import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/controllers/app_notification_controller.dart';

class ChangePwdPage extends GetView<AuthController> {
  const ChangePwdPage({super.key});

  @override
  Widget build(BuildContext context) {
    final passwordController = TextEditingController();

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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Verifikasi Password",
              style: GoogleFonts.merriweather(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A4D2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Masukkan password saat ini untuk melanjutkan proses ubah password.",
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Obx(
              () => TextField(
                controller: passwordController,
                obscureText: !controller.isPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: "Password Saat Ini",
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 20,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    controller.verifyCurrentPasswordAndSendOtp(value);
                  }
                },
              ),
            ),
            Obx(() {
              if (controller.currentPasswordErrorMessage.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    controller.currentPasswordErrorMessage.value,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 32),
            Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : () {
                          if (passwordController.text.isNotEmpty) {
                            controller.verifyCurrentPasswordAndSendOtp(
                              passwordController.text,
                            );
                          } else {
                            AppNotificationController.to.showError(
                              "Password harus diisi",
                            );
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A4D2E),
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
                          "Lanjut",
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
}
