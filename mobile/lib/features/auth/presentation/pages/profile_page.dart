import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_pages.dart';
import '../controllers/auth_controller.dart';

class ProfilePage extends GetView<AuthController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF1A4D2E),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Text(
                  controller.userName.value,
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Obx(
                () => Text(
                  controller.userEmail.value,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildMenuTile(
                icon: Icons.edit_outlined,
                title: "Ubah Profil",
                onTap: () {
                  Get.toNamed(Routes.EDIT_PROFILE);
                },
              ),
              _buildMenuTile(
                icon: Icons.lock_outline,
                title: "Ubah Password",
                onTap: () {
                  Get.toNamed(Routes.CHANGE_PWD);
                },
              ),
              _buildMenuTile(
                icon: Icons.info_outline,
                title: "Info Aplikasi",
                onTap: () {
                  Get.toNamed(Routes.ABOUT_APP);
                },
              ),
              _buildMenuTile(
                icon: Icons.logout,
                title: "Keluar",
                onTap: () => controller.logout(),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8), // Reduced margin
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        dense: true, // Make it compact
        visualDensity: VisualDensity.compact, // Further compact
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 0,
        ), // Reduce internal padding
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.black87,
          size: 20,
        ), // Smaller icon
        title: Text(
          title,
          style: GoogleFonts.quicksand(
            color: isDestructive ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14, // Slightly smaller text
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
