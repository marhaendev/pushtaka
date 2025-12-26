import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/book.dart';
import '../../../transaction/presentation/controllers/transaction_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/book_controller.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../main_page/presentation/controllers/main_controller.dart';
import '../../../../core/widgets/app_loading.dart';
import 'package:intl/intl.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late final int bookId;
  late final BookController bookController;
  late final TransactionController transactionController;
  final isBorrowSuccess = false.obs;

  @override
  void initState() {
    super.initState();
    bookId = Get.arguments as int;
    bookController = Get.find<BookController>();
    transactionController = Get.find<TransactionController>();
    bookController.getBookById(bookId);
    isBorrowSuccess.value = false;
  }

  void _confirmDelete(Book book) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red.shade400,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Hapus Buku?",
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Apakah Anda yakin ingin menghapus buku \"${book.title}\"? Transaksi pinjaman buku ini juga akan terhapus.",
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Batal",
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Get.back();
                            await bookController.deleteBook(
                              book.id,
                              onSuccess: () => Get.back(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Hapus",
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _handleBorrowReturn() async {
    final book = bookController.currentBook.value;
    if (book == null) return;

    final isBorrowed = transactionController.isBorrowed(book.id);

    if (isBorrowed) {
      try {
        final mainController = Get.find<MainController>();
        mainController.changeTabIndex(1);
        transactionController.openSearch(book.title, requestFocus: false);
        transactionController.fetchHistory();
        Get.until((route) => route.settings.name == Routes.HOME);
      } catch (e) {
        Get.offAllNamed(Routes.HOME, arguments: book.title);
      }
      return;
    } else if (book.stock > 0) {
      final success = await transactionController.borrowBook(
        book.id,
        book: book,
        silentSuccess: true,
      );

      if (success) {
        isBorrowSuccess.value = true;
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            isBorrowSuccess.value = false;
          }
        });
      }
    }
    await bookController.refreshCurrentBook();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final book = bookController.currentBook.value;
      final isLoading = bookController.isLoadingDetail.value;

      if (isLoading && book == null) {
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: AppLoading()),
        );
      }

      if (book == null) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "Buku tidak ditemukan",
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text("Kembali"),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: Colors.white,
        body: Skeletonizer(
          enabled: isLoading,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 28),
                  onPressed: () => Get.back(),
                ),
                title: Text(
                  "Detail Buku",
                  style: GoogleFonts.merriweather(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                surfaceTintColor: Colors.white,
                actions: [
                  if (Get.find<AuthController>().isAdmin.value) ...[
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        final result = await Get.toNamed(
                          Routes.BOOK_FORM,
                          arguments: book,
                        );
                        if (result == true) {
                          await bookController.refreshCurrentBook();
                        }
                      },
                      tooltip: "Edit Buku",
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(book),
                      tooltip: "Hapus Buku",
                    ),
                  ],
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBookCover(book),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: GoogleFonts.libreBaskerville(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  book.author,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildBookInfo(book),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildActionButtons(book),
      );
    });
  }

  Widget _buildBookCover(Book book) {
    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:
            (book.image != null && book.image!.isNotEmpty)
                ? Image.network(
                  book.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: AppLoading(size: 20)),
                    );
                  },
                )
                : _buildPlaceholderCover(),
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: const Color(0xFF1A4D2E),
      child: Center(
        child: Icon(Icons.book, size: 40, color: Colors.white.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildBookInfo(Book book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.calendar_today, "Tahun", book.year.toString()),
        _buildInfoRow(
          Icons.inventory_2_outlined,
          "Stok",
          "${book.stock} tersedia",
          valueColor: book.stock > 0 ? Colors.green : Colors.red,
        ),
        if (book.code.isNotEmpty)
          _buildInfoRow(Icons.qr_code, "Kode", book.code),
        if (book.isbn.isNotEmpty) _buildInfoRow(Icons.tag, "ISBN", book.isbn),
        if (book.publisher.isNotEmpty)
          _buildInfoRow(Icons.business, "Penerbit", book.publisher),
        if (book.description.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            "Deskripsi",
            style: GoogleFonts.merriweather(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.description,
            textAlign: TextAlign.justify,
            style: GoogleFonts.merriweather(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.8,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1A4D2E)),
          const SizedBox(width: 12),
          Text(
            "$label:",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: valueColor ?? Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Book book) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          final isBorrowed = transactionController.isBorrowed(book.id);
          final borrowCount = transactionController.activeBorrowCount;
          final isLimitReached =
              borrowCount >= transactionController.maxBorrowLimit;
          final hasLateBooks = transactionController.hasLateBooks;
          final hasUnpaidFines = transactionController.hasUnpaidFines;
          final isLoggedIn = Get.find<AuthController>().isLoggedIn.value;

          if (!isLoggedIn || isBorrowed) return const SizedBox.shrink();

          String? warningMessage;
          if (hasLateBooks) {
            warningMessage =
                "Anda memiliki buku yang terlambat dikembalikan. Harap kembalikan buku tersebut sebelum meminjam lagi.";
          } else if (hasUnpaidFines) {
            warningMessage =
                "Anda memiliki denda yang belum dibayar. Harap lunasi denda Anda di menu Transaksi sebelum meminjam lagi.";
          } else if (isLimitReached) {
            warningMessage =
                "Anda sudah meminjam ${transactionController.maxBorrowLimit} buku. Kembalikan salah satu untuk meminjam buku lain.";
          }

          if (warningMessage != null) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF9C4), // Soft Yellow
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFDD835), width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFF57F17),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "$warningMessage "),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              onTap: () {
                                final mainController =
                                    Get.find<MainController>();
                                if (hasUnpaidFines) {
                                  transactionController.setStatusFilter(
                                    'Denda',
                                  );
                                } else if (hasLateBooks) {
                                  transactionController.setStatusFilter(
                                    'Terlambat',
                                  );
                                } else {
                                  transactionController.setStatusFilter(
                                    'Dipinjam',
                                  );
                                }
                                mainController.changeTabIndex(1);
                                Get.until(
                                  (route) => route.settings.name == Routes.HOME,
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Lihat Transaksi",
                                    style: GoogleFonts.sourceSerif4(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    size: 14,
                                    color: Colors.blue.shade700,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 10.5,
                        color: const Color(0xFF5D4037),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.5, end: 0).fadeIn();
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          final isBorrowed = transactionController.isBorrowed(book.id);
          final isLoggedIn = Get.find<AuthController>().isLoggedIn.value;
          if (isBorrowed || !isLoggedIn || book.stock <= 0) {
            return const SizedBox.shrink();
          }
          return _buildDueDatePreview();
        }),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              if (isBorrowSuccess.value) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.black87,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Buku berhasil dipinjam",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                );
              }
              return const SizedBox.shrink();
            }),

            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      final auth = Get.find<AuthController>();
                      final isBorrowed = transactionController.isBorrowed(
                        book.id,
                      );
                      final isTransactionLoading =
                          transactionController.isLoading.value;
                      final isLoggedIn = auth.isLoggedIn.value;
                      final limit = transactionController.maxBorrowLimit;
                      final borrowCount =
                          transactionController.activeBorrowCount;
                      final isLimitReached = borrowCount >= limit;

                      final hasLateBooks = transactionController.hasLateBooks;
                      final hasUnpaidFines =
                          transactionController.hasUnpaidFines;
                      final isRestricted =
                          (isLimitReached || hasLateBooks || hasUnpaidFines) &&
                          !isBorrowed &&
                          isLoggedIn &&
                          !auth.isAdmin.value;

                      return ElevatedButton(
                        onPressed:
                            (isTransactionLoading || isRestricted)
                                ? null
                                : () {
                                  if (!isLoggedIn) {
                                    Get.toNamed(Routes.LOGIN);
                                    return;
                                  }
                                  _handleBorrowReturn();
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              !isLoggedIn
                                  ? const Color(0xFF1A4D2E)
                                  : (isBorrowed
                                      ? const Color(0xFFE67E22)
                                      : const Color(0xFF1A4D2E)),
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            isTransactionLoading
                                ? const AppLoading(
                                  size: 20,
                                  isCircular: true,
                                  color: Colors.white,
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      !isLoggedIn
                                          ? Icons.login
                                          : (isBorrowed
                                              ? Icons.assignment_return
                                              : Icons.book),
                                      color:
                                          isRestricted
                                              ? Colors.grey.shade500
                                              : Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      !isLoggedIn
                                          ? "Login untuk Pinjam"
                                          : (isBorrowed
                                              ? "Kembalikan Buku"
                                              : (book.stock > 0
                                                  ? (isRestricted
                                                      ? "Pinjam Dibatasi"
                                                      : "Pinjam Buku")
                                                  : "Stok Habis")),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color:
                                            isRestricted
                                                ? Colors.grey.shade500
                                                : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                      ); // Closing ElevatedButton
                    }),
                  ),
                  const SizedBox(width: 16),
                  Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          bookController.isFavorite(book.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red.shade400,
                        ),
                        onPressed: () => bookController.toggleFavorite(book.id),
                        padding: const EdgeInsets.all(12),
                        tooltip:
                            bookController.isFavorite(book.id)
                                ? "Hapus dari Favorit"
                                : "Tambah ke Favorit",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDueDatePreview() {
    return Obx(() {
      final s = transactionController.settings.value;
      if (s == null) return const SizedBox.shrink();

      final now = DateTime.now();
      DateTime dueDate;
      if (s.borrowDurationUnit == 'minute') {
        dueDate = now.add(Duration(minutes: s.borrowDuration));
      } else if (s.borrowDurationUnit == 'hour') {
        dueDate = now.add(Duration(hours: s.borrowDuration));
      } else {
        dueDate = now.add(Duration(days: s.borrowDuration));
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        color: Colors.blue.shade50.withOpacity(0.5),
        child: Row(
          children: [
            Icon(Icons.timer_outlined, size: 14, color: Colors.blue.shade800),
            const SizedBox(width: 8),
            Text(
              "Estimasi jatuh tempo: ${DateFormat('dd MMM yyyy, HH:mm').format(dueDate)}",
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// End of file - Trigger Reload Fix Final
