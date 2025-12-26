import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/error/failures.dart';
import 'package:dio/dio.dart';
import '../../data/models/google_book_model.dart';
import '../../data/models/open_library_model.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/controllers/app_notification_controller.dart';
import '../../../../core/constants/api_constants.dart';

class BookController extends GetxController {
  final BookRepository repository;

  BookController({required this.repository});

  var books = <Book>[].obs;
  var currentBook = Rxn<Book>();
  var isLoading = false.obs;
  var isLoadingDetail = false.obs;
  var errorMessage = ''.obs;

  var isGridView = true.obs;
  var isSearchOpen = false.obs;
  var searchQuery = ''.obs;
  var currentSort = 'year_desc'.obs;
  var currentFilter = 'Semua'.obs;
  var scrollOffset = 0.0.obs;

  var isAdmin = false.obs;
  var isSelectionMode = false.obs;
  var selectedIds = <int>[].obs;
  var favoriteIds = <int>[].obs;
  var isShowFavorites = false.obs;
  var deletingIds = <int>[].obs;
  var isProcessingDelete = false.obs;

  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(() {
      updateScroll(scrollController.offset);
    });

    try {
      final authController = Get.find<AuthController>();

      void onLoginStatusChanged(bool isLoggedIn) {
        isAdmin.value = isLoggedIn && authController.isAdmin.value;
        if (isLoggedIn) {
          loadFavorites();
        } else {
          favoriteIds.clear();
        }
      }

      onLoginStatusChanged(authController.isLoggedIn.value);

      ever(authController.isLoggedIn, (val) => onLoginStatusChanged(val));
      ever(
        authController.isAdmin,
        (_) => onLoginStatusChanged(authController.isLoggedIn.value),
      );
    } catch (e) {
      // Ignore if AuthController not found
    }

    fetchBooks();
  }

  Future<void> loadFavorites() async {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value) return;

    final result = await repository.getFavorites();
    result.fold(
      (failure) => null, // Silent fail for background load
      (data) {
        favoriteIds.value = data.map((e) => e.id).toList();
      },
    );
  }

  Future<void> toggleFavorite(int bookId) async {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value) {
      AppNotificationController.to.showError(
        "Silakan login untuk menambah favorit",
      );
      return;
    }

    final isCurrentlyFavorite = favoriteIds.contains(bookId);

    if (isCurrentlyFavorite) {
      final result = await repository.removeFavorite(bookId);
      result.fold(
        (failure) =>
            AppNotificationController.to.showError("Gagal menghapus favorit"),
        (_) => favoriteIds.remove(bookId),
      );
    } else {
      final result = await repository.addFavorite(bookId);
      result.fold((failure) {
        final msg = failure.message.toLowerCase();
        if (msg.contains("already") ||
            msg.contains("duplicate") ||
            msg.contains("exist")) {
          favoriteIds.add(bookId); // Sync if server says it's already there
        } else {
          AppNotificationController.to.showError(
            "Gagal menambah favorit: ${failure.message}",
          );
        }
      }, (_) => favoriteIds.add(bookId));
    }
  }

  bool isFavorite(int bookId) => favoriteIds.contains(bookId);

  void toggleShowFavorites() {
    isShowFavorites.toggle();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> fetchBooks() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await repository.getBooks();
    result.fold(
      (failure) {
        errorMessage.value = _mapFailureToMessage(failure);
      },
      (data) {
        books.value = data;
      },
    );
    isLoading.value = false;
  }

  Future<void> refreshBooks() async {
    await fetchBooks();
  }

  // Fetch single book by ID for detail page
  Future<void> getBookById(int id) async {
    isLoadingDetail.value = true;
    errorMessage.value = '';

    final result = await repository.getBookDetail(id);
    result.fold(
      (failure) {
        errorMessage.value = _mapFailureToMessage(failure);
        print('Get Book Detail Error: ${_mapFailureToMessage(failure)}');
      },
      (data) {
        currentBook.value = data;
        print('Get Book Detail Success: ${data.title}');
      },
    );
    isLoadingDetail.value = false;
  }

  // Refresh current book detail
  Future<void> refreshCurrentBook() async {
    if (currentBook.value != null) {
      await getBookById(currentBook.value!.id);
    }
  }

  void updateScroll(double offset) {
    scrollOffset.value = offset;
  }

  void toggleView() => isGridView.toggle();
  void toggleSearch() {
    isSearchOpen.toggle();
    if (!isSearchOpen.value) {
      searchQuery.value = ''; // Clear search when closed
    }
  }

  void toggleSelectionMode() {
    isSelectionMode.toggle();
    if (!isSelectionMode.value) {
      selectedIds.clear();
    }
  }

  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void clearSelection() => selectedIds.clear();

  bool _isBookBorrowed(int id) {
    // TODO: Implement actual check against transaction database
    return id == 1;
  }

  Future<void> deleteSelectedBooks() async {
    if (selectedIds.isEmpty) return;

    isProcessingDelete.value = true;
    int successCount = 0;
    int failCount = 0;
    List<String> failedTitles = [];
    List<int> successfulIds = [];

    // Create a copy of the list to avoid concurrent modification issues
    final idsToDelete = List<int>.from(selectedIds);

    for (int id in idsToDelete) {
      // Check if book is borrowed
      if (_isBookBorrowed(id)) {
        failCount++;
        final book = books.firstWhereOrNull((b) => b.id == id);
        if (book != null) {
          failedTitles.add(book.title);
        }
        continue;
      }

      final result = await repository.deleteBook(id);
      result.fold(
        (failure) {
          failCount++;
          // try to find title
          final book = books.firstWhereOrNull((b) => b.id == id);
          if (book != null) {
            failedTitles.add("${book.title} (Error Sistem)");
          }
        },
        (_) {
          successCount++;
          successfulIds.add(id);
        },
      );
    }

    isProcessingDelete.value = false;

    // Start Animation Sequence for successful deletions
    if (successfulIds.isNotEmpty) {
      for (int id in successfulIds) {
        deletingIds.add(id);
        await Future.delayed(const Duration(milliseconds: 100));
      }
      // Wait for the exit animations to finish
      await Future.delayed(const Duration(milliseconds: 400));
      deletingIds.clear();
    }

    if (successCount > 0) {
      String message = "$successCount buku berhasil dihapus.";
      if (failCount > 0) {
        message += "\n$failCount gagal: ${failedTitles.join(', ')}";
        if (failedTitles.any((t) => !t.contains("Error Sistem"))) {
          message += "\n(Buku sedang dipinjam tidak dapat dihapus)";
        }
      }
      AppNotificationController.to.showSuccess(message);

      // Clear selection and refresh only if some were deleted
      toggleSelectionMode();
      fetchBooks();
    } else if (failCount > 0) {
      AppNotificationController.to.showError(
        "Gagal menghapus buku.\n${failedTitles.join(', ')}\n(Mungkin sedang dipinjam)",
      );
    }
  }

  Future<void> deleteBook(int id, {VoidCallback? onSuccess}) async {
    isProcessingDelete.value = true;

    // Check if book is borrowed
    if (_isBookBorrowed(id)) {
      isProcessingDelete.value = false;
      AppNotificationController.to.showError(
        "Buku sedang dipinjam, tidak dapat dihapus.",
      );
      return;
    }

    final result = await repository.deleteBook(id);

    isProcessingDelete.value = false;

    result.fold(
      (failure) {
        AppNotificationController.to.showError(
          "Gagal menghapus buku: ${_mapFailureToMessage(failure)}",
        );
      },
      (_) async {
        deletingIds.add(id);
        await Future.delayed(const Duration(milliseconds: 400));
        deletingIds.clear();
        fetchBooks();
        AppNotificationController.to.showSuccess("Buku berhasil dihapus");
        if (onSuccess != null) onSuccess();
      },
    );
    isLoadingDetail.value = false;
  }

  Future<void> addBook(
    String title,
    String author,
    int year,
    int stock, {
    String isbn = '',
    String publisher = '',
    String description = '',
    String? image,
    VoidCallback? onSuccess, // Callback validation
  }) async {
    isLoading.value = true;

    try {
      final Map<String, dynamic> data = {
        'title': title,
        'author': author,
        'publication_year': year,
        'stock': stock,
        'isbn': isbn,
        'publisher': publisher,
        'description': description,
        if (image != null) 'image': image,
      };

      final result = await repository.addBook(data);

      result.fold(
        (failure) {
          AppNotificationController.to.showError(
            "Gagal menambah buku: ${_mapFailureToMessage(failure)}",
          );
        },
        (_) {
          fetchBooks();
          if (onSuccess != null) onSuccess();
        },
      );
    } catch (e) {
      AppNotificationController.to.showError("Terjadi kesalahan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editBook(
    int id,
    String title,
    String author,
    int year,
    int stock, {
    String? isbn,
    String publisher = '',
    String description = '',
    String? image,
    VoidCallback? onSuccess, // Callback validation
  }) async {
    isLoading.value = true;

    try {
      final Map<String, dynamic> data = {
        'title': title,
        'author': author,
        'publication_year': year,
        'stock': stock,
        'isbn': isbn ?? '',
        'publisher': publisher,
        'description': description,
        if (image != null) 'image': image,
      };

      final result = await repository.updateBook(id, data);

      result.fold(
        (failure) {
          AppNotificationController.to.showError(
            "Gagal mengedit buku: ${_mapFailureToMessage(failure)}",
          );
        },
        (_) {
          fetchBooks();
          if (currentBook.value?.id == id) {
            getBookById(id);
          }
          if (onSuccess != null) onSuccess();
        },
      );
    } catch (e) {
      AppNotificationController.to.showError("Terjadi kesalahan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) {
    searchQuery.value = query;
  }

  void sortBooks(String sortValue) {
    currentSort.value = sortValue;
  }

  void filterBooks(String filterValue) {
    currentFilter.value = filterValue;
  }

  List<Book> get displayedBooks {
    List<Book> filtered =
        searchQuery.isEmpty
            ? List.from(books)
            : books
                .where(
                  (book) =>
                      book.title.toLowerCase().contains(
                        searchQuery.value.toLowerCase(),
                      ) ||
                      book.author.toLowerCase().contains(
                        searchQuery.value.toLowerCase(),
                      ),
                )
                .toList();

    if (isShowFavorites.value) {
      filtered =
          filtered.where((book) => favoriteIds.contains(book.id)).toList();
    }

    if (currentFilter.value == 'Tersedia') {
      filtered = filtered.where((book) => book.stock > 0).toList();
    } else if (currentFilter.value == 'Habis') {
      filtered = filtered.where((book) => book.stock == 0).toList();
    }

    switch (currentSort.value) {
      case 'title_asc':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'title_desc':
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'year_desc': // Newest (by ID desc)
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'year_asc': // Oldest (by ID asc)
        filtered.sort((a, b) => a.id.compareTo(b.id));
        break;
    }

    return filtered;
  }

  Future<List<GoogleBookItem>> searchGoogleBooks(String query) async {
    if (query.isEmpty) return [];

    isLoading.value = true;
    try {
      final dio = Dio();
      final response = await dio.get(
        ApiConstants.googleBooks,
        queryParameters: {'q': query, 'maxResults': 40},
      );

      if (response.statusCode == 200) {
        final data = GoogleBooksResponse.fromJson(response.data);
        return data.items ?? [];
      }
      return [];
    } catch (e) {
      AppNotificationController.to.showError("Gagal mencari buku: $e");
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<OpenLibraryDoc>> searchOpenLibrary(String query) async {
    if (query.isEmpty) return [];

    isLoading.value = true;
    try {
      final dio = Dio();
      final response = await dio.get(
        ApiConstants.openLibrary,
        queryParameters: {'q': query, 'limit': 20},
      );

      if (response.statusCode == 200) {
        final data = OpenLibraryResponse.fromJson(response.data);
        return data.docs ?? [];
      }
      return [];
    } catch (e) {
      AppNotificationController.to.showError(
        "Gagal mencari buku di Open Library: $e",
      );
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message.isNotEmpty
            ? "Server Error: ${failure.message}"
            : 'Server Error: Please try again later.';
      case CacheFailure:
        return 'Cache Error: Data could not be loaded from cache.';
      default:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Unexpected Error';
    }
  }
}
