package usecase

import (
	"context"
	"pushtaka/services/book/internal/domain"
	"time"
)

type favoriteUsecase struct {
	favoriteRepo   domain.FavoriteRepository
	contextTimeout time.Duration
}

func NewFavoriteUsecase(f domain.FavoriteRepository, timeout time.Duration) domain.FavoriteUsecase {
	return &favoriteUsecase{
		favoriteRepo:   f,
		contextTimeout: timeout,
	}
}

func (u *favoriteUsecase) FetchByUserID(c context.Context, userID uint) ([]domain.Book, error) {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	favorites, err := u.favoriteRepo.FetchByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	books := make([]domain.Book, len(favorites))
	for i, fav := range favorites {
		books[i] = fav.Book
	}

	return books, nil
}

func (u *favoriteUsecase) Store(c context.Context, userID uint, bookID uint) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	favorite := &domain.Favorite{
		UserID: userID,
		BookID: bookID,
	}

	return u.favoriteRepo.Store(ctx, favorite)
}

func (u *favoriteUsecase) Delete(c context.Context, userID uint, bookID uint) error {
	ctx, cancel := context.WithTimeout(c, u.contextTimeout)
	defer cancel()

	return u.favoriteRepo.Delete(ctx, userID, bookID)
}
