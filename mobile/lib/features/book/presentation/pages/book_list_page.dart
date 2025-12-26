import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controllers/book_controller.dart';
import '../../../transaction/presentation/controllers/transaction_controller.dart';
import '../../../../core/routes/app_pages.dart';

class BookListPage extends GetView<BookController> {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionController = Get.find<TransactionController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
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
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          0,
                          MediaQuery.of(context).padding.top + 20,
                          0,
                          20,
                        ),
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "PUSHTAKA",
                              style: GoogleFonts.merriweather(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              "Manajemen Perpustakaan",
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
                      actions: const [],
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(50),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade100),
                            ),
                          ),
                          child: Obx(() {
                            double offset = controller.scrollOffset.value;
                            double titleStart = 70.0;
                            double titleEnd = 130.0;
                            double alignTransition = ((offset - titleStart) /
                                    (titleEnd - titleStart))
                                .clamp(0.0, 1.0);
                            double alignX = alignTransition;

                            double titleOpacity = alignTransition;
                            double titleSlide = (1.0 - titleOpacity) * -15.0;

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Obx(() {
                                    if (controller.isSearchOpen.value) {
                                      return const SizedBox.shrink();
                                    }
                                    return Opacity(
                                      opacity: titleOpacity,
                                      child: Transform.translate(
                                        offset: Offset(titleSlide, 0),
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.6,
                                          ),
                                          child: Text(
                                            "PUSHTAKA",
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                            style: GoogleFonts.merriweather(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                Align(
                                  alignment:
                                      controller.isSearchOpen.value
                                          ? Alignment.center
                                          : Alignment(alignX, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (controller.isSelectionMode.value) ...[
                                        TextButton.icon(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (context) => Dialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    backgroundColor:
                                                        Colors.white,
                                                    surfaceTintColor:
                                                        Colors.white,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            24,
                                                          ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          // Icon Container
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  16,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .red
                                                                          .shade50,
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                ),
                                                            child: Icon(
                                                              Icons
                                                                  .delete_forever_rounded,
                                                              color:
                                                                  Colors
                                                                      .red
                                                                      .shade400,
                                                              size: 32,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          // Title
                                                          Text(
                                                            "Hapus ${controller.selectedIds.length} Buku?",
                                                            style: GoogleFonts.merriweather(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                            ),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          // Description
                                                          Text(
                                                            "Buku yang dihapus tidak dapat dikembalikan lagi. Riwayat pinjaman buku ini juga akan terhapus.",
                                                            style: GoogleFonts.quicksand(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors
                                                                      .black54,
                                                              height: 1.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                          const SizedBox(
                                                            height: 32,
                                                          ),
                                                          // Buttons
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: OutlinedButton(
                                                                  onPressed:
                                                                      () =>
                                                                          Get.back(),
                                                                  style: OutlinedButton.styleFrom(
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              12,
                                                                        ),
                                                                    side: BorderSide(
                                                                      color:
                                                                          Colors
                                                                              .grey
                                                                              .shade300,
                                                                    ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    "Batal",
                                                                    style: GoogleFonts.quicksand(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          Colors
                                                                              .black87,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 12,
                                                              ),
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                  onPressed: () {
                                                                    Get.back();
                                                                    controller
                                                                        .deleteSelectedBooks();
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red
                                                                            .shade400,
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              12,
                                                                        ),
                                                                    elevation:
                                                                        0,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    "Hapus",
                                                                    style: GoogleFonts.quicksand(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          Colors
                                                                              .white,
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
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 18,
                                          ),
                                          label: Text(
                                            "Hapus (${controller.selectedIds.length})",
                                            style: GoogleFonts.poppins(
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed:
                                              controller.toggleSelectionMode,
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.black54,
                                            size: 20,
                                          ),
                                          tooltip: "Batal",
                                        ),
                                      ] else ...[
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 400,
                                          ),
                                          curve: Curves.easeInOutCubic,
                                          width:
                                              controller.isSearchOpen.value
                                                  ? MediaQuery.of(
                                                        context,
                                                      ).size.width -
                                                      40
                                                  : 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child:
                                              controller.isSearchOpen.value
                                                  ? TextField(
                                                    autofocus: true,
                                                    style:
                                                        GoogleFonts.merriweather(
                                                          fontSize: 12,
                                                          color: Colors.black87,
                                                        ),
                                                    decoration: InputDecoration(
                                                      hintText: "Cari...",
                                                      fillColor: Colors.white,
                                                      filled: true,
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 8,
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
                                                                  .shade300,
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
                                                                      .shade300,
                                                            ),
                                                          ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            borderSide: BorderSide(
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade400,
                                                            ),
                                                          ),
                                                      hintStyle:
                                                          GoogleFonts.merriweather(
                                                            color: Colors.grey,
                                                            fontSize: 12,
                                                          ),
                                                      suffixIcon: IconButton(
                                                        icon: const Icon(
                                                          Icons.close,
                                                          size: 16,
                                                          color: Colors.black54,
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
                                              !controller.isSearchOpen.value
                                                  ? Row(
                                                    key: const ValueKey(
                                                      'buttons',
                                                    ),
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        iconSize: 18,
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        icon: Icon(
                                                          controller
                                                                  .isGridView
                                                                  .value
                                                              ? Icons
                                                                  .view_list_rounded
                                                              : Icons
                                                                  .grid_view_rounded,
                                                          color: Colors.black54,
                                                        ),
                                                        onPressed:
                                                            controller
                                                                .toggleView,
                                                        tooltip: "Tampilan",
                                                      ),

                                                      Obx(() {
                                                        final isFav =
                                                            controller
                                                                .isShowFavorites
                                                                .value;
                                                        return IconButton(
                                                          icon: Icon(
                                                            isFav
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border,
                                                            color:
                                                                isFav
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .black54,
                                                          ),
                                                          iconSize: 18,
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                          onPressed:
                                                              controller
                                                                  .toggleShowFavorites,
                                                          tooltip:
                                                              "Tampilkan Favorit",
                                                        );
                                                      }),

                                                      if (true) ...[
                                                        PopupMenuButton<String>(
                                                          icon: const Icon(
                                                            Icons.more_vert,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                          iconSize: 18,
                                                          tooltip: "Lainnya",
                                                          offset: const Offset(
                                                            0,
                                                            40,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          color: Colors.white,
                                                          surfaceTintColor:
                                                              Colors.white,
                                                          onSelected: (value) {
                                                            if (value ==
                                                                'hapus') {
                                                              controller
                                                                  .toggleSelectionMode();
                                                            } else if (value ==
                                                                'add') {
                                                              print(
                                                                "Navigating to Book Form...",
                                                              );
                                                              Get.toNamed(
                                                                Routes
                                                                    .BOOK_FORM,
                                                              );
                                                            } else if (value
                                                                .startsWith(
                                                                  'sort_',
                                                                )) {
                                                              controller.sortBooks(
                                                                value
                                                                    .replaceFirst(
                                                                      'sort_',
                                                                      '',
                                                                    ),
                                                              );
                                                            } else if (value
                                                                .startsWith(
                                                                  'filter_',
                                                                )) {
                                                              controller.filterBooks(
                                                                value
                                                                    .replaceFirst(
                                                                      'filter_',
                                                                      '',
                                                                    ),
                                                              );
                                                            }
                                                          },
                                                          itemBuilder: (
                                                            context,
                                                          ) {
                                                            return [
                                                              if (controller
                                                                  .isAdmin
                                                                  .value) ...[
                                                                _buildPopupHeader(
                                                                  "Buku",
                                                                ),
                                                                _buildPopupItem(
                                                                  'add',
                                                                  Icons
                                                                      .add_circle_outline,
                                                                  'Tambah Buku',
                                                                ),
                                                                _buildPopupItem(
                                                                  'hapus',
                                                                  Icons
                                                                      .delete_outline,
                                                                  'Hapus',
                                                                ),
                                                                const PopupMenuDivider(
                                                                  height: 1,
                                                                ),
                                                              ],
                                                              _buildPopupHeader(
                                                                "Urutkan",
                                                              ),
                                                              _buildPopupItem(
                                                                'sort_title_asc',
                                                                Icons
                                                                    .sort_by_alpha,
                                                                'Judul (A-Z)',
                                                              ),
                                                              _buildPopupItem(
                                                                'sort_title_desc',
                                                                Icons
                                                                    .sort_by_alpha,
                                                                'Judul (Z-A)',
                                                              ),
                                                              _buildPopupItem(
                                                                'sort_year_desc',
                                                                Icons
                                                                    .calendar_month,
                                                                'Terbaru',
                                                              ),
                                                              _buildPopupItem(
                                                                'sort_year_asc',
                                                                Icons
                                                                    .calendar_month,
                                                                'Terlama',
                                                              ),
                                                              const PopupMenuDivider(
                                                                height: 1,
                                                              ),
                                                              _buildPopupHeader(
                                                                "Filter",
                                                              ),
                                                              _buildPopupItem(
                                                                'filter_Semua',
                                                                Icons
                                                                    .all_inclusive,
                                                                'Semua',
                                                              ),
                                                              _buildPopupItem(
                                                                'filter_Tersedia',
                                                                Icons
                                                                    .check_circle_outline,
                                                                'Tersedia',
                                                              ),
                                                              _buildPopupItem(
                                                                'filter_Habis',
                                                                Icons
                                                                    .block_flipped,
                                                                'Habis',
                                                              ),
                                                            ];
                                                          },
                                                        ),
                                                      ],
                                                    ],
                                                  )
                                                  : const SizedBox.shrink(
                                                    key: ValueKey('hide'),
                                                  ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
              body: RefreshIndicator(
                onRefresh: controller.refreshBooks,
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
                              controller.books.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                100,
                              ),
                              child: Skeletonizer(
                                enabled: true,
                                child:
                                    controller.isGridView.value
                                        ? MasonryGridView.count(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                          itemCount: 12,
                                          itemBuilder: (context, index) {
                                            return _buildSkeletonBookCard(
                                              isGrid: true,
                                            );
                                          },
                                        )
                                        : ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: 12,
                                          separatorBuilder:
                                              (context, index) =>
                                                  const SizedBox(height: 12),
                                          itemBuilder: (context, index) {
                                            return _buildSkeletonBookCard(
                                              isGrid: false,
                                            );
                                          },
                                        ),
                              ),
                            );
                          }

                          final booksList = controller.displayedBooks;

                          if (booksList.isEmpty) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.search_off,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Tidak ada buku ditemukan",
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (controller.isGridView.value) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MasonryGridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    itemCount: booksList.length,
                                    itemBuilder: (context, index) {
                                      return _buildBookCard(
                                        booksList[index],
                                        index,
                                        isGrid: true,
                                        key: ValueKey(booksList[index].id),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: booksList.length,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: _buildBookCard(
                                          booksList[index],
                                          index,
                                          isGrid: false,
                                          key: ValueKey(booksList[index].id),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        }),
                      ),
                      SliverToBoxAdapter(
                        child: const SizedBox(height: 80),
                      ), // Bottom spacer
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Login Notification Overlay
          Obx(() {
            if (!transactionController.showLoginNotif.value) {
              return const SizedBox.shrink();
            }
            return Positioned(
              bottom: 80, // Above FAB/Bottom
              left: 20,
              right: 20,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.login_rounded,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Anda perlu login untuk meminjam buku.",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "Menuju halaman login dalam ${transactionController.loginRedirectCountdown.value} detik",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.5, end: 0),
            );
          }),
          // Delete Processing Overlay
          Obx(() {
            if (!controller.isProcessingDelete.value) {
              return const SizedBox.shrink();
            }
            return Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.white.withOpacity(0.4)),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/loading.gif', height: 100),
                      const SizedBox(height: 16),
                      Text(
                        "Sedang memproses...",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn();
          }),
        ],
      ),
    );
  }

  Widget _buildSkeletonBookCard({required bool isGrid}) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.transparent, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Judul Buku Yang Cukup Panjang Di Sini",
              maxLines: 2,
              style: GoogleFonts.libreBaskerville(
                fontWeight: FontWeight.bold,
                fontSize: isGrid ? 12 : 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Penulis Buku • 2024",
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: isGrid ? 10 : 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                if (!isGrid)
                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(
    dynamic book,
    int index, {
    required bool isGrid,
    Key? key,
  }) {
    final transactionController = Get.find<TransactionController>();
    return Obx(() {
      final isSelected = controller.selectedIds.contains(book.id ?? 0);
      final isSelectionMode = controller.isSelectionMode.value;

      final isDeleting = controller.deletingIds.contains(book.id ?? 0);
      final isRight = index % 2 == 1;

      return Card(
            margin: EdgeInsets.zero,
            elevation: isSelected ? 4 : 2,
            shadowColor:
                isSelected
                    ? const Color(0xFF1A4D2E).withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
            color: isSelected ? const Color(0xFFF1F8F4) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color:
                    isSelected ? const Color(0xFF1A4D2E) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (isSelectionMode) {
                  controller.toggleSelection(book.id ?? 0);
                } else {
                  // Navigate to detail
                  print(
                    "DEBUG: Navigating to detail with ID: ${book.id} (Type: ${book.id.runtimeType})",
                  );
                  Get.toNamed(Routes.BOOK_DETAIL, arguments: book.id);
                }
              },
              onLongPress: () {
                if (!isSelectionMode && controller.isAdmin.value) {
                  controller.toggleSelectionMode();
                  controller.toggleSelection(book.id ?? 0);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isGrid)
                          // Image Container
                          Container(
                            height: 140,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade100,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  (book.image != null && book.image!.isNotEmpty)
                                      ? Image.network(
                                        book.image!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.grey.shade400,
                                                size: 30,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                      : Container(
                                        color: Colors.grey.shade200,
                                        child: Center(
                                          child: Icon(
                                            Icons.book,
                                            size: 30,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.libreBaskerville(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                isGrid ? 12 : 14, // Reduced grid font size
                            color: isSelected ? const Color(0xFF1A4D2E) : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${book.author} • ${book.year > 0 ? book.year : '-'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize:
                                isGrid ? 10 : 12, // Reduced grid font size
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    book.stock > 0
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                book.stock > 0
                                    ? "${book.stock} Tersedia"
                                    : "Habis",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color:
                                      book.stock > 0
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (!isGrid && !isSelectionMode)
                              const Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: Colors.grey,
                              ),
                            if (isSelectionMode && isSelected)
                              const Icon(
                                Icons.check_circle,
                                size: 22,
                                color: Color(0xFF1A4D2E),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (!isSelectionMode)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (transactionController.isBorrowed(book.id ?? 0))
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.bookmark_rounded,
                                  size: 18,
                                  color: Colors.orange,
                                ),
                              ),
                            InkWell(
                              onTap: () {
                                controller.toggleFavorite(book.id ?? 0);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  controller.isFavorite(book.id ?? 0)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 18,
                                  color:
                                      controller.isFavorite(book.id ?? 0)
                                          ? Colors.red
                                          : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
          .animate(target: isDeleting ? 1 : 0)
          .fadeOut(duration: 400.ms)
          .slideX(
            begin: 0,
            end: isGrid ? (isRight ? 1 : -1) : -1,
            duration: 400.ms,
            curve: Curves.easeInCubic,
          )
          .custom(
            duration: 400.ms,
            curve: Curves.easeInOutCubic,
            builder: (context, value, child) {
              return Align(
                heightFactor: 1 - value,
                alignment: Alignment.topCenter,
                child: child,
              );
            },
          );
    });
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<String>(
      value: value,
      height: 36,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.poppins(fontSize: 11)),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupHeader(String title) {
    return PopupMenuItem<String>(
      enabled: false,
      height: 24,
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// Simple dummy book class for skeleton loading
