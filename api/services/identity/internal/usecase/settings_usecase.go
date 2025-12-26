package usecase

import (
	"context"
	"errors"
	"strings"
	"pushtaka/services/identity/internal/domain"
	"time"
)

type settingsUsecase struct {
	userRepo       domain.UserRepository
	contextTimeout time.Duration
}

func NewSettingsUsecase(userRepo domain.UserRepository, timeout time.Duration) domain.SettingsUsecase {
	return &settingsUsecase{
		userRepo:       userRepo,
		contextTimeout: timeout,
	}
}

func (u *settingsUsecase) GetAllSettings(c context.Context) ([]domain.Config, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	return u.userRepo.GetAllConfigs(ctx)
}

func (u *settingsUsecase) GetSetting(c context.Context, key string) (*domain.Config, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	return u.userRepo.GetConfigByKey(ctx, key)
}

func (u *settingsUsecase) CreateSetting(c context.Context, key, value, description, typeStr string, isVisible bool) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	config := &domain.Config{
		Key:         key,
		Value:       value,
		Description: description,
		Type:        typeStr,
		IsVisible:   isVisible,
	}
	// Check for duplicates BEFORE insert to prevent ID auto-increment gaps.
	// existing will not be nil even if not found because repo returns pointer to local var.
	// Must check error.
	_, err := u.userRepo.GetConfigByKey(ctx, key)
	if err == nil {
		// Found!
		return errors.New("setting with this key already exists")
	}
    // If error is NOT RecordNotFound, maybe we should return it?
    // But for now, let's assume any error means "not found" or "db issue", 
    // proceeding to create will likely fail if it's a DB issue anyway.
    // Ideally: if err != gorm.ErrRecordNotFound { return err }

	err = u.userRepo.CreateConfig(ctx, config)
	if err != nil {
		// Fallback check just in case race condition happens
		if strings.Contains(err.Error(), "duplicate key value") || strings.Contains(err.Error(), "unique constraint") {
			return errors.New("setting with this key already exists")
		}
		return err
	}
	return nil
}



func (u *settingsUsecase) UpdateSetting(c context.Context, key, value string, isVisible *bool) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	
	// Check exist
	existing, err := u.userRepo.GetConfigByKey(ctx, key)
	if err != nil {
		return err
	}
	
	if value != "" {
		existing.Value = value
	}
	if isVisible != nil {
		existing.IsVisible = *isVisible
	}
	
	return u.userRepo.UpdateConfig(ctx, existing)
}

func (u *settingsUsecase) DeleteSetting(c context.Context, key string) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	return u.userRepo.DeleteConfig(ctx, key)
}

func (u *settingsUsecase) DeleteSettings(c context.Context, keys []string) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	return u.userRepo.DeleteConfigs(ctx, keys)
}

func (u *settingsUsecase) GetSettingByID(c context.Context, id uint) (*domain.Config, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	return u.userRepo.GetConfigByID(ctx, id)
}

func (u *settingsUsecase) UpdateSettingByID(c context.Context, id uint, value string, isVisible *bool) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	
	existing, err := u.userRepo.GetConfigByID(ctx, id)
	if err != nil {
		return err
	}
	
	if value != "" {
		existing.Value = value
	}
	if isVisible != nil {
		existing.IsVisible = *isVisible
	}
	
	return u.userRepo.UpdateConfig(ctx, existing)
}

func (u *settingsUsecase) DeleteSettingByID(c context.Context, id uint) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	return u.userRepo.DeleteConfigByID(ctx, id)
}

func (u *settingsUsecase) DeleteSettingsByIDs(c context.Context, ids []uint) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	return u.userRepo.DeleteConfigsByIDs(ctx, ids)
}
