import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/routes/app_pages.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../book/domain/entities/book.dart';
import '../../domain/entities/transaction.dart';
import '../../data/models/transaction_settings_model.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/controllers/app_notification_controller.dart';

class TransactionController extends GetxController {
  final TransactionRepository repository;

  TransactionController({required this.repository});

  var history = <Transaction>[].obs;
  var isLoading = false.obs;
  var isSettingsLoading = false.obs;
  var settings = Rxn<TransactionSettingsModel>();

  // Search and filter state
  var searchQuery = ''.obs;
  var isSearchOpen = false.obs;

  // UI State
  var isGridView = false.obs;
  var scrollOffset = 0.0.obs;
  var selectedStatus = 'Semua'.obs;
  var selectedSort = 'Terbaru'.obs;

  late ScrollController scrollController;
  late TextEditingController searchTextController;
  late FocusNode searchFocusNode;

  // Login redirect notification state
  var showLoginNotif = false.obs;
  var loginRedirectCountdown = 5.obs;
  Timer? _redirectTimer;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    searchTextController = TextEditingController();
    searchFocusNode = FocusNode();

    if (Get.arguments != null && Get.arguments is String) {
      final query = Get.arguments as String;
      if (query.isNotEmpty) {
        searchQuery.value = query;
        searchTextController.text = query;
        isSearchOpen.value = true;
      }
    }

    try {
      final authController = Get.find<AuthController>();

      if (authController.isLoggedIn.value) {
        fetchHistory();
        fetchSettings();
      }

      ever(authController.isLoggedIn, (loggedIn) {
        if (loggedIn) {
          fetchHistory();
          fetchSettings();
        } else {
          history.clear();
          settings.value = null;
        }
      });
    } catch (e) {
      debugPrint("Auth Controller not found yet");
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchTextController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void updateScroll(double offset) {
    scrollOffset.value = offset;
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
  }

  void toggleSearch() {
    isSearchOpen.toggle();
    if (!isSearchOpen.value) {
      searchQuery.value = '';
      searchTextController.clear();
      searchFocusNode.unfocus();
    } else {
      _requestSearchFocus();
    }
  }

  void openSearch(String query, {bool requestFocus = false}) {
    if (query.isEmpty) return;

    isSearchOpen.value = true;
    searchQuery.value = query;
    searchTextController.text = query;

    if (requestFocus) {
      _requestSearchFocus();
    } else {
      searchFocusNode.unfocus();
    }
  }

  void _requestSearchFocus() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isSearchOpen.value) {
        searchFocusNode.requestFocus();
      }
    });
  }

  void search(String query) {
    searchQuery.value = query;
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
  }

  void setSortOption(String sort) {
    selectedSort.value = sort;
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  bool get isAdmin {
    try {
      final authController = Get.find<AuthController>();
      return authController.isAdmin.value;
    } catch (_) {
      return false;
    }
  }

  String get currentUserId {
    try {
      final authController = Get.find<AuthController>();
      return authController.userId.value;
    } catch (_) {
      return '';
    }
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;

    final result =
        isAdmin
            ? await repository.getAllTransactions()
            : await repository.getHistory();

    result.fold(
      (failure) {
        debugPrint('Error fetching history: $failure');
        AppNotificationController.to.showError(failure.message);
        history.assignAll([]);
      },
      (data) {
        history.assignAll(data);
      },
    );
    isLoading.value = false;
  }

  Future<void> refreshHistory() async {
    await fetchHistory();
  }

  int get activeBorrowCount {
    final auth = Get.find<AuthController>();
    final currentUserId = auth.userId.value;
    if (currentUserId.isEmpty) return 0;

    return history.where((tx) {
      return tx.status == 'active' && tx.userId.toString() == currentUserId;
    }).length;
  }

  int get maxBorrowLimit => settings.value?.maxBorrowLimit ?? 3;

  bool get hasLateBooks {
    final auth = Get.find<AuthController>();
    final currentUserId = auth.userId.value;
    if (currentUserId.isEmpty) return false;

    return history.any((tx) {
      return tx.status == 'active' &&
          tx.userId.toString() == currentUserId &&
          tx.dueDate != null &&
          tx.dueDate!.isBefore(DateTime.now());
    });
  }

  bool get hasUnpaidFines {
    final auth = Get.find<AuthController>();
    final currentUserId = auth.userId.value;
    if (currentUserId.isEmpty) return false;

    return history.any((tx) {
      if (tx.userId.toString() != currentUserId) return false;
      if (tx.paidAt != null) return false;
      return calculateEstimatedFine(tx) > 0;
    });
  }

  List<Transaction> get processedHistory {
    // 1. Sort by newest first to pair logically (Return before Borrow in time)
    List<Transaction> sorted = List.from(history);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    List<Transaction> mergedList = [];
    Map<int, List<Transaction>> returnsQueue = {};

    for (var tx in sorted) {
      final action = tx.action.toLowerCase();

      if (action == 'return' ||
          action == 'kembali' ||
          action == 'pengembalian') {
        if (!returnsQueue.containsKey(tx.bookId)) {
          returnsQueue[tx.bookId] = [];
        }
        returnsQueue[tx.bookId]!.add(tx);
      } else if (action == 'borrow' ||
          action == 'pinjam' ||
          action == 'peminjaman') {
        if (returnsQueue.containsKey(tx.bookId) &&
            returnsQueue[tx.bookId]!.isNotEmpty) {
          final returnTx = returnsQueue[tx.bookId]!.removeAt(0);

          mergedList.add(
            Transaction(
              id: returnTx.id,
              bookId: tx.bookId,
              userId: tx.userId,
              action: tx.action,
              status: returnTx.status,
              dueDate: tx.dueDate,
              returnDate: returnTx.createdAt,
              fine: returnTx.fine,
              paidAt: returnTx.paidAt,
              paymentMethod: returnTx.paymentMethod,
              createdAt: tx.createdAt,
              bookTitle: tx.bookTitle,
              author: tx.author,
              image: tx.image,
              userName: tx.userName,
              userEmail: tx.userEmail,
            ),
          );
        } else {
          mergedList.add(tx);
        }
      } else {
        mergedList.add(tx);
      }
    }
    return mergedList;
  }

  List<Transaction> get searchFilteredHistory {
    List<Transaction> filtered = List<Transaction>.from(processedHistory);
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (tx) =>
                    (tx.bookTitle ?? '').toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ||
                    (tx.author ?? '').toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ),
              )
              .toList();
    }
    return filtered;
  }

  int get countSemua => searchFilteredHistory.length;
  int get countDipinjam =>
      searchFilteredHistory.where((tx) => tx.status == 'active').length;
  int get countDikembalikan =>
      searchFilteredHistory
          .where((tx) => tx.status == 'returned' || tx.status == 'completed')
          .length;
  int get countTerlambat =>
      searchFilteredHistory
          .where(
            (tx) =>
                tx.status == 'active' &&
                tx.dueDate != null &&
                tx.dueDate!.isBefore(DateTime.now()),
          )
          .length;
  int get countDenda =>
      searchFilteredHistory
          .where((tx) => calculateEstimatedFine(tx) > 0 && tx.paidAt == null)
          .length;

  List<Transaction> get displayedTransactions {
    List<Transaction> filtered = List<Transaction>.from(searchFilteredHistory);
    if (selectedStatus.value != 'Semua') {
      if (selectedStatus.value == 'Dipinjam') {
        filtered = filtered.where((tx) => tx.status == 'active').toList();
      } else if (selectedStatus.value == 'Dikembalikan') {
        filtered =
            filtered
                .where(
                  (tx) => tx.status == 'returned' || tx.status == 'completed',
                )
                .toList();
      } else if (selectedStatus.value == 'Terlambat') {
        filtered =
            filtered
                .where(
                  (tx) =>
                      tx.status == 'active' &&
                      tx.dueDate != null &&
                      tx.dueDate!.isBefore(DateTime.now()),
                )
                .toList();
      } else if (selectedStatus.value == 'Denda') {
        filtered =
            filtered
                .where(
                  (tx) => calculateEstimatedFine(tx) > 0 && tx.paidAt == null,
                )
                .toList();
      }
    }

    List<Transaction> sorted = List.from(filtered);
    if (selectedSort.value == 'Terbaru') {
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (selectedSort.value == 'Terlama') {
      sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (selectedSort.value == 'Judul (A-Z)') {
      sorted.sort(
        (a, b) => (a.bookTitle ?? '').toLowerCase().compareTo(
          (b.bookTitle ?? '').toLowerCase(),
        ),
      );
    } else if (selectedSort.value == 'Judul (Z-A)') {
      sorted.sort(
        (a, b) => (b.bookTitle ?? '').toLowerCase().compareTo(
          (a.bookTitle ?? '').toLowerCase(),
        ),
      );
    }

    return sorted;
  }

  String _getFriendlyErrorMessage(String apiError) {
    final errorLower = apiError.toLowerCase();

    if (errorLower.contains('limit reached') ||
        errorLower.contains('max') ||
        errorLower.contains('limit')) {
      return 'Anda sudah meminjam $maxBorrowLimit buku. Kembalikan salah satu untuk meminjam buku lain.';
    } else if (errorLower.contains('already borrowed')) {
      return 'Anda sudah meminjam buku ini sebelumnya.';
    } else if (errorLower.contains('not found') ||
        errorLower.contains('active borrow record not found')) {
      return 'Buku ini belum dipinjam atau sudah dikembalikan.';
    } else if (errorLower.contains('stock')) {
      return 'Stok buku habis. Silakan coba lagi nanti.';
    } else if (errorLower.contains('unauthorized') ||
        errorLower.contains('login')) {
      return 'Silakan login terlebih dahulu.';
    } else if (errorLower.contains('unpaid fines') ||
        errorLower.contains('fine')) {
      return 'Anda memiliki denda yang belum dibayar. Harap lunasi denda Anda terlebih dahulu.';
    } else {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  Future<bool> borrowBook(
    int bookId, {
    Book? book,
    bool silentSuccess = false,
  }) async {
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final now = DateTime.now();
    DateTime? calcDueDate;
    final s = settings.value;
    if (s != null) {
      if (s.borrowDurationUnit == 'minute') {
        calcDueDate = now.add(Duration(minutes: s.borrowDuration));
      } else if (s.borrowDurationUnit == 'hour') {
        calcDueDate = now.add(Duration(hours: s.borrowDuration));
      } else {
        calcDueDate = now.add(Duration(days: s.borrowDuration));
      }
    }

    final tempTx = Transaction(
      id: tempId,
      bookId: bookId,
      userId: 0, // Placeholder
      action: 'borrow',
      status: 'active',
      createdAt: now,
      dueDate: calcDueDate,
      bookTitle: book?.title ?? 'Loading...',
      author: book?.author ?? '',
      image: book?.image,
      fine: 0,
    );

    history.insert(0, tempTx);

    final result = await repository.borrowBook(bookId);

    return result.fold(
      (l) {
        // Revert on failure
        history.removeWhere((tx) => tx.id == tempId);

        AppNotificationController.to.showError(
          _getFriendlyErrorMessage(l.message),
        );
        debugPrint('Borrow Error: ${l.message}');
        return false;
      },
      (r) async {
        if (!silentSuccess) {
          AppNotificationController.to.showSuccess("Buku berhasil dipinjam");
        }
        await fetchHistory();
        return true;
      },
    );
  }

  Future<void> returnBook(int bookId, {int? userId}) async {
    // Optimistic Update
    // Find active transaction for this book
    final existingIndex = history.indexWhere(
      (tx) =>
          tx.bookId == bookId &&
          tx.status == 'active' &&
          (userId == null || tx.userId == userId),
    );

    Transaction? activeTx;
    Transaction? tempReturnTx;

    if (existingIndex != -1) {
      activeTx = history[existingIndex];
      tempReturnTx = Transaction(
        id: -DateTime.now().millisecondsSinceEpoch,
        bookId: bookId,
        userId: activeTx.userId,
        action: 'return',
        status: 'returned',
        createdAt: DateTime.now(),
        bookTitle: activeTx.bookTitle,
        author: activeTx.author,
        image: activeTx.image,
        fine: 0,
      );

      // Add return record to top (newest)
      history.insert(0, tempReturnTx);
    }

    // Call API
    final result = await repository.returnBook(bookId, userId: userId);

    result.fold(
      (l) {
        // Revert on failure
        if (tempReturnTx != null) {
          history.remove(tempReturnTx);
        }

        AppNotificationController.to.showError(
          _getFriendlyErrorMessage(l.message),
        );
        print('Return Error: ${l.message}');
      },
      (r) async {
        AppNotificationController.to.showSuccess("Buku berhasil dikembalikan");
        print('Return Success - Refreshing history silently...');
        await fetchHistory();
      },
    );
  }

  Future<Map<String, dynamic>?> payFine(
    int transactionId, {
    required String method,
    String? proof,
  }) async {
    isLoading.value = true;
    final result = await repository.payFine(
      transactionId,
      method: method,
      proof: proof,
    );

    Map<String, dynamic>? paymentData;
    result.fold(
      (l) {
        AppNotificationController.to.showError(l.message);
      },
      (r) {
        paymentData = r;
        if (method == 'manual') {
          AppNotificationController.to.showSuccess("Bukti pembayaran dikirim");
          fetchHistory();
        }
      },
    );

    isLoading.value = false;
    return paymentData;
  }

  void markAsPaidOptimistic(int transactionId) {
    final index = history.indexWhere((tx) => tx.id == transactionId);
    if (index != -1) {
      final originalTx = history[index];
      history[index] = TransactionModel(
        id: originalTx.id,
        bookId: originalTx.bookId,
        userId: originalTx.userId,
        action: originalTx.action,
        status: originalTx.status,
        dueDate: originalTx.dueDate,
        returnDate: originalTx.returnDate,
        fine: originalTx.fine,
        paidAt: DateTime.now(),
        paymentMethod: 'qris',
        createdAt: originalTx.createdAt,
        bookTitle: originalTx.bookTitle,
        author: originalTx.author,
        image: originalTx.image,
        userName: originalTx.userName,
        userEmail: originalTx.userEmail,
      );
      history.refresh();
    }
  }

  int calculateEstimatedFine(Transaction tx) {
    if (tx.status != 'active') return tx.fine;
    if (tx.dueDate == null) return 0;

    final now = DateTime.now();
    if (now.isBefore(tx.dueDate!)) return 0;

    final diff = now.difference(tx.dueDate!);
    final fineAmount = settings.value?.fineAmount ?? 1000;
    final fineUnit = settings.value?.fineUnit ?? 'day';
    final fineDuration = settings.value?.fineDuration ?? 1;

    int overdueCount = 0;

    if (fineUnit == 'minute') {
      overdueCount = (diff.inSeconds / 60 / fineDuration).ceil();
    } else if (fineUnit == 'hour') {
      overdueCount = (diff.inSeconds / 3600 / fineDuration).ceil();
    } else {
      overdueCount = (diff.inSeconds / (24 * 3600) / fineDuration).ceil();
    }

    return overdueCount * fineAmount;
  }

  bool isBorrowed(int bookId) {
    final auth = Get.find<AuthController>();
    final currentUserId = auth.userId.value;
    if (currentUserId.isEmpty) return false;

    return history.any(
      (tx) =>
          tx.bookId == bookId &&
          tx.status == 'active' &&
          tx.userId.toString() == currentUserId,
    );
  }

  Future<void> fetchSettings() async {
    isSettingsLoading.value = true;
    final result = await repository.getSettings();
    result.fold(
      (l) => AppNotificationController.to.showError(l.message),
      (r) => settings.value = r,
    );
    isSettingsLoading.value = false;
  }

  Future<void> updateSettings(TransactionSettingsModel newSettings) async {
    isLoading.value = true;
    final result = await repository.updateSettings(newSettings);
    result.fold(
      (l) {
        AppNotificationController.to.showError(l.message);
        isLoading.value = false;
      },
      (r) async {
        await fetchSettings();
        AppNotificationController.to.showSuccess(
          "Pengaturan transaksi diperbarui",
        );
        isLoading.value = false;
        Get.back();
      },
    );
  }

  void startLoginRedirectTimer() {
    if (showLoginNotif.value) return; // Prevent multiple clicks

    showLoginNotif.value = true;
    loginRedirectCountdown.value = 5;

    _redirectTimer?.cancel();
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (loginRedirectCountdown.value > 1) {
        loginRedirectCountdown.value--;
      } else {
        timer.cancel();
        showLoginNotif.value = false;
        Get.toNamed(Routes.LOGIN);
      }
    });
  }
}
