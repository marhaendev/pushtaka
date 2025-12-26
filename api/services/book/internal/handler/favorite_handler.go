package handler

import (
	"pushtaka/pkg/middleware"
	"pushtaka/pkg/utils"
	"pushtaka/services/book/internal/domain"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

type FavoriteHandler struct {
	favoriteUsecase domain.FavoriteUsecase
}

func NewFavoriteHandler(app *fiber.App, favoriteUsecase domain.FavoriteUsecase) {
	handler := &FavoriteHandler{
		favoriteUsecase: favoriteUsecase,
	}

	mw := middleware.NewRoleMiddleware()
	auth := mw.RequireAuth()

	app.Get("/favorites", auth, handler.FetchByUserID)
	app.Post("/favorites/:book_id", auth, handler.Store)
	app.Delete("/favorites/:book_id", auth, handler.Delete)
}

func (h *FavoriteHandler) FetchByUserID(c *fiber.Ctx) error {
	userID, ok := c.Locals("user_id").(float64)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(utils.Error("invalid user id"))
	}

	books, err := h.favoriteUsecase.FetchByUserID(c.Context(), uint(userID))
	if err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}
	return c.JSON(utils.Success("favorites retrieved", books))
}

type StoreFavoriteRequest struct {
	BookID uint `json:"book_id"`
}

func (h *FavoriteHandler) Store(c *fiber.Ctx) error {
	bookID, err := strconv.Atoi(c.Params("book_id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid book id"))
	}

	userID, ok := c.Locals("user_id").(float64)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(utils.Error("invalid user id"))
	}

	if err := h.favoriteUsecase.Store(c.Context(), uint(userID), uint(bookID)); err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}
	return c.Status(fiber.StatusCreated).JSON(utils.Success("book added to favorites", nil))
}

func (h *FavoriteHandler) Delete(c *fiber.Ctx) error {
	bookID, err := strconv.Atoi(c.Params("book_id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid book id"))
	}

	userID, ok := c.Locals("user_id").(float64)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(utils.Error("invalid user id"))
	}

	if err := h.favoriteUsecase.Delete(c.Context(), uint(userID), uint(bookID)); err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}
	return c.Status(fiber.StatusOK).JSON(utils.Success("book removed from favorites", nil))
}
