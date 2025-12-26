package handler

import (
	"errors"
    "strings"
	"pushtaka/pkg/utils"
	"pushtaka/services/identity/internal/domain"
    "strconv"
    
    "gorm.io/gorm"

	"github.com/gofiber/fiber/v2"
)

type SettingsHandler struct {
	settingsUsecase domain.SettingsUsecase
}

func NewSettingsHandler(app *fiber.App, settingsUsecase domain.SettingsUsecase, roleMiddleware fiber.Handler) {
	handler := &SettingsHandler{
		settingsUsecase: settingsUsecase,
	}

	api := app.Group("/settings")
	api.Use(roleMiddleware)
	
	api.Get("/", handler.ListSettings)
	api.Get("/:key", handler.GetSetting)
	api.Post("/", handler.CreateSetting)
	api.Put("/:key", handler.UpdateSetting)
	api.Delete("/:key", handler.DeleteSetting)
	api.Delete("/", handler.DeleteSettings)
}

func (h *SettingsHandler) ListSettings(c *fiber.Ctx) error {
	configs, err := h.settingsUsecase.GetAllSettings(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}
	return c.JSON(utils.Success("settings retrieved", configs))
}

func (h *SettingsHandler) GetSetting(c *fiber.Ctx) error {
	param := c.Params("key")
	
	// Check if param is numeric ID
	id, err := strconv.Atoi(param)
	if err == nil {
		config, err := h.settingsUsecase.GetSettingByID(c.Context(), uint(id))
		if err != nil {
			return c.Status(fiber.StatusNotFound).JSON(utils.Error("setting not found"))
		}
		return c.JSON(utils.Success("setting retrieved", config))
	}

	config, err := h.settingsUsecase.GetSetting(c.Context(), param)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(utils.Error("setting not found"))
	}
	return c.JSON(utils.Success("setting retrieved", config))
}

func (h *SettingsHandler) CreateSetting(c *fiber.Ctx) error {
	type Request struct {
		Key         string `json:"key"`
		Value       string `json:"value"`
		Description string `json:"description"`
		Type        string `json:"type"`
		IsVisible   bool   `json:"is_visible"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}
	
	// Default Type if empty
	if req.Type == "" {
		req.Type = "string"
	}
	
	err := h.settingsUsecase.CreateSetting(c.Context(), req.Key, req.Value, req.Description, req.Type, req.IsVisible)
	if err != nil {
		if err.Error() == "setting with this key already exists" {
			return c.Status(fiber.StatusConflict).JSON(utils.Error(err.Error()))
		}
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}

	return c.Status(fiber.StatusCreated).JSON(utils.Success("setting created", nil))
}

func (h *SettingsHandler) UpdateSetting(c *fiber.Ctx) error {
	param := c.Params("key")
	
	type Request struct {
		Value     string `json:"value"`
		IsVisible *bool  `json:"is_visible"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}
	
	id, err := strconv.Atoi(param)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("update must use setting ID, not key"))
	}

	err = h.settingsUsecase.UpdateSettingByID(c.Context(), uint(id), req.Value, req.IsVisible)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}
	return c.JSON(utils.Success("setting updated", nil))
}

func (h *SettingsHandler) DeleteSetting(c *fiber.Ctx) error {
	param := c.Params("key")
	
	id, err := strconv.Atoi(param)
	if err == nil {
		err := h.settingsUsecase.DeleteSettingByID(c.Context(), uint(id))
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) || strings.Contains(err.Error(), "record not found") {
				return c.Status(fiber.StatusNotFound).JSON(utils.Error("setting not found"))
			}
			return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
		}
		return c.JSON(utils.Success("setting deleted", nil))
	}

	err = h.settingsUsecase.DeleteSetting(c.Context(), param)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) || strings.Contains(err.Error(), "record not found") {
			return c.Status(fiber.StatusNotFound).JSON(utils.Error("setting not found"))
		}
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}
	return c.JSON(utils.Success("setting deleted", nil))
}

func (h *SettingsHandler) DeleteSettings(c *fiber.Ctx) error {
	type Request struct {
		Keys []string `json:"keys"`
		IDs  []uint   `json:"ids"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}

	if len(req.IDs) > 0 {
		err := h.settingsUsecase.DeleteSettingsByIDs(c.Context(), req.IDs)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
		}
		return c.JSON(utils.Success("settings deleted", nil))
	}

	err := h.settingsUsecase.DeleteSettings(c.Context(), req.Keys)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}
	return c.JSON(utils.Success("settings deleted", nil))
}
