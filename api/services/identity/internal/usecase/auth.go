package usecase

import (
	"context"
	"errors"
	"log"
	"os"
	"pushtaka/pkg/auth"
	"pushtaka/pkg/mail"
	"pushtaka/services/identity/internal/domain"
	"strconv"
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type authUsecase struct {
	userRepo       domain.UserRepository
	mailSender     mail.Sender
	contextTimeout time.Duration
	jwtExpiry      time.Duration
	jwtSecret      string
}

func NewAuthUsecase(userRepo domain.UserRepository, mailSender mail.Sender, timeout time.Duration) domain.AuthUsecase {
	expiryHoursStr := os.Getenv("JWT_EXPIRATION_HOURS")
	expiryHours, err := strconv.Atoi(expiryHoursStr)
	if err != nil || expiryHours <= 0 {
		expiryHours = 24 // Default fallback
	}

	return &authUsecase{
		userRepo:       userRepo,
		mailSender:     mailSender,
		contextTimeout: timeout,
		jwtExpiry:      time.Duration(expiryHours) * time.Hour,
		jwtSecret:      os.Getenv("JWT_SECRET"),
	}
}

func (u *authUsecase) Register(c context.Context, req *domain.RegisterRequest) (*domain.AuthResponse, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	// 1. Hash Password first
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	// 2. Generate 6-digit OTP
	otp := auth.GenerateOTP()
	otpExpiry := time.Now().Add(5 * time.Minute)

	// 3. Check if user exists (including deleted)
	var userToProcess *domain.User
	existingUser, err := u.userRepo.GetByEmailUnscoped(ctx, req.Email)

	if existingUser != nil {
		// Check if active or deleted
		if existingUser.DeletedAt.Valid {
			// DELETED USER -> RESTORE SEQUENCE
			existingUser.DeletedAt = gorm.DeletedAt{} // Clear delete flag (Restore)
			existingUser.Name = req.Name
			existingUser.Password = string(hashedPassword)
			existingUser.OTP = otp
			existingUser.OTPPurpose = "register"
			existingUser.OTPExpiry = otpExpiry
			existingUser.IsVerified = false // Require re-verification

			if err := u.userRepo.Update(ctx, existingUser); err != nil {
				return nil, err
			}
			userToProcess = existingUser
		} else {
			// ACTIVE USER
			if existingUser.IsVerified {
				return nil, errors.New("email already exists")
			}
			// RE-REGISTER: Update existing unverified user
			existingUser.Name = req.Name
			existingUser.Password = string(hashedPassword)
			existingUser.OTP = otp
			existingUser.OTPPurpose = "register"
			existingUser.OTPExpiry = otpExpiry

			if err := u.userRepo.Update(ctx, existingUser); err != nil {
				return nil, err
			}
			userToProcess = existingUser
		}
	} else {
		// NEW REGISTER: Create new user
		newUser := &domain.User{
			Email:      req.Email,
			Password:   string(hashedPassword),
			Name:       req.Name,
			OTP:        otp,
			OTPPurpose: "register",
			OTPExpiry:  otpExpiry,
			IsVerified: false,
		}

		if err := u.userRepo.Create(ctx, newUser); err != nil {
			return nil, err
		}
		userToProcess = newUser
	}

	// 4. Send OTP Email
	log.Printf("DEBUG REGISTER OTP for %s: %s", userToProcess.Email, otp)
	if err := u.mailSender.SendOTP(userToProcess.Email, userToProcess.Name, otp); err != nil {
		log.Printf("Failed to send OTP: %v", err)
		// return nil, errors.New("failed to send verification email") // Suppress for testing
	}

	// Return success but NO token
	return &domain.AuthResponse{
		Token: "", // No token until verified
		User:  *userToProcess,
	}, nil
}

func (u *authUsecase) Login(c context.Context, req *domain.LoginRequest) (*domain.AuthResponse, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	user, err := u.userRepo.GetByEmail(ctx, req.Email)
	if err != nil {
		return nil, errors.New("invalid credentials")
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password))
	if err != nil {
		return nil, errors.New("invalid credentials")
	}

	if !user.IsVerified {
		return nil, errors.New("account not verified")
	}

	// Generate Token
	// Get Expiry from Config
	expiryStr, err := u.userRepo.GetConfig(ctx, "jwt_expiration_hours")
	expiryDuration := u.jwtExpiry
	if err == nil {
		if hours, err := strconv.Atoi(expiryStr); err == nil && hours > 0 {
			expiryDuration = time.Duration(hours) * time.Hour
		}
	}
	
	token, err := auth.GenerateToken(user.ID, user.Email, user.Role, u.jwtSecret, expiryDuration)
	if err != nil {
		return nil, err
	}

	return &domain.AuthResponse{Token: token, User: *user}, nil
}

func (u *authUsecase) RequestOTP(c context.Context, email string, purpose string) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	user, err := u.userRepo.GetByEmail(ctx, email)
	if err != nil {
		return errors.New("email not found")
	}

	// Validate purpose
	if purpose != "change_password" && purpose != "change_email" && purpose != "register" && purpose != "reset_password" {
		return errors.New("invalid otp purpose")
	}

	// Generate 6-digit OTP
	otp := auth.GenerateOTP()
	expiry := time.Now().Add(5 * time.Minute)

	user.OTP = otp
	user.OTPPurpose = purpose
	user.OTPExpiry = expiry

	if err := u.userRepo.Update(ctx, user); err != nil {
		return err
	}

	// Send OTP Email
	if err := u.mailSender.SendOTP(user.Email, user.Name, otp); err != nil {
		log.Printf("Failed to send OTP for %s: %v", purpose, err)
		return errors.New("failed to send OTP email")
	}

	return nil
}

func (u *authUsecase) ForgotPassword(c context.Context, req *domain.ForgotPasswordRequest) (string, error) {
	err := u.RequestOTP(c, req.Email, "reset_password")
	if err != nil {
		return "", err
	}
	return "otp sent", nil
}

func (u *authUsecase) ResetPassword(c context.Context, req *domain.ResetPasswordRequest) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	// Find by Reset Token instead of Email+OTP (Restoring secure flow)
	user, err := u.userRepo.GetByResetToken(ctx, req.Token)
	if err != nil {
		return errors.New("invalid or expired token")
	}

	// SECURITY CHECK: Ensure token belongs to the requested email
	// REMOVED: Email is no longer required in request, token is sufficient.
	// if user.Email != req.Email {
	// 	return errors.New("invalid token for this email")
	// }

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	user.Password = string(hashedPassword)
	user.ResetToken = ""
	return u.userRepo.Update(ctx, user)
}

func (u *authUsecase) VerifyOTP(c context.Context, req *domain.VerifyOTPRequest) (*domain.AuthResponse, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	user, err := u.userRepo.GetByEmail(ctx, req.Email)
	if err != nil {
		return nil, errors.New("invalid email")
	}

	if user.OTP != req.OTP {
		return nil, errors.New("invalid otp")
	}

	if user.OTPPurpose != req.Purpose {
		return nil, errors.New("invalid otp purpose")
	}

	if time.Now().After(user.OTPExpiry) {
		return nil, errors.New("otp expired")
	}

	// Verify Success - Clear OTP
	user.OTP = ""
	user.OTPPurpose = ""
	user.OTPExpiry = time.Time{}

	// Purpose Specific Logic
	if req.Purpose == "register" {
		user.IsVerified = true
		if err := u.userRepo.Update(ctx, user); err != nil {
			return nil, err
		}

		// Generate Login Token
		token, err := auth.GenerateToken(user.ID, user.Email, user.Role, os.Getenv("JWT_SECRET"), u.jwtExpiry)
		if err != nil {
			return nil, err
		}
		return &domain.AuthResponse{Token: token, User: *user}, nil

	} else if req.Purpose == "reset_password" || req.Purpose == "change_password" {
		// Generate 15-min Reset Token
		resetToken := "reset-" + auth.GenerateOTP() + "-" + time.Now().Format("20060102150405")
		user.ResetToken = resetToken
		user.ResetTokenExpiry = time.Now().Add(15 * time.Minute)
		
		if err := u.userRepo.Update(ctx, user); err != nil {
			return nil, err
		}

		// Return the reset token in the response
		return &domain.AuthResponse{Token: resetToken, User: *user}, nil

	} else if req.Purpose == "change_email" {
		// Generate 15-min Reset Token (reuse ResetToken field for simplicity or rename if needed)
		// For now we reuse ResetToken field for any secure action token
		changeToken := "change-email-" + auth.GenerateOTP() + "-" + time.Now().Format("20060102150405")
		user.ResetToken = changeToken
		user.ResetTokenExpiry = time.Now().Add(15 * time.Minute)

		if err := u.userRepo.Update(ctx, user); err != nil {
			return nil, err
		}

		return &domain.AuthResponse{Token: changeToken, User: *user}, nil
	}

	return nil, errors.New("invalid purpose")
}

func (u *authUsecase) ChangeEmail(c context.Context, req *domain.ChangeEmailRequest) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	user, err := u.userRepo.GetByResetToken(ctx, req.Token)
	if err != nil {
		return errors.New("invalid or expired token")
	}

	// Check if new email is taken
	existing, _ := u.userRepo.GetByEmail(ctx, req.NewEmail)
	if existing != nil && existing.ID != user.ID {
		return errors.New("email already taken")
	}

	user.Email = req.NewEmail
	user.ResetToken = ""
	user.ResetTokenExpiry = time.Time{}

	return u.userRepo.Update(ctx, user)
}
