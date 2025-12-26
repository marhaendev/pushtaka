package domain

import (
	"context"
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	Email     string         `gorm:"uniqueIndex;not null" json:"email"`
	Password  string         `gorm:"not null" json:"-"`
	Name      string         `json:"name"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt        gorm.DeletedAt `gorm:"index" json:"-"`
	ResetToken       string         `json:"-"`
	ResetTokenExpiry time.Time      `json:"-"`
	OTP              string         `json:"-"`
	OTPPurpose       string         `json:"-"`
	OTPExpiry        time.Time      `json:"-"`
	IsVerified       bool           `gorm:"default:false" json:"is_verified"`
	Role             string         `gorm:"default:'user'" json:"role"`
}

const (
	RoleUser  = "user"
	RoleAdmin = "admin"
)

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type RegisterRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
	Name     string `json:"name"`
}

type VerifyOTPRequest struct {
	Email   string `json:"email"`
	OTP     string `json:"otp"`
	Purpose string `json:"purpose"` // register, login, reset_password, change_password, change_email
}

type RequestOTPRequest struct {
	Email   string `json:"email"`
	Purpose string `json:"purpose"`
}

type UpdateUserRequest struct {
	Name       string `json:"name"`
	Email      string `json:"email"`
	Role       string `json:"role"`
	IsVerified *bool  `json:"is_verified"` // Use pointer to distinguish between false and missing
}

type UpdateProfileRequest struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

type ForgotPasswordRequest struct {
	Email string `json:"email"`
}

type ResetPasswordRequest struct {
	Token       string `json:"token"`
	NewPassword string `json:"new_password"`
}

type ChangeEmailRequest struct {
	Token    string `json:"token"`
	NewEmail string `json:"new_email"`
}

type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

type UserResponse struct {
	ID         uint      `json:"id"`
	Email      string    `json:"email"`
	Name       string    `json:"name"`
	Role       string    `json:"role"`
	IsVerified bool      `json:"is_verified"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type Config struct {
	ID          uint   `gorm:"primaryKey" json:"id"`
	Key         string `gorm:"uniqueIndex;not null" json:"key"`
	Value       string `json:"value"`
	Description string `json:"description"`
	Type        string `json:"type" gorm:"default:'string'"`
	IsVisible   bool   `json:"is_visible" gorm:"default:true"`
}

type UserRepository interface {
	Create(ctx context.Context, user *User) error
	GetByEmail(ctx context.Context, email string) (*User, error)
	GetByEmailUnscoped(ctx context.Context, email string) (*User, error)
	GetByID(ctx context.Context, id uint) (*User, error)
	Update(ctx context.Context, user *User) error
	Delete(ctx context.Context, id uint) error
	DeletePermanent(ctx context.Context, id uint) error
	GetAll(ctx context.Context, limit, offset int) ([]User, int64, error)
	DeleteBatch(ctx context.Context, ids []uint, permanent bool) error
	
	// Config (Legacy/Internal)
	GetConfig(ctx context.Context, key string) (string, error)
	SetConfig(ctx context.Context, key string, value string) error
	
	// Reset Token
	GetByResetToken(ctx context.Context, token string) (*User, error)
	
	// Settings CRUD
	GetAllConfigs(ctx context.Context) ([]Config, error)
	GetConfigByKey(ctx context.Context, key string) (*Config, error)
	GetConfigByID(ctx context.Context, id uint) (*Config, error)
	CreateConfig(ctx context.Context, config *Config) error
	UpdateConfig(ctx context.Context, config *Config) error
	DeleteConfig(ctx context.Context, key string) error // Keep for legacy/utility? Or just ID? User said "settings/id"
	DeleteConfigByID(ctx context.Context, id uint) error
	DeleteConfigs(ctx context.Context, keys []string) error // Batch delete usually by IDs now? User asked "agar bisa settings/id". 
    // Let's keep keys for batch or switch to IDs? Batch delete usually sends IDs.
    // Let's support both or switch to IDs. Batch Delete by Keys logic might be brittle if Key changes. 
    // I will switch Batch Delete to IDs too for consistency.
	DeleteConfigsByIDs(ctx context.Context, ids []uint) error
}

type SettingsUsecase interface {
	GetAllSettings(ctx context.Context) ([]Config, error)
	GetSetting(ctx context.Context, key string) (*Config, error)
	GetSettingByID(ctx context.Context, id uint) (*Config, error) // NEW
	CreateSetting(ctx context.Context, key, value, description, typeStr string, isVisible bool) error
	UpdateSetting(ctx context.Context, key, value string, isVisible *bool) error
	UpdateSettingByID(ctx context.Context, id uint, value string, isVisible *bool) error // NEW
	DeleteSetting(ctx context.Context, key string) error
	DeleteSettingByID(ctx context.Context, id uint) error // NEW
	DeleteSettings(ctx context.Context, keys []string) error
	DeleteSettingsByIDs(ctx context.Context, ids []uint) error // NEW
}

type AuthUsecase interface {
	Register(ctx context.Context, req *RegisterRequest) (*AuthResponse, error)
	Login(ctx context.Context, req *LoginRequest) (*AuthResponse, error)
	ForgotPassword(ctx context.Context, req *ForgotPasswordRequest) (string, error)
	ResetPassword(ctx context.Context, req *ResetPasswordRequest) error
	VerifyOTP(ctx context.Context, req *VerifyOTPRequest) (*AuthResponse, error)
	RequestOTP(ctx context.Context, email string, purpose string) error
	ChangeEmail(ctx context.Context, req *ChangeEmailRequest) error
}

type UserUsecase interface {
	// Admin
	GetAllUsers(ctx context.Context, limit, offset int) ([]User, error)
	GetUserByID(ctx context.Context, id uint) (*User, error)
	CreateUser(ctx context.Context, req *RegisterRequest) error
	UpdateUser(ctx context.Context, id uint, req *UpdateUserRequest) error
	DeleteUser(ctx context.Context, id uint, permanent bool) error
	DeleteUsers(ctx context.Context, ids []uint, permanent bool) error

	// Profile
	GetProfile(ctx context.Context, id uint) (*User, error)
	UpdateProfile(ctx context.Context, id uint, req *UpdateProfileRequest) error
}
