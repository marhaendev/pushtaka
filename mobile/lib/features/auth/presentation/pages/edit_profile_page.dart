import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/widgets/app_loading.dart';
// ignore: unused_import
import '../../../../core/widgets/app_notification_alert.dart';
import '../../../../core/controllers/app_notification_controller.dart';

class EditProfilePage extends GetView<AuthController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller for input fields, initialized with current user data
    final nameController = TextEditingController(
      text: controller.userName.value,
    );
    final emailController = TextEditingController(
      text: controller.userEmail.value,
    );
    final roleController = TextEditingController(
      text: controller.isAdmin.value ? "Admin" : "Member",
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Ubah Profil",
              style: GoogleFonts.merriweather(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A4D2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Perbarui informasi profil Anda di bawah ini.",
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildInputField(
              "Nama Lengkap",
              Icons.person_outline,
              nameController,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              "Email",
              Icons.email_outlined,
              emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: false,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              "Role",
              Icons.badge_outlined,
              roleController,
              enabled: false,
            ),
            const SizedBox(height: 48),
            Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : () {
                          if (nameController.text.isNotEmpty) {
                            controller.updateProfile(
                              nameController.text,
                              emailController.text,
                            );
                          } else {
                            AppNotificationController.to.showError(
                              "Nama harus diisi",
                            );
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A4D2E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    controller.isLoading.value
                        ? const AppLoading(
                          size: 20,
                          isCircular: true,
                          color: Colors.white,
                        )
                        : Text(
                          "Simpan Perubahan",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    int? maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          style: GoogleFonts.quicksand(
            color: enabled ? Colors.black87 : Colors.grey.shade600,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 20,
              color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
            ),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1A4D2E),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
