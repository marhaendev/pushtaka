package domain

import (
	"context"
	"time"

	"gorm.io/gorm"
)

type Book struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	Title           string         `gorm:"not null" json:"title"`
	Slug            string         `gorm:"uniqueIndex" json:"slug"`
	Code            string         `gorm:"uniqueIndex" json:"code"`
	ISBN            string         `json:"isbn"`
	Publisher       string         `json:"publisher"`
	PublicationYear int            `json:"publication_year"`
	Description     string         `json:"description"`
	Author          string         `gorm:"not null" json:"author"`
	Image           string         `json:"image"`
	Stock           int            `gorm:"not null" json:"stock"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

type BookRepository interface {
	Fetch(ctx context.Context) ([]Book, error)
	GetByID(ctx context.Context, id uint) (*Book, error)
	GetBySlug(ctx context.Context, slug string) (*Book, error)
	Store(ctx context.Context, book *Book) error
	Update(ctx context.Context, book *Book) error
	Delete(ctx context.Context, id uint) error
	DeleteBatch(ctx context.Context, ids []uint) error
	UpdateStock(ctx context.Context, id uint, quantity int) error
}

type BookUsecase interface {
	Fetch(ctx context.Context) ([]Book, error)
	GetByID(ctx context.Context, id uint) (*Book, error)
	Store(ctx context.Context, book *Book) error
	Update(ctx context.Context, book *Book) error
	Delete(ctx context.Context, id uint) error
	DeleteBatch(ctx context.Context, ids []uint) error
}

type BookPublisher interface {
	PublishBookDeleted(bookID uint) error
}
