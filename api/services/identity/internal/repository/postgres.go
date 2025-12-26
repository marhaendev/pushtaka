package repository

import (
	"context"
	"pushtaka/services/identity/internal/domain"
	"time"

	"gorm.io/gorm"
)

type userRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) domain.UserRepository {
	return &userRepository{db}
}

func (r *userRepository) Create(ctx context.Context, user *domain.User) error {
	return r.db.WithContext(ctx).Create(user).Error
}

func (r *userRepository) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
	var user domain.User
	err := r.db.WithContext(ctx).Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) GetByEmailUnscoped(ctx context.Context, email string) (*domain.User, error) {
	var user domain.User
	err := r.db.WithContext(ctx).Unscoped().Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) GetByID(ctx context.Context, id uint) (*domain.User, error) {
	var user domain.User
	err := r.db.WithContext(ctx).First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) Update(ctx context.Context, user *domain.User) error {
	return r.db.WithContext(ctx).Save(user).Error
}

func (r *userRepository) GetByResetToken(ctx context.Context, token string) (*domain.User, error) {
	var user domain.User
	err := r.db.WithContext(ctx).Where("reset_token = ? AND reset_token_expiry > ?", token, time.Now()).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) GetAll(ctx context.Context, limit, offset int) ([]domain.User, int64, error) {
	var users []domain.User
	var total int64

	if err := r.db.WithContext(ctx).Model(&domain.User{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	if err := r.db.WithContext(ctx).Limit(limit).Offset(offset).Find(&users).Error; err != nil {
		return nil, 0, err
	}

	return users, total, nil
}

func (r *userRepository) Delete(ctx context.Context, id uint) error {
	// return r.db.WithContext(ctx).Delete(&domain.User{}, id).Error
	result := r.db.WithContext(ctx).Delete(&domain.User{}, id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (r *userRepository) DeletePermanent(ctx context.Context, id uint) error {
	result := r.db.WithContext(ctx).Unscoped().Delete(&domain.User{}, id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (r *userRepository) DeleteBatch(ctx context.Context, ids []uint, permanent bool) error {
	db := r.db.WithContext(ctx)
	if permanent {
		db = db.Unscoped()
	}

	result := db.Where("id IN ?", ids).Delete(&domain.User{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (r *userRepository) GetConfig(ctx context.Context, key string) (string, error) {
	var config domain.Config
	err := r.db.WithContext(ctx).Where("key = ?", key).First(&config).Error
	return config.Value, err
}

func (r *userRepository) SetConfig(ctx context.Context, key string, value string) error {
	config := domain.Config{Key: key, Value: value}
	return r.db.WithContext(ctx).Save(&config).Error
}

func (r *userRepository) GetAllConfigs(ctx context.Context) ([]domain.Config, error) {
	var configs []domain.Config
	err := r.db.WithContext(ctx).Find(&configs).Error
	return configs, err
}

func (r *userRepository) GetConfigByKey(ctx context.Context, key string) (*domain.Config, error) {
	var config domain.Config
	err := r.db.WithContext(ctx).Where("key = ?", key).First(&config).Error
	return &config, err
}

func (r *userRepository) CreateConfig(ctx context.Context, config *domain.Config) error {
	return r.db.WithContext(ctx).Create(config).Error
}

func (r *userRepository) UpdateConfig(ctx context.Context, config *domain.Config) error {
	return r.db.WithContext(ctx).Save(config).Error
}

func (r *userRepository) DeleteConfig(ctx context.Context, key string) error {
	result := r.db.WithContext(ctx).Delete(&domain.Config{}, "key = ?", key)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (r *userRepository) DeleteConfigs(ctx context.Context, keys []string) error {
	result := r.db.WithContext(ctx).Delete(&domain.Config{}, "key IN ?", keys)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (r *userRepository) GetConfigByID(ctx context.Context, id uint) (*domain.Config, error) {
	var config domain.Config
	err := r.db.WithContext(ctx).First(&config, id).Error
	return &config, err
}

func (r *userRepository) DeleteConfigByID(ctx context.Context, id uint) error {
	result := r.db.WithContext(ctx).Delete(&domain.Config{}, id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (r *userRepository) DeleteConfigsByIDs(ctx context.Context, ids []uint) error {
	result := r.db.WithContext(ctx).Delete(&domain.Config{}, ids)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}
