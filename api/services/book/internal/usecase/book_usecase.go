package usecase

import (
	"context"
	"fmt"
	"pushtaka/services/book/internal/domain"
	"regexp"
	"strings"
	"time"
)

type bookUsecase struct {
	bookRepo       domain.BookRepository
	publisher      domain.BookPublisher
	contextTimeout time.Duration
}

func NewBookUsecase(bookRepo domain.BookRepository, publisher domain.BookPublisher, timeout time.Duration) domain.BookUsecase {
	return &bookUsecase{
		bookRepo:       bookRepo,
		publisher:      publisher,
		contextTimeout: timeout,
	}
}

func (a *bookUsecase) Fetch(c context.Context) ([]domain.Book, error) {
	ctx, cancel := context.WithTimeout(c, a.contextTimeout)
	defer cancel()
	return a.bookRepo.Fetch(ctx)
}

func (a *bookUsecase) GetByID(c context.Context, id uint) (*domain.Book, error) {
	ctx, cancel := context.WithTimeout(c, a.contextTimeout)
	defer cancel()
	return a.bookRepo.GetByID(ctx, id)
}

func (a *bookUsecase) Store(c context.Context, book *domain.Book) error {
	ctx, cancel := context.WithTimeout(c, a.contextTimeout)
	defer cancel()

	if book.Slug == "" {
		book.Slug = generateSlug(book.Title)
	}

	book.Slug = a.ensureUniqueSlug(ctx, book.Slug, 0)

	if book.Code == "" {
		// Generate simple unique code: BK-<FormattedTimeMilli>
		// or BK-<Random>. Let's use Timestamp for simplicity and ordering.
		book.Code = fmt.Sprintf("BK-%d", time.Now().UnixNano())
	}

	return a.bookRepo.Store(ctx, book)
}

func (a *bookUsecase) Update(c context.Context, book *domain.Book) error {
	ctx, cancel := context.WithTimeout(c, a.contextTimeout)
	defer cancel()

	// If slug is provided, it updates. If empty, we could either keep old or regen.
	// For now, let's regen if it's explicitly empty but title is there (though usually update sends partial data in other architectures, here struct is full).
	// Assuming Handler sends what it got. If slug is empty string, we might want to regenerate.
	// Assuming Handler sends what it got. If slug is empty string, we might want to regenerate.
	if book.Slug == "" && book.Title != "" {
		book.Slug = generateSlug(book.Title)
	}

    // Only ensure unique if slug is being changed or set. 
    // Optimization: If ID matches existing record with same slug, we don't need to suffix it.
    // simpler: Let's just always ensure unique. If it finds ITSELF, it might suffix itself? 
    // Problem: If I update "Harry Potter" and slug is "harry-potter", ensureUniqueSlug will find "harry-potter" (itself) and make it "harry-potter-1".
    // Fix: ensureUniqueSlug needs to ignore current ID.
    // Updated Plan: Pass ID to ensureUniqueSlug (0 for create).

	book.Slug = a.ensureUniqueSlug(ctx, book.Slug, book.ID)

	return a.bookRepo.Update(ctx, book)
}

func generateSlug(title string) string {
	// Lowercase
	slug := strings.ToLower(title)
	// Replace spaces with -
	slug = strings.ReplaceAll(slug, " ", "-")
	// Remove non-alphanumeric (simple regex, can be improved)
	reg, _ := regexp.Compile("[^a-z0-9-]+")
	slug = reg.ReplaceAllString(slug, "")
	// Trim dashes
	slug = strings.Trim(slug, "-")
	return slug
}

func (a *bookUsecase) ensureUniqueSlug(ctx context.Context, slug string, excludeID uint) string {
	originalSlug := slug
	suffix := 1

	for {
		existing, err := a.bookRepo.GetBySlug(ctx, slug)
		
		if err != nil {
			// Not found (or error), assume safe to use
			break
		}
		
		// Found! Check if it is the same record
		if excludeID != 0 && existing.ID == excludeID {
			break
		}
		
		slug = fmt.Sprintf("%s-%d", originalSlug, suffix)
		suffix++
	}
	return slug
}

func (a *bookUsecase) Delete(c context.Context, id uint) error {
	ctx, cancel := context.WithTimeout(c, a.contextTimeout)
	defer cancel()
	err := a.bookRepo.Delete(ctx, id)
	if err == nil {
		// Publish event
		if pubErr := a.publisher.PublishBookDeleted(id); pubErr != nil {
			// Log error but don't fail the request as the action itself succeeded
			fmt.Printf("Failed to publish book deleted event: %v\n", pubErr)
		}
	}
	return err
}

func (a *bookUsecase) DeleteBatch(c context.Context, ids []uint) error {
	ctx, cancel := context.WithTimeout(c, a.contextTimeout)
	defer cancel()
	return a.bookRepo.DeleteBatch(ctx, ids)
}
