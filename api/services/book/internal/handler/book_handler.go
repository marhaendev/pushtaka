package handler

import (
	"pushtaka/pkg/middleware"
	"pushtaka/pkg/utils"
	"pushtaka/services/book/internal/domain"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

type BookHandler struct {
	bookUsecase domain.BookUsecase
}

func NewBookHandler(app *fiber.App, bookUsecase domain.BookUsecase) {
	handler := &BookHandler{
		bookUsecase: bookUsecase,
	}

	mw := middleware.NewRoleMiddleware()
	adminOnly := mw.RequireRole("admin")

	app.Get("/books", handler.Fetch)
	app.Get("/books/:id", handler.GetByID)
	app.Post("/books", adminOnly, handler.Store)
	app.Put("/books/:id", adminOnly, handler.Update)
	app.Delete("/books/:id", adminOnly, handler.Delete)
	app.Delete("/books", adminOnly, handler.DeleteBatch)
}

func (h *BookHandler) Fetch(c *fiber.Ctx) error {
	books, err := h.bookUsecase.Fetch(c.Context())
	if err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}
	return c.JSON(utils.Success("book list retrieved", books))
}

func (h *BookHandler) GetByID(c *fiber.Ctx) error {
	id, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid id"))
	}
	book, err := h.bookUsecase.GetByID(c.Context(), uint(id))
	if err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}
	return c.JSON(utils.Success("book retrieved successfully", book))
}

func (h *BookHandler) Store(c *fiber.Ctx) error {
	var book domain.Book
	if err := c.BodyParser(&book); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(utils.ParseError(err)))
	}
	if err := h.bookUsecase.Store(c.Context(), &book); err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}
	return c.Status(fiber.StatusCreated).JSON(utils.Success("book created successfully", book))
}

func (h *BookHandler) Update(c *fiber.Ctx) error {
	id, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid id"))
	}
	var book domain.Book
	if err := c.BodyParser(&book); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(utils.ParseError(err)))
	}
	book.ID = uint(id)
	if err := h.bookUsecase.Update(c.Context(), &book); err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}
	return c.JSON(utils.Success("book updated successfully", book))
}

func (h *BookHandler) Delete(c *fiber.Ctx) error {
	id, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid id"))
	}
	if err := h.bookUsecase.Delete(c.Context(), uint(id)); err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}
	return c.Status(fiber.StatusOK).JSON(utils.Success("book deleted successfully", nil))
}

type BatchDeleteRequest struct {
	IDs []uint `json:"ids"`
}

func (h *BookHandler) DeleteBatch(c *fiber.Ctx) error {
	var req BatchDeleteRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid request payload"))
	}

	if len(req.IDs) == 0 {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("no book ids provided"))
	}

	if err := h.bookUsecase.DeleteBatch(c.Context(), req.IDs); err != nil {
		return c.Status(utils.GetStatusCode(err)).JSON(utils.Error(utils.ParseError(err)))
	}

	return c.Status(fiber.StatusOK).JSON(utils.Success("books deleted successfully", nil))
}
