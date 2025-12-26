package handler

import (
	"os"
	"pushtaka/pkg/auth"
	"pushtaka/pkg/utils"
	"pushtaka/services/transaction/internal/domain"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

type TransactionHandler struct {
	txUsecase domain.TransactionUsecase
}

func NewTransactionHandler(app *fiber.App, txUsecase domain.TransactionUsecase) {
	handler := &TransactionHandler{
		txUsecase: txUsecase,
	}

	// Public Routes (Webhooks)
	app.Post("/transactions/callback", handler.CallbackFine)

	// Protected Routes
	app.Use(auth.Middleware(os.Getenv("JWT_SECRET")))
	app.Post("/transactions/borrow/:id", handler.Borrow)
	app.Post("/transactions/return/:id", handler.Return)
	// app.Post("/transactions/pay-fine/:id", handler.PayFine) // Override below
	app.Get("/transactions/history", handler.History)
	app.Get("/transactions", handler.GetAllTransactions)
	
	// Settings
	app.Get("/transactions/settings", handler.GetSettings)
	app.Post("/transactions/settings", handler.UpdateSettings)

	// Fine Management
	app.Get("/transactions/fines", handler.GetMyFines)
	app.Post("/transactions/pay-fine/:id", handler.PayFine)
	app.Post("/transactions/verify/:id", handler.VerifyFine)
	// app.Post("/transactions/callback", handler.CallbackFine) // Moved up

	// Test/Debug helpers
	app.Post("/transactions/test/make-late/:id", handler.MakeLate)
}

func (h *TransactionHandler) GetSettings(c *fiber.Ctx) error {
	settings, err := h.txUsecase.GetSettings(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}
	return c.JSON(utils.Success("settings retrieved", settings))
}

func (h *TransactionHandler) UpdateSettings(c *fiber.Ctx) error {
	role := auth.GetUserRole(c)
	if role != "admin" {
		return c.Status(fiber.StatusForbidden).JSON(utils.Error("access denied: admins only"))
	}

	var settings domain.Settings
	if err := c.BodyParser(&settings); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid request body"))
	}

	if err := h.txUsecase.UpdateSettings(c.Context(), &settings); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}

	return c.JSON(utils.Success("settings updated successfully", nil))
}

func (h *TransactionHandler) Borrow(c *fiber.Ctx) error {
	param := c.Params("id")
	bookID, err := strconv.Atoi(param)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid book id"))
	}
	userID := auth.GetUserID(c)

	if err := h.txUsecase.BorrowBook(c.Context(), userID, uint(bookID)); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}

	return c.JSON(utils.Success("book borrowed successfully", nil))
}

func (h *TransactionHandler) Return(c *fiber.Ctx) error {
	param := c.Params("id")
	bookID, err := strconv.Atoi(param)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid book id"))
	}
	userID := auth.GetUserID(c)

	if err := h.txUsecase.ReturnBook(c.Context(), userID, uint(bookID)); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}

	return c.JSON(utils.Success("book returned successfully", nil))
}

func (h *TransactionHandler) History(c *fiber.Ctx) error {
	userID := auth.GetUserID(c)
	history, err := h.txUsecase.History(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}
	return c.JSON(utils.Success("transaction history retrieved", history))
}

func (h *TransactionHandler) GetAllTransactions(c *fiber.Ctx) error {
	role := auth.GetUserRole(c)
	if role != "admin" {
		return c.Status(fiber.StatusForbidden).JSON(utils.Error("access denied: admins only"))
	}

	history, err := h.txUsecase.GetAllHistory(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}
	return c.JSON(utils.Success("all transactions retrieved", history))
}



func (h *TransactionHandler) GetMyFines(c *fiber.Ctx) error {
	userID := auth.GetUserID(c)
	fines, err := h.txUsecase.GetMyFines(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}
	return c.JSON(utils.Success("unpaid fines retrieved", fines))
}

type PayFineRequest struct {
	Method string `json:"method"` // "qris" or "manual"
	Proof  string `json:"proof"`  // optional
}

func (h *TransactionHandler) PayFine(c *fiber.Ctx) error {
	param := c.Params("id")
	transactionID, err := strconv.Atoi(param)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid transaction id"))
	}
	userID := auth.GetUserID(c)

	var req PayFineRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid request body"))
	}

	respString, err := h.txUsecase.PayFine(c.Context(), userID, uint(transactionID), req.Method, req.Proof)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}

	data := map[string]string{}
	if req.Method == "qris" {
		data["qr_string"] = respString
		data["message"] = "Scan this QR code to pay"
	} else {
		data["message"] = respString
	}

	return c.JSON(utils.Success("payment initiated", data))
}

type VerifyFineRequest struct {
	Action string `json:"action"` // "approve" or "reject"
}

func (h *TransactionHandler) VerifyFine(c *fiber.Ctx) error {
	role := auth.GetUserRole(c)
	if role != "admin" {
		return c.Status(fiber.StatusForbidden).JSON(utils.Error("access denied: admins only"))
	}

	param := c.Params("id")
	transactionID, err := strconv.Atoi(param)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid transaction id"))
	}

	var req VerifyFineRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid request body"))
	}

	if err := h.txUsecase.VerifyFine(c.Context(), uint(transactionID), req.Action); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}

	return c.JSON(utils.Success("fine verification processed", nil))
}

type CallbackRequest struct {
	OrderID           string `json:"order_id"`
	TransactionStatus string `json:"transaction_status"`
}

func (h *TransactionHandler) CallbackFine(c *fiber.Ctx) error {
	// Webhook usually doesn't have User Token, so we skip auth? or auth is disabled for this route?
	// In NewTransactionHandler, auth middleware is applied globally!
	// We need to exclude this route from auth middleware or move it before middleware.
	// Limitation of current structure: Middleware applied to "app".
	// Fix: create a separate group or check token only if present?
	// For simplicity in this refactor: user must be logged in? No, webhook comes from Midtrans.
	// Since we defined middleware globally in NewTransactionHandler, we have a problem.
	// But let's assume valid Midtrans callback for now.
	// Wait, if Middleware is global, Midtrans request will fail 401.
	// I need to Fix this.
	// Solution: Use Route Groups.
	
	// For now, let's implement validation inside usecase, but handler will error 401.
	// I should refactor NewTransactionHandler to use groups.
	
	var req CallbackRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid request body"))
	}

	if err := h.txUsecase.HandlePaymentCallback(c.Context(), req.OrderID, req.TransactionStatus); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(utils.Error(err.Error()))
	}

	return c.JSON(utils.Success("callback received", nil))
}

func (h *TransactionHandler) MakeLate(c *fiber.Ctx) error {
	param := c.Params("id")
	transactionID, err := strconv.Atoi(param)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error("invalid transaction id"))
	}
	userID := auth.GetUserID(c)

	// Optional: get days from query param, default to 3
	daysLate := 3
	if daysStr := c.Query("days"); daysStr != "" {
		if d, err := strconv.Atoi(daysStr); err == nil && d > 0 {
			daysLate = d
		}
	}

	if err := h.txUsecase.MakeLate(c.Context(), userID, uint(transactionID), daysLate); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(utils.Error(err.Error()))
	}

	return c.JSON(utils.Success("transaction marked as late for testing", nil))
}


