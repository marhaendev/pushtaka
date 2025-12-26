import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/transaction_controller.dart';

import '../../domain/entities/transaction.dart';
import '../../../../core/routes/app_pages.dart';

class TransactionPage extends GetView<TransactionController> {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            double pixels = notification.metrics.pixels;
            if (notification.depth > 0) {
              pixels += 140.0;
            }
            controller.updateScroll(pixels);
          }
          return true;
        },
        child: NestedScrollView(
          controller: controller.scrollController,
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      0,
                      MediaQuery.of(context).padding.top + 20,
                      0,
                      10,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text(
                          "TRANSAKSI",
                          style: GoogleFonts.merriweather(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Peminjaman Buku",
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 0,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(155),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade50),
                              ),
                            ),
                            child: Obx(() {
                              final isOpen = controller.isSearchOpen.value;
                              final offset = controller.scrollOffset.value;

                              // Animation logic matching Discover page
                              const double titleStart = 70.0;
                              const double titleEnd = 130.0;

                              double transition = ((offset - titleStart) /
                                      (titleEnd - titleStart))
                                  .clamp(0.0, 1.0);

                              // Sync title opacity and slide with search alignment
                              double titleOpacity = transition;
                              double titleSlide = (1.0 - transition) * -15.0;
                              double searchAlignX = transition;

                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Small Title
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Opacity(
                                      opacity: isOpen ? 0.0 : titleOpacity,
                                      child: Transform.translate(
                                        offset: Offset(titleSlide, 0),
                                        child: Text(
                                          "TRANSAKSI",
                                          style: GoogleFonts.merriweather(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Align(
                                    alignment:
                                        isOpen
                                            ? Alignment.center
                                            : Alignment(searchAlignX, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Search Bar / Icon
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 400,
                                          ),
                                          curve: Curves.easeInOutCubic,
                                          width:
                                              isOpen
                                                  ? MediaQuery.of(
                                                        context,
                                                      ).size.width -
                                                      32
                                                  : 40,
                                          height: 40,
                                          child:
                                              isOpen
                                                  ? TextField(
                                                    controller:
                                                        controller
                                                            .searchTextController,
                                                    focusNode:
                                                        controller
                                                            .searchFocusNode,
                                                    style:
                                                        GoogleFonts.merriweather(
                                                          fontSize: 12,
                                                        ),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Cari transaksi...",
                                                      fillColor:
                                                          Colors.grey.shade50,
                                                      filled: true,
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                          ),
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade200,
                                                        ),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            borderSide: BorderSide(
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade200,
                                                            ),
                                                          ),
                                                      suffixIcon: IconButton(
                                                        icon: const Icon(
                                                          Icons.close,
                                                          size: 16,
                                                        ),
                                                        onPressed:
                                                            controller
                                                                .toggleSearch,
                                                      ),
                                                    ),
                                                    onChanged:
                                                        controller.search,
                                                  )
                                                  : GestureDetector(
                                                    onTap:
                                                        controller.toggleSearch,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.search,
                                                        color: Colors.black54,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                        ),

                                        // Action Icons (Sort, Settings) using AnimatedSwitcher for smooth transitions
                                        AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 400,
                                          ),
                                          switchInCurve: Curves.easeInOutCubic,
                                          switchOutCurve: Curves.easeInOutCubic,
                                          transitionBuilder: (
                                            child,
                                            animation,
                                          ) {
                                            return SizeTransition(
                                              sizeFactor: animation,
                                              axis: Axis.horizontal,
                                              child: child,
                                            );
                                          },
                                          child:
                                              !isOpen
                                                  ? Row(
                                                    key: const ValueKey(
                                                      'tx_actions',
                                                    ),
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      if (controller.isAdmin)
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons
                                                                .settings_outlined,
                                                            color:
                                                                Colors.black54,
                                                            size: 18,
                                                          ),
                                                          onPressed:
                                                              () => Get.toNamed(
                                                                Routes
                                                                    .TRANSACTION_SETTINGS,
                                                              ),
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                        ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.sort_rounded,
                                                          color: Colors.black54,
                                                          size: 18,
                                                        ),
                                                        onPressed:
                                                            () =>
                                                                _showSortOptions(
                                                                  context,
                                                                ),
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                      ),
                                                    ],
                                                  )
                                                  : const SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                          _buildFilterAndSortBar(context),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Obx(() {
                    if (controller.selectedStatus.value == 'Denda') {
                      final s = controller.settings.value;
                      final fineAmount = s?.fineAmount ?? 1000;
                      final fineDuration = s?.fineDuration ?? 1;
                      final fineUnit =
                          s?.fineUnit == 'minute'
                              ? 'Menit'
                              : s?.fineUnit == 'hour'
                              ? 'Jam'
                              : 'Hari';

                      return Container(
                        width: double.infinity,
                        color: Colors.blue.shade50,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Denda: Rp $fineAmount per $fineDuration $fineUnit keterlambatan",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms);
                    }
                    return const SizedBox.shrink();
                  }),
                ),
              ],
          body: RefreshIndicator(
            onRefresh: controller.refreshHistory,
            color: const Color(0xFF1A4D2E),
            child: RawScrollbar(
              thumbVisibility: true,
              thumbColor: const Color(0xFF1A4D2E),
              radius: const Radius.circular(8),
              thickness: 6,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.history.isEmpty) {
                        return _buildLoadingState();
                      }

                      final txList = controller.displayedTransactions;
                      if (txList.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child:
                            controller.isGridView.value
                                ? _buildList(
                                  txList,
                                ) // Use list for both just in case, or just _buildList
                                : _buildList(txList),
                      );
                    }),
                  ),
                  SliverToBoxAdapter(
                    child: Obx(() {
                      if (controller.scrollOffset.value > 400) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextButton.icon(
                              onPressed: controller.scrollToTop,
                              icon: const Icon(
                                Icons.keyboard_double_arrow_up,
                                size: 18,
                                color: Colors.grey,
                              ),
                              label: Text(
                                "Kembali ke Atas",
                                style: GoogleFonts.merriweather(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Transaction> txList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: txList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder:
          (context, index) =>
              _buildTransactionCard(txList[index], isGrid: false),
    );
  }

  Widget _buildTransactionCard(Transaction tx, {required bool isGrid}) {
    final isBorrowed = tx.status == 'active';
    final isOverdue =
        tx.dueDate != null &&
        tx.dueDate!.isBefore(DateTime.now()) &&
        isBorrowed;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue ? Colors.red.shade200 : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed(Routes.BOOK_DETAIL, arguments: tx.bookId);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: isGrid ? 16 : 20,
                    backgroundColor:
                        isBorrowed
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                    child: Icon(
                      isBorrowed ? Icons.book : Icons.check,
                      color: isBorrowed ? Colors.orange : Colors.green,
                      size: isGrid ? 16 : 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.bookTitle ?? "Buku #${tx.bookId}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.libreBaskerville(
                            fontWeight: FontWeight.bold,
                            fontSize: isGrid ? 11 : 13,
                          ),
                        ),
                        if (tx.author != null)
                          Text(
                            tx.author!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),

                        if (controller.isAdmin && tx.userName != null) ...[
                          const SizedBox(height: 4),
                          RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.blue.shade700,
                              ),
                              children: [
                                const TextSpan(
                                  text: "Peminjam: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                TextSpan(
                                  text: "${tx.userName}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (tx.userEmail != null &&
                                    tx.userEmail!.isNotEmpty)
                                  TextSpan(
                                    text: " (${tx.userEmail})",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.blue.shade400,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isBorrowed
                                  ? Colors.orange.shade50
                                  : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isBorrowed ? "Dipinjam" : "Dikembalikan",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color:
                                isBorrowed
                                    ? Colors.orange.shade800
                                    : Colors.green.shade800,
                          ),
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Terlambat",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Dipinjam: ${DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt.toLocal())}",
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (!isBorrowed && tx.returnDate != null)
                        Text(
                          "Dikembalikan: ${DateFormat('dd MMM yyyy, HH:mm').format(tx.returnDate!.toLocal())}",
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else if (isBorrowed && tx.dueDate != null)
                        Text(
                          "Jatuh tempo: ${DateFormat('dd MMM yyyy, HH:mm').format(tx.dueDate!.toLocal())}",
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color:
                                isOverdue
                                    ? Colors.red.shade700
                                    : Colors.orange.shade700,
                            fontWeight:
                                isOverdue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Builder(
                builder: (context) {
                  final fine = controller.calculateEstimatedFine(tx);
                  // Only show denda line if there is a fine
                  if (fine > 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Denda: Rp ${fine.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (tx.paidAt != null)
                          Text(
                            "Lunas (${DateFormat('dd MMM HH:mm').format(tx.paidAt!.toLocal())})",
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (tx.status != 'active' || tx.action == 'return')
                          Builder(
                            builder: (context) {
                              final isOwner =
                                  controller.currentUserId ==
                                  tx.userId.toString();
                              if (!isOwner) return const SizedBox.shrink();

                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: SizedBox(
                                  height: 28,
                                  child: ElevatedButton(
                                    onPressed: () => _showPaymentSelection(tx),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade700,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: Text(
                                      "Bayar Denda",
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ); // Close Padding
                            }, // Close Builder builder
                          ), // Close Builder
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              Builder(
                builder: (context) {
                  final isOwner =
                      controller.currentUserId == tx.userId.toString();
                  if (isBorrowed && isOwner) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Get.dialog(
                              Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Colors.white,
                                surfaceTintColor: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.keyboard_return_rounded,
                                          color: Colors.orange.shade400,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Kembalikan Buku?",
                                        style: GoogleFonts.merriweather(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Pastikan Anda sudah selesai membaca buku ini sebelum mengembalikannya.",
                                        style: GoogleFonts.quicksand(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => Get.back(),
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                side: BorderSide(
                                                  color: Colors.grey.shade300,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                "Batal",
                                                style: GoogleFonts.quicksand(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Get.back();
                                                controller.returnBook(
                                                  tx.bookId,
                                                  userId: tx.userId,
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.orange.shade400,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                "Kembalikan",
                                                style: GoogleFonts.quicksand(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  fontSize: 14,
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
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 8,
                            ),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            "Kembalikan",
                            style: GoogleFonts.poppins(fontSize: 10),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSkeletonCard({required bool isGrid}) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isGrid ? 16 : 20,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Judul Buku Yang Panjang",
                        maxLines: 1,
                        style: GoogleFonts.libreBaskerville(
                          fontWeight: FontWeight.bold,
                          fontSize: isGrid ? 11 : 13,
                        ),
                      ),
                      Text(
                        "Nama Penulis",
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: 70,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "23 Dec 2025, 10:30",
              style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Skeletonizer(
        enabled: true,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildSkeletonCard(isGrid: false),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              controller.selectedStatus.value == 'Denda'
                  ? "Tidak ada tagihan denda"
                  : "Belum ada transaksi peminjaman",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Filter bar - only filter chips (sort is in toolbar)
  Widget _buildFilterAndSortBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 0,
            children: [
              _buildFilterChip('Semua'),
              _buildFilterChip('Dipinjam'),
              _buildFilterChip('Dikembalikan'),
            ],
          ),
          const SizedBox(height: 2),
          Wrap(
            spacing: 6,
            runSpacing: 0,
            children: [
              _buildFilterChip('Terlambat'),
              _buildFilterChip('Denda'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Obx(() {
      final isSelected = controller.selectedStatus.value == label;
      int count = 0;
      if (label == 'Semua') {
        count = controller.countSemua;
      } else if (label == 'Dipinjam') {
        count = controller.countDipinjam;
      } else if (label == 'Dikembalikan') {
        count = controller.countDikembalikan;
      } else if (label == 'Terlambat') {
        count = controller.countTerlambat;
      } else if (label == 'Denda') {
        count = controller.countDenda;
      }

      return Badge(
        label: Text(
          count.toString(),
          style: const TextStyle(fontSize: 9, color: Colors.white),
        ),
        isLabelVisible: count > 0,
        backgroundColor:
            isSelected ? const Color(0xFFFF4B2B) : const Color(0xFF1A4D2E),
        offset: const Offset(4, -4),
        child: ChoiceChip(
          label: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) controller.setStatusFilter(label);
          },
          selectedColor: const Color(0xFF1A4D2E),
          backgroundColor: Colors.grey.shade50,
          side: BorderSide(
            color: isSelected ? const Color(0xFF1A4D2E) : Colors.grey.shade200,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          visualDensity: VisualDensity.compact,
          showCheckmark: false,
        ),
      );
    });
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Urutkan Berdasarkan",
                  style: GoogleFonts.merriweather(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSortItem('Terbaru', Icons.new_releases_outlined),
                _buildSortItem('Terlama', Icons.history_rounded),
                _buildSortItem('Judul (A-Z)', Icons.sort_by_alpha_rounded),
                _buildSortItem('Judul (Z-A)', Icons.sort_by_alpha_rounded),
              ],
            ),
          ),
    );
  }

  Widget _buildSortItem(String label, IconData icon) {
    return Obx(
      () => ListTile(
        leading: Icon(icon, color: const Color(0xFF1A4D2E)),
        title: Text(label, style: GoogleFonts.poppins(fontSize: 14)),
        trailing:
            controller.selectedSort.value == label
                ? const Icon(Icons.check_circle, color: Color(0xFF1A4D2E))
                : null,
        onTap: () {
          controller.setSortOption(label);
          Get.back();
        },
      ),
    );
  }

  void _showPaymentSelection(Transaction tx) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pilih Metode Pembayaran",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Denda: Rp ${tx.fine.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _buildPaymentMethodItem(
              icon: Icons.qr_code_scanner_rounded,
              title: "QRIS (Otomatis)",
              subtitle: "Pembayaran instan via GoPay, OVO, Dana, dll.",
              onTap: () async {
                Get.back();
                // We still call the API to notify the backend, but we ignore the actual Midtrans response data
                await controller.payFine(tx.id, method: 'qris');
                // Always show mock QR for dummy simulation
                const mockQrString =
                    "00020101021126670014ID.CO.QRIS.WWW0215ID1020211116246030300051440014ID.CO.QRIS.WWW5204594253033605802ID5911PUSHTAKA.CO6007JAKARTA6105123456304ABCD";
                _showQRIS(mockQrString, tx);
              },
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodItem(
              icon: Icons.account_balance_rounded,
              title: "Transfer Manual",
              subtitle: "Transfer ke rekening perpustakaan & unggah bukti.",
              onTap: () {
                Get.back();
                _showManualPayment(tx);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showQRIS(String qrString, Transaction tx) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Scan QRIS untuk Bayar",
                style: GoogleFonts.merriweather(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrString,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Total Bayar: Rp ${tx.fine.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Simulasi: Klik tombol di bawah untuk anggap pembayaran berhasil",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.markAsPaidOptimistic(tx.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A4D2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Konfirmasi Pembayaran Selesai",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualPayment(Transaction tx) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Transfer Manual (Simulasi)",
                style: GoogleFonts.merriweather(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Bank", style: GoogleFonts.poppins(fontSize: 12)),
                        Text(
                          "BCA (Pushtaka)",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "No. Rekening",
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          "1234567890",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total", style: GoogleFonts.poppins(fontSize: 12)),
                        Text(
                          "Rp ${tx.fine.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Simulasi Unggah Bukti",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  await controller.payFine(
                    tx.id,
                    method: 'manual',
                    proof: 'simulated_proof_base64',
                  );
                  Get.back();
                },
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.grey.shade400,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Klik untuk simulasi unggah",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
