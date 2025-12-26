package handler

import (
	"pushtaka/pkg/utils"
	"pushtaka/services/identity/internal/domain"

	"github.com/gofiber/fiber/v2"
)

type AuthHandler struct {
	authUsecase domain.AuthUsecase
}

func NewAuthHandler(app *fiber.App, authUsecase domain.AuthUsecase) {
	handler := &AuthHandler{
		authUsecase: authUsecase,
	}

	// Public Routes
	authGroup := app.Group("/auth")
	authGroup.Post("/register", handler.Register)
	authGroup.Post("/verify-otp", handler.VerifyOTP)
	authGroup.Post("/login", handler.Login)
	authGroup.Post("/forgot-password", handler.ForgotPassword)
	authGroup.Post("/reset-password", handler.ResetPassword)
	authGroup.Post("/request-otp", handler.RequestOTP)
	authGroup.Post("/change-email", handler.ChangeEmail)
}

func (h *AuthHandler) Register(c *fiber.Ctx) error {
	var req domain.RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}

	res, err := h.authUsecase.Register(c.Context(), &req)
	if err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}

	return c.Status(fiber.StatusCreated).JSON(utils.Success("otp sent to email", res))
}

func (h *AuthHandler) VerifyOTP(c *fiber.Ctx) error {
	var req domain.VerifyOTPRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}

	res, err := h.authUsecase.VerifyOTP(c.Context(), &req)
	if err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}

	return c.JSON(utils.Success("otp verified successfully", res))
}

func (h *AuthHandler) Login(c *fiber.Ctx) error {
	var req domain.LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}

	res, err := h.authUsecase.Login(c.Context(), &req)
	if err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error("Invalid email or password"))
	}

	return c.JSON(utils.Success("login successful", res))
}

func (h *AuthHandler) ForgotPassword(c *fiber.Ctx) error {
	var req domain.ForgotPasswordRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}

	res, err := h.authUsecase.ForgotPassword(c.Context(), &req)
	if err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}

	return c.JSON(utils.Success(res, nil))
}

func (h *AuthHandler) ResetPassword(c *fiber.Ctx) error {
	var req domain.ResetPasswordRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}

	err := h.authUsecase.ResetPassword(c.Context(), &req)
	if err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}

	return c.JSON(utils.Success("password reset successfully", nil))
}
func (h *AuthHandler) RequestOTP(c *fiber.Ctx) error {
	var req domain.RequestOTPRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}

	err := h.authUsecase.RequestOTP(c.Context(), req.Email, req.Purpose)
	if err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}

	return c.JSON(utils.Success("otp sent to email", nil))
}

func (h *AuthHandler) ChangeEmail(c *fiber.Ctx) error {
	var req domain.ChangeEmailRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}

	err := h.authUsecase.ChangeEmail(c.Context(), &req)
	if err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}

	return c.JSON(utils.Success("email changed successfully", nil))
}

