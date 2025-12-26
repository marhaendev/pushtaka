package repository

import (
	"context"
	"pushtaka/services/transaction/internal/domain"

	"gorm.io/gorm"
)

type postgresTransactionRepo struct {
	db *gorm.DB
}

func NewPostgresTransactionRepo(db *gorm.DB) domain.TransactionRepository {
	return &postgresTransactionRepo{db}
}

func (p *postgresTransactionRepo) Create(ctx context.Context, transaction *domain.Transaction) error {
	return p.db.WithContext(ctx).Create(transaction).Error
}

func (p *postgresTransactionRepo) Update(ctx context.Context, transaction *domain.Transaction) error {
	return p.db.WithContext(ctx).Save(transaction).Error
}

func (p *postgresTransactionRepo) GetByUserID(ctx context.Context, userID uint) ([]domain.Transaction, error) {
	var transactions []domain.Transaction
	err := p.db.WithContext(ctx).
		Preload("Book").
		Where("user_id = ?", userID).
		Order("created_at desc").
		Find(&transactions).Error
	return transactions, err
}

func (p *postgresTransactionRepo) GetByID(ctx context.Context, id uint) (*domain.Transaction, error) {
	var transaction domain.Transaction
	err := p.db.WithContext(ctx).First(&transaction, id).Error
	if err != nil {
		return nil, err
	}
	return &transaction, nil
}

func (p *postgresTransactionRepo) GetUnpaidFines(ctx context.Context, userID uint) ([]domain.Transaction, error) {
	var transactions []domain.Transaction
	err := p.db.WithContext(ctx).
		Where("user_id = ? AND fine > 0 AND paid_at IS NULL", userID).
		Order("created_at desc").
		Find(&transactions).Error
	return transactions, err
}

func (p *postgresTransactionRepo) GetAll(ctx context.Context) ([]domain.Transaction, error) {
	var transactions []domain.Transaction
	err := p.db.WithContext(ctx).
		Preload("Book").
		Preload("User").
		Order("created_at desc").
		Find(&transactions).Error
	return transactions, err
}

func (p *postgresTransactionRepo) CountActiveBorrows(ctx context.Context, userID uint) (int64, error) {
	var count int64
	// Simplification: Count 'borrow' minus 'return' for specific book?
	// For "Active Borrows count":
	// We might need a better query or strategy. 
	// Simple approach: Count 'borrow' transactions where there is no corresponding 'return' for the same book/user.
	// This is complex in SQL.
	// Alternative: Add 'status' field to transaction or a separate 'Borrow' table.
	// Based on "Transaction" being an event log, reconstructing state is hard.
	// Let's assume 'Status' field in Transaction handles it ? 
	// Re-reading logic: "Create transaction". If I borrow, I create a record.
	// If I return, I create another record?
	// The prompt implies "Transaction Service" handles process.
	// Let's stick to simple logic: 
	// Find all borrows for user. Find all returns for user. Count difference?
	// But we need to limit to 3 books.
	// Let's assume we count (Borrow - Return).
	
	// Better query:
	// SELECT count(*) FROM transactions t1 WHERE action = 'borrow' AND user_id = ? AND NOT EXISTS (SELECT 1 FROM transactions t2 WHERE t2.book_id = t1.book_id AND t2.user_id = t1.user_id AND t2.action = 'return' AND t2.created_at > t1.created_at)
	
	err := p.db.WithContext(ctx).Model(&domain.Transaction{}).
		Where("user_id = ? AND action = 'borrow'", userID).
		Where("NOT EXISTS (SELECT 1 FROM transactions t2 WHERE t2.book_id = transactions.book_id AND t2.user_id = transactions.user_id AND t2.action = 'return' AND t2.created_at > transactions.created_at)").
		Count(&count).Error
	
	return count, err
}

func (p *postgresTransactionRepo) GetActiveBorrow(ctx context.Context, userID uint, bookID uint) (*domain.Transaction, error) {
	var transaction domain.Transaction
	// Find the latest borrow for this book/user that hasn't been returned
	// Logic: Find 'borrow' action. Ensure no 'return' exists after it.
	err := p.db.WithContext(ctx).
		Where("user_id = ? AND book_id = ? AND action = 'borrow'", userID, bookID).
		Where("NOT EXISTS (SELECT 1 FROM transactions t2 WHERE t2.book_id = transactions.book_id AND t2.user_id = transactions.user_id AND t2.action = 'return' AND t2.created_at > transactions.created_at)").
		Order("created_at desc").
		First(&transaction).Error
		
	if err != nil {
		return nil, err
	}
	return &transaction, nil
}

func (p *postgresTransactionRepo) GetConfig(ctx context.Context, key string) (string, error) {
	var config domain.Config
	err := p.db.WithContext(ctx).Where("key = ?", key).First(&config).Error
	return config.Value, err
}

func (p *postgresTransactionRepo) UpdateConfig(ctx context.Context, key string, value string) error {
	var config domain.Config
	// Check if exists
	err := p.db.WithContext(ctx).Where("key = ?", key).First(&config).Error
	if err == nil {
		// Update
		config.Value = value
		return p.db.WithContext(ctx).Save(&config).Error
	}
	
	// Create new
	newConfig := domain.Config{
		Key: key,
		Value: value,
		Type: "int", // Default type
		IsVisible: true,
	}
	return p.db.WithContext(ctx).Create(&newConfig).Error
}
func (p *postgresTransactionRepo) DeleteByBookID(ctx context.Context, bookID uint) error {
	result := p.db.WithContext(ctx).Where("book_id = ?", bookID).Delete(&domain.Transaction{})
	if result.Error != nil {
		return result.Error
	}
	return nil
}
