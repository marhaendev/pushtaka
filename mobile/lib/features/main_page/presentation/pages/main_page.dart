import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../../book/presentation/pages/book_list_page.dart';
import '../../../transaction/presentation/pages/transaction_page.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../user/presentation/pages/user_list_page.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../../core/widgets/shared_bottom_nav.dart';
import '../../../book/presentation/controllers/book_controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find();

    final bookController = Get.find<BookController>();

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          body: Obx(
            () => IndexedStack(
              index: controller.tabIndex.value,
              children: [
                const BookListPage(),
                if (auth.isLoggedIn.value) const TransactionPage(),
                if (auth.isLoggedIn.value && auth.isAdmin.value)
                  const UserListPage(),
                if (auth.isLoggedIn.value) const ProfilePage(),
              ],
            ),
          ),
          bottomNavigationBar: Obx(
            () => SharedBottomNav(
              selectedIndex: controller.tabIndex.value,
              showTransactionTab: auth.isLoggedIn.value,
              isAdmin: auth.isAdmin.value,
              onDestinationSelected: (index) {
                // If not logged in and trying to access non-discover tabs
                if (!auth.isLoggedIn.value && index > 0) {
                  Get.toNamed(Routes.LOGIN);
                  return;
                }
                controller.changeTabIndex(index);
              },
            ),
          ),
        ),
        // Floating Back-to-Top Button Overlay
        Obx(() {
          // Only show on Discover tab (index 0) and when scrolled
          if (controller.tabIndex.value == 0 &&
              bookController.scrollOffset.value > 400) {
            // Calculate position to avoid overlap with icons
            // Member (3 icons): center overlaps icon 2 (Transaksi). Position at x=0.33 (between 2 and 3)
            // Guest (2 icons) or Admin (4 icons): center (x=0) is safe between icons
            int iconCount = 2; // Default Guest
            if (auth.isLoggedIn.value) {
              iconCount = auth.isAdmin.value ? 4 : 3;
            }
            double alignX = (iconCount == 3) ? 0.33 : 0.0;

            return Positioned(
              bottom: 40, // Positioned on top of Bottom Nav
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment(alignX, 0),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  elevation: 0, // Removed shadow
                  child: InkWell(
                    onTap: bookController.scrollToTop,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(
                        Icons.keyboard_double_arrow_up,
                        color: Color(0xFF1A4D2E),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
