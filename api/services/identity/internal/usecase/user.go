package usecase

import (
	"context"
	"errors"
	"pushtaka/services/identity/internal/domain"
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type userUsecase struct {
	userRepo       domain.UserRepository
	contextTimeout time.Duration
}

func NewUserUsecase(userRepo domain.UserRepository, timeout time.Duration) domain.UserUsecase {
	return &userUsecase{
		userRepo:       userRepo,
		contextTimeout: timeout,
	}
}

func (u *userUsecase) GetAllUsers(c context.Context, limit, offset int) ([]domain.User, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	users, _, err := u.userRepo.GetAll(ctx, limit, offset)
	if err != nil {
		return nil, err
	}

	return users, nil
}

func (u *userUsecase) GetUserByID(c context.Context, id uint) (*domain.User, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	return u.userRepo.GetByID(ctx, id)
}

func (u *userUsecase) CreateUser(c context.Context, req *domain.RegisterRequest) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	existingUser, err := u.userRepo.GetByEmailUnscoped(ctx, req.Email)
	if existingUser != nil {
		if existingUser.DeletedAt.Valid {
			// Restore deleted user
			hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
			if err != nil {
				return err
			}
			existingUser.DeletedAt = gorm.DeletedAt{}
			existingUser.Name = req.Name
			existingUser.Password = string(hashedPassword)
			existingUser.Role = domain.RoleUser
			existingUser.IsVerified = true

			return u.userRepo.Update(ctx, existingUser)
		}
		return errors.New("email already exists")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	newUser := &domain.User{
		Email:      req.Email,
		Password:   string(hashedPassword),
		Name:       req.Name,
		Role:       domain.RoleUser, // Default to user, admin can update role later if needed
		IsVerified: true,            // Admin created users are auto-verified
	}

	return u.userRepo.Create(ctx, newUser)
}

func (u *userUsecase) UpdateUser(c context.Context, id uint, req *domain.UpdateUserRequest) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	user, err := u.userRepo.GetByID(ctx, id)
	if err != nil {
		return err
	}

	if req.Name != "" {
		user.Name = req.Name
	}
	if req.Email != "" {
		// Check if email taken by another user
		existingUser, _ := u.userRepo.GetByEmail(ctx, req.Email)
		if existingUser != nil && existingUser.ID != user.ID {
			return errors.New("email already used by another user")
		}
		user.Email = req.Email
	}
	if req.Role != "" {
		// Validate role?
		if req.Role != domain.RoleUser && req.Role != domain.RoleAdmin {
			return errors.New("invalid role")
		}
		user.Role = req.Role
	}
	if req.IsVerified != nil {
		user.IsVerified = *req.IsVerified
	}

	return u.userRepo.Update(ctx, user)
}

func (u *userUsecase) DeleteUser(c context.Context, id uint, permanent bool) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	if permanent {
		return u.userRepo.DeletePermanent(ctx, id)
	}

	return u.userRepo.Delete(ctx, id)
}

func (u *userUsecase) DeleteUsers(ctx context.Context, ids []uint, permanent bool) error {
	ctx, cancel := context.WithTimeout(ctx, u.contextTimeout)
	defer cancel()
	return u.userRepo.DeleteBatch(ctx, ids, permanent)
}

func (u *userUsecase) GetProfile(c context.Context, id uint) (*domain.User, error) {
	return u.GetUserByID(c, id)
}

func (u *userUsecase) UpdateProfile(c context.Context, id uint, req *domain.UpdateProfileRequest) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	user, err := u.userRepo.GetByID(ctx, id)
	if err != nil {
		return err
	}

	if req.Name != "" {
		user.Name = req.Name
	}
	if req.Email != "" {
		// Check if email taken by another user
		existingUser, _ := u.userRepo.GetByEmail(ctx, req.Email)
		if existingUser != nil && existingUser.ID != user.ID {
			return errors.New("email already used by another user")
		}
		user.Email = req.Email
	}

	return u.userRepo.Update(ctx, user)
}
