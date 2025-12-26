import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../../core/widgets/shared_bottom_nav.dart';
import '../../../../core/widgets/app_loading.dart';

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var passwordController = TextEditingController();
    var nameController = TextEditingController();
    var otps = List.generate(6, (index) => TextEditingController());

    var currentStep = 0.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Subtle Decorative Blobs
          Positioned(
            top: -50,
            right: -30,
            child: _buildDecorativeBlob(250, [
              const Color(0xFF1A4D2E).withOpacity(0.04),
              const Color(0xFF1A4D2E).withOpacity(0),
            ]),
          ),
          Positioned(
            bottom: -30,
            left: -50,
            child: _buildDecorativeBlob(300, [
              Colors.teal.withOpacity(0.04),
              Colors.teal.withOpacity(0),
            ]),
          ),

          // 2. Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.grey.shade100, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => Text(
                          currentStep.value == 0
                              ? "Buat Akun"
                              : "Verifikasi OTP",
                          style: GoogleFonts.quicksand(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A4D2E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStepperIndicator(currentStep),
                      const SizedBox(height: 24),
                      Obx(
                        () =>
                            currentStep.value == 0
                                ? _buildRegisterForm(
                                  nameController,
                                  emailController,
                                  passwordController,
                                  currentStep,
                                )
                                : _buildOTPForm(
                                  emailController.text,
                                  otps,
                                  currentStep,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SharedBottomNav(
        selectedIndex: 1,
        authTabLabel: "Daftar",
        onDestinationSelected: (index) {
          if (index == 0) {
            Get.offNamed(Routes.HOME);
          }
        },
      ),
    );
  }

  Widget _buildDecorativeBlob(double size, List<Color> colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }

  Widget _buildStepperIndicator(RxInt currentStep) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _indicatorCircle(1, currentStep.value >= 0),
          _indicatorLine(currentStep.value >= 1),
          _indicatorCircle(2, currentStep.value >= 1),
        ],
      ),
    );
  }

  Widget _indicatorCircle(int step, bool active) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? const Color(0xFF1A4D2E) : Colors.grey.shade50,
        border: Border.all(
          color: active ? const Color(0xFF1A4D2E) : Colors.grey.shade300,
        ),
      ),
      child: Center(
        child: Text(
          "$step",
          style: GoogleFonts.quicksand(
            color: active ? Colors.white : Colors.grey.shade500,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _indicatorLine(bool active) {
    return Container(
      width: 32,
      height: 2,
      color: active ? const Color(0xFF1A4D2E) : Colors.grey.shade200,
    );
  }

  Widget _buildRegisterForm(
    TextEditingController name,
    TextEditingController email,
    TextEditingController password,
    RxInt currentStep,
  ) {
    return Column(
      children: [
        _buildTextField(
          "Nama Lengkap",
          Icons.person_outline,
          name,
          hintText: "masukkan nama",
        ),
        const SizedBox(height: 10),
        // Email with Autocomplete
        _buildEmailFieldWithAutocomplete(email),
        const SizedBox(height: 10),
        _buildTextField(
          "Password",
          Icons.lock_outline,
          password,
          isPasswordField: true,
          hintText: "masukkan password",
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (name.text.isEmpty ||
                  email.text.isEmpty ||
                  password.text.isEmpty) {
                return;
              }
              await controller.register(name.text, email.text, password.text);
              if (!controller.isLoading.value) {
                currentStep.value = 1;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A4D2E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 4,
            ),
            child: Obx(
              () =>
                  controller.isLoading.value
                      ? const AppLoading(
                        size: 18,
                        isCircular: true,
                        color: Colors.white,
                      )
                      : Text(
                        "LANJUT",
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sudah punya akun? ",
              style: GoogleFonts.quicksand(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            GestureDetector(
              onTap: () => Get.offNamed(Routes.LOGIN),
              child: Text(
                "Masuk",
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A4D2E),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOTPForm(
    String email,
    List<TextEditingController> otps,
    RxInt currentStep,
  ) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          "Kode dikirim ke $email",
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOTPBox(otps[index])),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              String otp = otps.map((e) => e.text).join();
              if (otp.length < 6) {
                return;
              }
              controller.verifyAndRegister(email, otp);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A4D2E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 4,
            ),
            child: Text(
              "VERIFIKASI",
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => currentStep.value = 0,
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          child: Text(
            "Kembali",
            style: GoogleFonts.quicksand(
              color: const Color(0xFF1A4D2E),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController textController, {
    bool isPasswordField = false,
    TextInputType? keyboardType,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              color: Colors.grey.shade800,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        isPasswordField
            ? Obx(
              () => TextField(
                controller: textController,
                obscureText: !controller.isPasswordVisible.value,
                keyboardType: keyboardType,
                style: GoogleFonts.quicksand(
                  color: Colors.black87,
                  fontSize: 14,
                ),
                onChanged: onChanged,
                inputFormatters: inputFormatters,
                decoration: _buildInputDecoration(icon, true, hintText),
              ),
            )
            : TextField(
              controller: textController,
              obscureText: false,
              keyboardType: keyboardType,
              style: GoogleFonts.quicksand(color: Colors.black87, fontSize: 14),
              onChanged: onChanged,
              inputFormatters: inputFormatters,
              decoration: _buildInputDecoration(icon, false, hintText),
            ),
      ],
    );
  }

  Widget _buildOTPBox(TextEditingController controller) {
    return SizedBox(
      width: 38,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.quicksand(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A4D2E), width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) Get.focusScope?.nextFocus();
        },
      ),
    );
  }

  static const List<String> _emailDomains = [
    "gmail.com",
    "yahoo.com",
    "hotmail.com",
    "outlook.com",
    "icloud.com",
    "live.com",
    "msn.com",
    "protonmail.com",
    "zoho.com",
    "mail.com",
  ];

  Widget _buildEmailFieldWithAutocomplete(
    TextEditingController textController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            "Email",
            style: GoogleFonts.quicksand(
              color: Colors.grey.shade800,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            String text = textEditingValue.text;
            if (!text.contains('@')) return const Iterable<String>.empty();

            List<String> parts = text.split('@');
            if (parts.length > 2) return const Iterable<String>.empty();

            String prefix = parts[0].toLowerCase();
            String domainPart = parts.length > 1 ? parts[1] : "";

            return _emailDomains
                .where((domain) => domain.startsWith(domainPart))
                .map((domain) => "$prefix@$domain");
          },
          onSelected: (String selection) {
            textController.text = selection;
          },
          fieldViewBuilder: (
            context,
            autoTextController,
            focusNode,
            onFieldSubmitted,
          ) {
            // Sync textController with our external controller
            if (autoTextController.text != textController.text) {
              autoTextController.text = textController.text;
            }
            autoTextController.addListener(() {
              textController.text = autoTextController.text;
            });

            return TextField(
              controller: autoTextController,
              focusNode: focusNode,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.quicksand(color: Colors.black87, fontSize: 14),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.copyWith(text: newValue.text.toLowerCase());
                }),
              ],
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.grey,
                  size: 18,
                ),
                hintText: "masukkan email",
                hintStyle: GoogleFonts.quicksand(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
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
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 300,
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return ListTile(
                        title: Text(
                          option,
                          style: GoogleFonts.quicksand(fontSize: 13),
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    IconData icon,
    bool isPasswordField,
    String? hintText,
  ) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 18),
      suffixIcon:
          isPasswordField
              ? IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
                onPressed: controller.togglePasswordVisibility,
              )
              : null,
      hintText: hintText,
      hintStyle: GoogleFonts.quicksand(
        color: Colors.grey.shade400,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        borderSide: const BorderSide(color: Color(0xFF1A4D2E), width: 1.5),
      ),
    );
  }
}
