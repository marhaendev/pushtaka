package repository

import (
	"context"
	"pushtaka/services/book/internal/domain"

	"gorm.io/gorm"
)

type postgresFavoriteRepo struct {
	db *gorm.DB
}

func NewPostgresFavoriteRepo(db *gorm.DB) domain.FavoriteRepository {
	return &postgresFavoriteRepo{db}
}

func (p *postgresFavoriteRepo) FetchByUserID(ctx context.Context, userID uint) ([]domain.Favorite, error) {
	var favorites []domain.Favorite
	err := p.db.WithContext(ctx).Preload("Book").Where("user_id = ?", userID).Find(&favorites).Error
	return favorites, err
}

func (p *postgresFavoriteRepo) Store(ctx context.Context, favorite *domain.Favorite) error {
	var existing domain.Favorite
	err := p.db.WithContext(ctx).Unscoped().Where("user_id = ? AND book_id = ?", favorite.UserID, favorite.BookID).First(&existing).Error
	
	if err == nil {
		// Record exists (either active or soft-deleted)
		if existing.DeletedAt.Valid {
			// Restore soft-deleted record
			return p.db.WithContext(ctx).Model(&existing).Unscoped().Update("deleted_at", nil).Error
		}
		// Already active, nothing to do
		return nil
	}

	if err != gorm.ErrRecordNotFound {
		return err
	}

	// No record exists, create new one
	return p.db.WithContext(ctx).Create(favorite).Error
}

func (p *postgresFavoriteRepo) Delete(ctx context.Context, userID uint, bookID uint) error {
	result := p.db.WithContext(ctx).Where("user_id = ? AND book_id = ?", userID, bookID).Delete(&domain.Favorite{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}
