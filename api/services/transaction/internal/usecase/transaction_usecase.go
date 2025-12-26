package usecase

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"pushtaka/services/transaction/internal/domain"
	"strconv"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
)

type transactionUsecase struct {
	txRepo         domain.TransactionRepository
	contextTimeout time.Duration
	amqpChannel    *amqp.Channel
}

type StockUpdateMessage struct {
	BookID   uint   `json:"book_id"`
	Action   string `json:"action"` // "borrow" or "return"
	Quantity int    `json:"quantity"`
}

func NewTransactionUsecase(txRepo domain.TransactionRepository, timeout time.Duration, ch *amqp.Channel) domain.TransactionUsecase {
	return &transactionUsecase{
		txRepo:         txRepo,
		contextTimeout: timeout,
		amqpChannel:    ch,
	}
}

func (u *transactionUsecase) BorrowBook(c context.Context, userID uint, bookID uint) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	// 1. Check if user has unpaid fines
	unpaidFines, err := u.txRepo.GetUnpaidFines(ctx, userID)
	if err != nil {
		return err
	}
	if len(unpaidFines) > 0 {
		totalFine := 0
		for _, tx := range unpaidFines {
			totalFine += tx.Fine
		}
		return errors.New("you have unpaid fines, please pay them first")
	}

	// 2. Check if user already borrowed this book
	activeBorrow, _ := u.txRepo.GetActiveBorrow(ctx, userID, bookID)
	if activeBorrow != nil {
		return errors.New("you have already borrowed this book")
	}

	// 3. Check max borrows
	count, err := u.txRepo.CountActiveBorrows(ctx, userID)
	if err != nil {
		return err
	}
	
	limitStr, err := u.txRepo.GetConfig(ctx, "max_borrow_limit")
	limit := 3 // Default
	if err == nil {
		l, _ := strconv.Atoi(limitStr)
		if l > 0 {
			limit = l
		}
	}

	if int(count) >= limit {
		return errors.New("limit reached: max " + strconv.Itoa(limit) + " books borrowed")
	}

	// 4. Calculate Due Date
	durationStr, _ := u.txRepo.GetConfig(ctx, "borrow_duration")
	unit, _ := u.txRepo.GetConfig(ctx, "borrow_duration_unit")
	
	duration := 7 // Default
	if d, err := strconv.Atoi(durationStr); err == nil && d > 0 {
		duration = d
	}
	
	var addTime time.Duration
	switch unit {
	case "minute":
		addTime = time.Duration(duration) * time.Minute
	case "hour":
		addTime = time.Duration(duration) * time.Hour
	case "day":
		addTime = time.Duration(duration) * 24 * time.Hour
	default:
		addTime = time.Duration(duration) * 24 * time.Hour // Default to days
	}
	
	dueDate := time.Now().Add(addTime)

	// 5. Create Transaction
	tx := &domain.Transaction{
		UserID:  userID,
		BookID:  bookID,
		Action:  "borrow",
		Status:  "active",
		DueDate: &dueDate,
	}
	if err := u.txRepo.Create(ctx, tx); err != nil {
		return err
	}

	// 6. Publish Event (Decrease Stock)
	msg := StockUpdateMessage{BookID: bookID, Action: "borrow", Quantity: -1}
	u.publishEvent(msg)

	return nil
}

func (u *transactionUsecase) ReturnBook(c context.Context, userID uint, bookID uint) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	// 1. Get Active Borrow to check Due Date
	activeBorrow, err := u.txRepo.GetActiveBorrow(ctx, userID, bookID)
	if err != nil {
		return errors.New("active borrow record not found")
	}

	// 2. Calculate Fine
	fine := 0
	now := time.Now()
	
	if activeBorrow.DueDate != nil && now.After(*activeBorrow.DueDate) {
		// Get Fine Config
		amountStr, _ := u.txRepo.GetConfig(ctx, "fine_amount")
		unit, _ := u.txRepo.GetConfig(ctx, "fine_unit")
		durationStr, _ := u.txRepo.GetConfig(ctx, "fine_duration")
		
		fineAmount := 1000 // Default
		if f, err := strconv.Atoi(amountStr); err == nil && f > 0 {
			fineAmount = f
		} else {
			// Backward compatibility: try fine_per_day
			if oldFine, err := u.txRepo.GetConfig(ctx, "fine_per_day"); err == nil {
				if f, err := strconv.Atoi(oldFine); err == nil && f > 0 {
					fineAmount = f
				}
			}
		}
		
		fineDuration := 1 // Default
		if d, err := strconv.Atoi(durationStr); err == nil && d > 0 {
			fineDuration = d
		}

		if unit == "" {
			unit = "day" // Default
		}
		
		// Calculate time late
		diff := now.Sub(*activeBorrow.DueDate)
		var totalMinutes float64
		
		switch unit {
		case "minute":
			totalMinutes = diff.Minutes()
		case "hour":
			totalMinutes = diff.Hours() * 60
		case "day":
			totalMinutes = diff.Hours() * 60 * 24
		case "month":
			totalMinutes = diff.Hours() * 60 * 24 * 30
		default:
			totalMinutes = diff.Hours() * 60 * 24
		}
		
		// Convert fine duration to minutes for calculation
		var durationInMinutes int
		switch unit {
		case "minute":
			durationInMinutes = fineDuration
		case "hour":
			durationInMinutes = fineDuration * 60
		case "day":
			durationInMinutes = fineDuration * 60 * 24
		case "month":
			durationInMinutes = fineDuration * 60 * 24 * 30
		default:
			durationInMinutes = fineDuration * 60 * 24
		}

		// Calculate units late (rounding up)
		unitsLate := int(totalMinutes / float64(durationInMinutes))
		if int(totalMinutes) % durationInMinutes > 0 || unitsLate == 0 {
			unitsLate++
		}
		
		fine = unitsLate * fineAmount
	}
	
	// 3. Update borrow status to returned
	activeBorrow.Status = "returned"
	if err := u.txRepo.Update(ctx, activeBorrow); err != nil {
		return err
	}

	// 4. Create Return Transaction
	tx := &domain.Transaction{
		UserID:     userID,
		BookID:     bookID,
		Action:     "return",
		Status:     "completed",
		ReturnDate: &now,
		Fine:       fine,
	}
	if err := u.txRepo.Create(ctx, tx); err != nil {
		return err
	}

	// 5. Publish Event (Increase Stock)
	msg := StockUpdateMessage{BookID: bookID, Action: "return", Quantity: 1}
	u.publishEvent(msg)

	return nil
}

func (u *transactionUsecase) History(c context.Context, userID uint) ([]domain.Transaction, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	return u.txRepo.GetByUserID(ctx, userID)
}

func (u *transactionUsecase) GetAllHistory(c context.Context) ([]domain.Transaction, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	return u.txRepo.GetAll(ctx)
}

func (u *transactionUsecase) PayFine(c context.Context, userID uint, transactionID uint, method string, proof string) (string, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	// 1. Get transaction
	tx, err := u.txRepo.GetByID(ctx, transactionID)
	if err != nil {
		return "", errors.New("transaction not found")
	}

	// 2. Verify ownership
	if tx.UserID != userID {
		return "", errors.New("unauthorized: this transaction does not belong to you")
	}

	// 3. Check if this transaction has a fine
	if tx.Fine <= 0 {
		return "", errors.New("no fine to pay for this transaction")
	}

	// 4. Check if already paid or pending
	if tx.PaidAt != nil {
		return "", errors.New("fine already paid")
	}
	if tx.Status == "pending_verification" {
		return "", errors.New("payment is already pending verification")
	}

	var returnData string

	// 5. Handle Payment Methods
	if method == "qris" {
		// Mock/Dummy Logic
		// Mock/Dummy Logic - Auto Pay
		now := time.Now()
		tx.PaidAt = &now
		tx.Status = "completed"
		tx.UpdatedAt = now
		tx.PaymentMethod = "qris"
		tx.PaymentProof = "auto-paid-dummy"
		returnData = "Payment successful (Dummy Mode)"
	} else if method == "manual" {
		// Mock/Dummy Logic - Auto Pay for Manual as well
		now := time.Now()
		tx.PaidAt = &now
		tx.Status = "completed"
		tx.UpdatedAt = now
		tx.PaymentMethod = "manual"
		if proof != "" {
			tx.PaymentProof = proof
		} else {
			tx.PaymentProof = "auto-paid-dummy-manual"
		}
		returnData = "Payment successful (Dummy Mode - Manual)"
	} else {
		return "", errors.New("invalid payment method (qris/manual)")
	}

	if err := u.txRepo.Update(ctx, tx); err != nil {
		return "", err
	}

	return returnData, nil
}



func (u *transactionUsecase) GetMyFines(c context.Context, userID uint) ([]domain.Transaction, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	return u.txRepo.GetUnpaidFines(ctx, userID)
}

func (u *transactionUsecase) VerifyFine(c context.Context, transactionID uint, action string) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	
	tx, err := u.txRepo.GetByID(ctx, transactionID)
	if err != nil {
		return err
	}
	
	if action == "approve" {
		now := time.Now()
		tx.PaidAt = &now
		tx.Status = "completed"
		tx.UpdatedAt = now
	} else if action == "reject" {
		tx.Status = "completed" // Or back to active? "active" means unpaid in our logic?
		// Logic mismatch: In BorrowBook, we check "UnpaidFines" -> Fine > 0 AND PaidAt IS NULL.
		// So checking status is critical.
		// If rejected, we reset to let user try again?
		tx.Status = "active" // Reset to allow re-payment
		tx.PaymentMethod = ""
		tx.PaymentProof = ""
	} else {
		return errors.New("invalid action")
	}
	
	return u.txRepo.Update(ctx, tx)
}

func (u *transactionUsecase) HandlePaymentCallback(c context.Context, orderID string, status string) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	
	// Assuming orderID is transactionID for simplicity
	id, _ := strconv.Atoi(orderID)
	tx, err := u.txRepo.GetByID(ctx, uint(id))
	if err != nil {
		return err
	}
	
	if status == "settled" || status == "capture" {
		now := time.Now()
		tx.PaidAt = &now
		tx.Status = "completed"
		tx.UpdatedAt = now
		return u.txRepo.Update(ctx, tx)
	}
	
	return nil
}

func (u *transactionUsecase) MakeLate(c context.Context, userID uint, transactionID uint, daysLate int) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	// 1. Get transaction
	tx, err := u.txRepo.GetByID(ctx, transactionID)
	if err != nil {
		return errors.New("transaction not found")
	}

	// 2. Verify ownership
	if tx.UserID != userID {
		return errors.New("unauthorized: this transaction does not belong to you")
	}

	// 3. Check if this is a borrow transaction
	if tx.Action != "borrow" {
		return errors.New("only borrow transactions can be made late")
	}

	// 4. Check if already returned
	if tx.Status == "returned" {
		return errors.New("book already returned")
	}

	// 5. Update due date to past
	if daysLate <= 0 {
		daysLate = 3 // Default 3 days late
	}
	newDueDate := time.Now().Add(-time.Duration(daysLate) * 24 * time.Hour)
	tx.DueDate = &newDueDate

	if err := u.txRepo.Update(ctx, tx); err != nil {
		return err
	}

	return nil
}

func (u *transactionUsecase) publishEvent(msg StockUpdateMessage) {
	body, _ := json.Marshal(msg)
	err := u.amqpChannel.PublishWithContext(context.Background(),
		"",            // exchange
		"stock_updates", // routing key
		false,         // mandatory
		false,         // immediate
		amqp.Publishing{
			ContentType: "application/json",
			Body:        body,
		})
	if err != nil {
		log.Printf("Failed to publish message: %v", err)
	}
}


func (u *transactionUsecase) DeleteByBookID(c context.Context, bookID uint) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	return u.txRepo.DeleteByBookID(ctx, bookID)
}

func (u *transactionUsecase) GetSettings(c context.Context) (*domain.Settings, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()
	
	s := &domain.Settings{
		BorrowDuration:     7,     // Defaults
		BorrowDurationUnit: "day", // Defaults
		FineAmount:         1000,
		FineUnit:           "day",
		FineDuration:       1,
		MaxBorrowLimit:     3,
	}

	if val, err := u.txRepo.GetConfig(ctx, "borrow_duration"); err == nil {
		if i, err := strconv.Atoi(val); err == nil && i > 0 {
			s.BorrowDuration = i
		}
	}
	if val, err := u.txRepo.GetConfig(ctx, "borrow_duration_unit"); err == nil && val != "" {
		s.BorrowDurationUnit = val
	}
	
	if val, err := u.txRepo.GetConfig(ctx, "fine_amount"); err == nil {
		if i, err := strconv.Atoi(val); err == nil && i >= 0 {
			s.FineAmount = i
		}
	} else {
		// Backward compatibility
		if val, err := u.txRepo.GetConfig(ctx, "fine_per_day"); err == nil {
			if i, err := strconv.Atoi(val); err == nil && i >= 0 {
				s.FineAmount = i
			}
		}
	}
	
	if val, err := u.txRepo.GetConfig(ctx, "fine_unit"); err == nil && val != "" {
		s.FineUnit = val
	} else {
		s.FineUnit = "day" // Default
	}

	if val, err := u.txRepo.GetConfig(ctx, "fine_duration"); err == nil {
		if i, err := strconv.Atoi(val); err == nil && i > 0 {
			s.FineDuration = i
		}
	}

	if val, err := u.txRepo.GetConfig(ctx, "max_borrow_limit"); err == nil {
		if i, err := strconv.Atoi(val); err == nil && i > 0 {
			s.MaxBorrowLimit = i
		}
	}

	return s, nil
}

func (u *transactionUsecase) UpdateSettings(c context.Context, s *domain.Settings) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	if s.BorrowDuration > 0 {
		if err := u.txRepo.UpdateConfig(ctx, "borrow_duration", strconv.Itoa(s.BorrowDuration)); err != nil {
			return err
		}
	}
	if s.BorrowDurationUnit != "" {
		if err := u.txRepo.UpdateConfig(ctx, "borrow_duration_unit", s.BorrowDurationUnit); err != nil {
			return err
		}
	}
	if s.FineAmount >= 0 {
		if err := u.txRepo.UpdateConfig(ctx, "fine_amount", strconv.Itoa(s.FineAmount)); err != nil {
			return err
		}
	}
	if s.FineUnit != "" {
		if err := u.txRepo.UpdateConfig(ctx, "fine_unit", s.FineUnit); err != nil {
			return err
		}
	}
	if s.FineDuration > 0 {
		if err := u.txRepo.UpdateConfig(ctx, "fine_duration", strconv.Itoa(s.FineDuration)); err != nil {
			return err
		}
	}
	if s.MaxBorrowLimit > 0 {
		if err := u.txRepo.UpdateConfig(ctx, "max_borrow_limit", strconv.Itoa(s.MaxBorrowLimit)); err != nil {
			return err
		}
	}

	return nil
}
