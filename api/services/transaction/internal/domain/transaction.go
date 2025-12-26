package domain

import (
	"context"
	"time"

	"gorm.io/gorm"
)

// Book represents the book model from book service
// We define it here to enable preloading in transaction history
type Book struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	Title     string         `gorm:"not null" json:"title"`
	Author    string         `json:"author"`
	Slug      string         `gorm:"uniqueIndex" json:"slug"`
	Image     string         `json:"image"`
	Stock     int            `gorm:"default:0" json:"stock"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// User represents the user model
// We define it here to enable preloading in transaction history
type User struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	Email     string         `gorm:"uniqueIndex;not null" json:"email"`
	Name      string         `json:"name"`
	Role      string         `gorm:"default:'user'" json:"role"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

type Transaction struct {
	ID         uint           `gorm:"primaryKey" json:"id"`
	UserID     uint           `gorm:"not null" json:"user_id"`
	User       *User          `gorm:"foreignKey:UserID" json:"user,omitempty"` // Preloaded user details
	BookID     uint           `gorm:"not null" json:"book_id"`
	Book       *Book          `gorm:"foreignKey:BookID" json:"book,omitempty"` // Preloaded book details
	Action     string         `gorm:"not null" json:"action"` // "borrow" or "return"
	Status     string         `gorm:"default:'pending'" json:"status"`
	DueDate    *time.Time     `json:"due_date"`
	ReturnDate *time.Time     `json:"return_date"`
	Fine       int            `json:"fine"`
	PaidAt     *time.Time     `json:"paid_at"` // Timestamp when fine was paid
	PaymentMethod string      `json:"payment_method"` // "qris" or "manual"
	PaymentProof  string      `json:"payment_proof"`  // URL or base64 for manual transfer
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
}

type Config struct {
	ID          uint   `gorm:"primaryKey" json:"id"`
	Key         string `gorm:"uniqueIndex;not null" json:"key"`
	Value       string `json:"value"`
	Description string `json:"description"`
	Type        string `json:"type" gorm:"default:'string'"`
	IsVisible   bool   `json:"is_visible" gorm:"default:true"`
}

type Settings struct {
	BorrowDuration     int    `json:"borrow_duration"`
	BorrowDurationUnit string `json:"borrow_duration_unit"` // "minute", "hour", "day"
	FineAmount         int    `json:"fine_amount"`
	FineUnit           string `json:"fine_unit"`           // "minute", "hour", "day", "month"
	FineDuration       int    `json:"fine_duration"`       // e.g., per 2 (minutes)
	MaxBorrowLimit     int    `json:"max_borrow_limit"`
}

type TransactionRepository interface {
	Create(ctx context.Context, transaction *Transaction) error
	Update(ctx context.Context, transaction *Transaction) error
	GetByUserID(ctx context.Context, userID uint) ([]Transaction, error)
	GetByID(ctx context.Context, id uint) (*Transaction, error)
	CountActiveBorrows(ctx context.Context, userID uint) (int64, error)
	GetActiveBorrow(ctx context.Context, userID uint, bookID uint) (*Transaction, error)
	GetUnpaidFines(ctx context.Context, userID uint) ([]Transaction, error)
	GetAll(ctx context.Context) ([]Transaction, error)
	
	// Config
	GetConfig(ctx context.Context, key string) (string, error)
	UpdateConfig(ctx context.Context, key string, value string) error
	DeleteByBookID(ctx context.Context, bookID uint) error
}

type TransactionUsecase interface {
	BorrowBook(ctx context.Context, userID uint, bookID uint) error
	ReturnBook(ctx context.Context, userID uint, bookID uint) error

	History(ctx context.Context, userID uint) ([]Transaction, error)
	GetAllHistory(ctx context.Context) ([]Transaction, error)
	
	// Settings
	GetSettings(ctx context.Context) (*Settings, error)
	UpdateSettings(ctx context.Context, settings *Settings) error
	
	// Fine Management
	GetMyFines(ctx context.Context, userID uint) ([]Transaction, error)
	VerifyFine(ctx context.Context, transactionID uint, action string) error
	HandlePaymentCallback(ctx context.Context, orderID string, status string) error
	PayFine(ctx context.Context, userID uint, transactionID uint, method string, proof string) (string, error)

	// Test/Debug helpers
	MakeLate(ctx context.Context, userID uint, transactionID uint, daysLate int) error
	DeleteByBookID(ctx context.Context, bookID uint) error
}
