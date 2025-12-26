package domain

import (
	"context"
	"time"

	"gorm.io/gorm"
)

type Favorite struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	UserID    uint           `gorm:"not null;uniqueIndex:idx_user_book" json:"user_id"`
	BookID    uint           `gorm:"not null;uniqueIndex:idx_user_book" json:"book_id"`
	Book      Book           `gorm:"foreignKey:BookID" json:"book"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

type FavoriteRepository interface {
	FetchByUserID(ctx context.Context, userID uint) ([]Favorite, error)
	Store(ctx context.Context, favorite *Favorite) error
	Delete(ctx context.Context, userID uint, bookID uint) error
}

type FavoriteUsecase interface {
	FetchByUserID(ctx context.Context, userID uint) ([]Book, error)
	Store(ctx context.Context, userID uint, bookID uint) error
	Delete(ctx context.Context, userID uint, bookID uint) error
}
