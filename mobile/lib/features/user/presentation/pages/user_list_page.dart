import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/user_controller.dart';
import '../../domain/entities/user.dart';
import 'user_form_page.dart';

class UserListPage extends GetView<UserController> {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            // Fix repeated animation by biasing inner scroll offset
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
                          "ANGGOTA",
                          style: GoogleFonts.merriweather(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Daftar Anggota",
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
                  actions: const [],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(100),
                    child: Column(
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
                            double offset = controller.scrollOffset.value;
                            const double titleStart = 70.0;
                            const double titleEnd = 130.0;
                            double transition = ((offset - titleStart) /
                                    (titleEnd - titleStart))
                                .clamp(0.0, 1.0);

                            double titleOpacity = transition;
                            double titleSlide = (1.0 - transition) * -15.0;
                            double searchAlignX = transition;

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Opacity(
                                    opacity:
                                        controller.isSearchOpen.value
                                            ? 0.0
                                            : titleOpacity,
                                    child: Transform.translate(
                                      offset: Offset(titleSlide, 0),
                                      child: Text(
                                        "ANGGOTA",
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
                                      controller.isSearchOpen.value
                                          ? Alignment.center
                                          : Alignment(searchAlignX, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (controller.isSelectionMode.value) ...[
                                        TextButton.icon(
                                          onPressed:
                                              () =>
                                                  _confirmBatchDelete(context),
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
                                        IconButton(
                                          onPressed:
                                              controller.toggleSelectionMode,
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.black54,
                                            size: 20,
                                          ),
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
                                                      hintText: "Cari user...",
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
                                                      'user-btns',
                                                    ),
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
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
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons
                                                              .person_add_alt_1_outlined,
                                                          color: Color(
                                                            0xFF1A4D2E,
                                                          ),
                                                          size: 18,
                                                        ),
                                                        onPressed:
                                                            () => Get.to(
                                                              () =>
                                                                  const UserFormPage(),
                                                            ),
                                                      ),
                                                      IconButton(
                                                        onPressed:
                                                            controller
                                                                .toggleSelectionMode,
                                                        icon: const Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.black54,
                                                          size: 18,
                                                        ),
                                                        tooltip:
                                                            "Hapus (Pilih Banyak)",
                                                      ),
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
                        _buildFilterAndSortBar(context),
                      ],
                    ),
                  ),
                ),
              ],
          body: RefreshIndicator(
            onRefresh: controller.refreshUsers,
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
                          controller.users.isEmpty) {
                        return _buildLoadingState();
                      }

                      final userList = controller.displayedUsers;
                      if (userList.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildList(userList),
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

  Widget _buildList(List<User> userList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildUserCard(userList[index]),
    );
  }

  Widget _buildUserCard(User user) {
    return Obx(() {
      final isSelected = controller.selectedIds.contains(user.id);
      final isSelectionMode = controller.isSelectionMode.value;

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
            color: isSelected ? const Color(0xFF1A4D2E) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (isSelectionMode) {
              controller.toggleSelection(user.id);
            } else {
              Get.to(() => UserFormPage(user: user));
            }
          },
          onLongPress: () {
            if (!isSelectionMode) {
              controller.toggleSelectionMode();
              controller.toggleSelection(user.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF1A4D2E).withOpacity(0.1),
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name.substring(0, 1).toUpperCase()
                            : "?",
                        style: GoogleFonts.merriweather(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A4D2E),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.libreBaskerville(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color:
                                  isSelected ? const Color(0xFF1A4D2E) : null,
                            ),
                          ),
                          Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelectionMode && isSelected)
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Color(0xFF1A4D2E),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (user.role ?? '').toLowerCase() == 'admin'
                                ? Colors.orange.shade50
                                : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (user.role ?? 'user').toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color:
                              (user.role ?? '').toLowerCase() == 'admin'
                                  ? Colors.orange.shade800
                                  : Colors.blue.shade800,
                        ),
                      ),
                    ),
                    if (user.isVerified ?? false)
                      const Icon(Icons.verified, color: Colors.blue, size: 14)
                    else
                      const Icon(
                        Icons.pending_actions,
                        color: Colors.grey,
                        size: 14,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms);
    });
  }

  Widget _buildSkeletonUserCard() {
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
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF1A4D2E).withOpacity(0.1),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nama User Yang Panjang",
                        maxLines: 1,
                        style: GoogleFonts.libreBaskerville(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "email@domain.com",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 50,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Icon(Icons.pending_actions, color: Colors.grey, size: 14),
              ],
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
          itemBuilder: (context, index) => _buildSkeletonUserCard(),
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
            const Icon(Icons.people_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              "Tidak ada user ditemukan",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterAndSortBar(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterChip('Semua'),
                const SizedBox(width: 8),
                _buildFilterChip('Admin'),
                const SizedBox(width: 8),
                _buildFilterChip('User'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = controller.selectedRole.value == label;
    return ChoiceChip(
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
        if (selected) controller.setRoleFilter(label);
      },
      selectedColor: const Color(0xFF1A4D2E),
      backgroundColor: Colors.grey.shade50,
      side: BorderSide(
        color: isSelected ? const Color(0xFF1A4D2E) : Colors.grey.shade200,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
    );
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
                _buildSortItem('Nama (A-Z)', Icons.sort_by_alpha_rounded),
                _buildSortItem('Nama (Z-A)', Icons.sort_by_alpha_rounded),
                _buildSortItem('Terbaru', Icons.new_releases_outlined),
                _buildSortItem('Terlama', Icons.history_rounded),
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

  void _confirmBatchDelete(BuildContext context) {
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
                  // Icon Container
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
                  // Title
                  Text(
                    "Hapus ${controller.selectedIds.length} User?",
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    "Data user dan seluruh riwayat peminjaman mereka akan terhapus. Tindakan ini tidak dapat dibatalkan.",
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Buttons
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
                          onPressed: () {
                            controller.deleteSelectedUsers();
                            Get.back();
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
}
