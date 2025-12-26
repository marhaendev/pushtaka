package handler

import (
	"pushtaka/pkg/utils"
	"pushtaka/services/identity/internal/domain"

	"github.com/gofiber/fiber/v2"
)

type UserHandler struct {
	userUsecase domain.UserUsecase
}

func NewUserHandler(app *fiber.App, userUsecase domain.UserUsecase, adminMiddleware fiber.Handler, authMiddleware fiber.Handler) {
	handler := &UserHandler{
		userUsecase: userUsecase,
	}

	// Profile Routes (Any authenticated user)
	profile := app.Group("/profile")
	profile.Use(authMiddleware)
	profile.Get("", handler.GetProfile)
	profile.Put("", handler.UpdateProfile)

	// Admin User Management Routes
	api := app.Group("/users")
	api.Use(adminMiddleware) // Apply admin middleware

	api.Get("/", handler.ListUsers)
	api.Get("/:id", handler.GetUser)
	api.Post("/", handler.CreateUser)
	api.Put("/:id", handler.UpdateUser)
	api.Delete("/:id", handler.DeleteUser)
	api.Delete("/", handler.DeleteUsers)
}

func (h *UserHandler) GetProfile(c *fiber.Ctx) error {
	// Got from RequireAuth/RequireRole locals
	claimID := c.Locals("user_id")
	if claimID == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(utils.Error("Unauthorized"))
	}
	
	// Convert float64 (JWT default number type) to uint
	id := uint(claimID.(float64))

	user, err := h.userUsecase.GetProfile(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}

	return c.Status(fiber.StatusOK).JSON(utils.Success("profile retrieved successfully", user))
}

func (h *UserHandler) UpdateProfile(c *fiber.Ctx) error {
	claimID := c.Locals("user_id")
	if claimID == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(utils.Error("Unauthorized"))
	}
	id := uint(claimID.(float64))

	var req domain.UpdateProfileRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("Invalid request payload"))
	}

	if err := h.userUsecase.UpdateProfile(c.Context(), id, &req); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}

	return c.Status(fiber.StatusOK).JSON(utils.Success("profile updated successfully", nil))
}

func (h *UserHandler) UpdateUser(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("Invalid user ID"))
	}

	var req domain.UpdateUserRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("Invalid request payload"))
	}

	if err := h.userUsecase.UpdateUser(c.Context(), uint(id), &req); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}

	return c.Status(fiber.StatusOK).JSON(utils.Success("user updated successfully", nil))
}

func (h *UserHandler) ListUsers(c *fiber.Ctx) error {
	limit := c.QueryInt("limit", 10)
	offset := c.QueryInt("offset", 0)

	users, err := h.userUsecase.GetAllUsers(c.Context(), limit, offset)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}

	return c.Status(fiber.StatusOK).JSON(utils.Success("users retrieved successfully", fiber.Map{
		"users":  users,
		"limit":  limit,
		"offset": offset,
	}))
}

func (h *UserHandler) GetUser(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("Invalid user ID"))
	}

	user, err := h.userUsecase.GetUserByID(c.Context(), uint(id))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}

	return c.Status(fiber.StatusOK).JSON(utils.Success("user retrieved successfully", user))
}

func (h *UserHandler) CreateUser(c *fiber.Ctx) error {
	var req domain.RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("Invalid request payload"))
	}

	if err := h.userUsecase.CreateUser(c.Context(), &req); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}

	return c.Status(fiber.StatusCreated).JSON(utils.Success("user created successfully", nil))
}

func (h *UserHandler) DeleteUser(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("Invalid user ID"))
	}

	if err := h.userUsecase.DeleteUser(c.Context(), uint(id), c.QueryBool("permanent")); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}

	return c.Status(fiber.StatusOK).JSON(utils.Success("user deleted successfully", nil))
}

type BatchDeleteRequest struct {
	IDs []uint `json:"ids"`
}

func (h *UserHandler) DeleteUsers(c *fiber.Ctx) error {
	var req BatchDeleteRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("Invalid request payload"))
	}

	if len(req.IDs) == 0 {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("No user IDs provided"))
	}

	if err := h.userUsecase.DeleteUsers(c.Context(), req.IDs, c.QueryBool("permanent")); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}

	return c.Status(fiber.StatusOK).JSON(utils.Success("users deleted successfully", nil))
}
