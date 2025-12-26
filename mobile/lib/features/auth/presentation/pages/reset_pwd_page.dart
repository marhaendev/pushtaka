import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/app_pages.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/widgets/app_loading.dart';

class ResetPwdPage extends StatefulWidget {
  const ResetPwdPage({super.key});

  @override
  State<ResetPwdPage> createState() => _ResetPwdPageState();
}

class _ResetPwdPageState extends State<ResetPwdPage> {
  final AuthController controller = Get.find<AuthController>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final ValueNotifier<bool> isLengthValid = ValueNotifier(false);
  final ValueNotifier<bool> isMatchValid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validate);
    confirmPasswordController.addListener(_validate);
  }

  void _validate() {
    isLengthValid.value = passwordController.text.length >= 6;
    isMatchValid.value =
        passwordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    isLengthValid.dispose();
    isMatchValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(),
      ),
      body: Obx(() {
        if (controller.isResetSuccess.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF1A4D2E),
                    size: 100,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Berhasil",
                    style: GoogleFonts.quicksand(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A4D2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Password berhasil diubah",
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Akan dialihkan dalam ${controller.resetCountdown.value} detik",
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.finishReset(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A4D2E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "Lanjut Sekarang",
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Reset Password",
                style: GoogleFonts.quicksand(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A4D2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Silakan buat password baru untuk akun Anda.",
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 48),
              _buildPasswordField(
                "Password Baru",
                Icons.lock_outline,
                passwordController,
                hintText: "masukkan password baru",
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                "Konfirmasi Password",
                Icons.lock_reset_outlined,
                confirmPasswordController,
                hintText: "ulangi password baru",
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: isLengthValid,
                builder: (context, isValid, child) {
                  return _buildValidationItem(isValid, "Minimal 6 karakter");
                },
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<bool>(
                valueListenable: isMatchValid,
                builder: (context, isValid, child) {
                  return _buildValidationItem(
                    isValid,
                    "Password dan Konfirmasi Password sama",
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: Listenable.merge([isLengthValid, isMatchValid]),
                  builder: (context, child) {
                    final isValid = isLengthValid.value && isMatchValid.value;
                    return Obx(
                      () => ElevatedButton(
                        onPressed:
                            controller.isLoading.value || !isValid
                                ? null
                                : () {
                                  controller.resetPassword(
                                    passwordController.text,
                                  );
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A4D2E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                        ),
                        child:
                            controller.isLoading.value
                                ? const AppLoading(
                                  size: 20,
                                  isCircular: true,
                                  color: Colors.white,
                                )
                                : Text(
                                  "RESET PASSWORD",
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    if (controller.isLoggedIn.value) {
                      Get.until((route) => route.settings.name == Routes.HOME);
                    } else {
                      Get.offAllNamed(Routes.LOGIN);
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text(
                    "BATALKAN",
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildValidationItem(bool isValid, String text) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          color: isValid ? Colors.green : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.quicksand(
            fontSize: 12,
            color: isValid ? Colors.green : Colors.grey,
            fontWeight: isValid ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    IconData icon,
    TextEditingController textController, {
    String? hintText,
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
        Obx(
          () => TextField(
            controller: textController,
            obscureText: !controller.isPasswordVisible.value,
            style: GoogleFonts.quicksand(color: Colors.black87, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.quicksand(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF1A4D2E),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
