package repository

import (
	"context"
	"pushtaka/services/book/internal/domain"

	"gorm.io/gorm"
)

type postgresBookRepo struct {
	db *gorm.DB
}

func NewPostgresBookRepo(db *gorm.DB) domain.BookRepository {
	return &postgresBookRepo{db}
}

func (p *postgresBookRepo) Fetch(ctx context.Context) ([]domain.Book, error) {
	var books []domain.Book
	err := p.db.WithContext(ctx).Find(&books).Error
	return books, err
}

func (p *postgresBookRepo) GetByID(ctx context.Context, id uint) (*domain.Book, error) {
	var book domain.Book
	err := p.db.WithContext(ctx).First(&book, id).Error
	if err != nil {
		return nil, err
	}
	return &book, nil
}

func (p *postgresBookRepo) GetBySlug(ctx context.Context, slug string) (*domain.Book, error) {
	var book domain.Book
	err := p.db.WithContext(ctx).Unscoped().Where("slug = ?", slug).First(&book).Error
	if err != nil {
		return nil, err
	}
	return &book, nil
}

func (p *postgresBookRepo) Store(ctx context.Context, book *domain.Book) error {
	return p.db.WithContext(ctx).Create(book).Error
}

func (p *postgresBookRepo) Update(ctx context.Context, book *domain.Book) error {
	result := p.db.WithContext(ctx).Model(book).Updates(book)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (p *postgresBookRepo) Delete(ctx context.Context, id uint) error {
	result := p.db.WithContext(ctx).Delete(&domain.Book{}, id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (p *postgresBookRepo) DeleteBatch(ctx context.Context, ids []uint) error {
	result := p.db.WithContext(ctx).Where("id IN ?", ids).Delete(&domain.Book{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (p *postgresBookRepo) UpdateStock(ctx context.Context, id uint, quantity int) error {
	return p.db.WithContext(ctx).Model(&domain.Book{}).Where("id = ?", id).UpdateColumn("stock", gorm.Expr("stock + ?", quantity)).Error
}
