import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../../core/widgets/shared_bottom_nav.dart';
import '../../../../core/widgets/app_loading.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController controller = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Worker? _emailWorker;
  TextEditingController? _autocompleteController;

  @override
  void initState() {
    super.initState();
    // Listen for changes from dropdown
    _emailWorker = ever(controller.selectedEmail, (String val) {
      if (val.isNotEmpty && _autocompleteController != null) {
        if (_autocompleteController!.text != val) {
          _autocompleteController!.text = val;
        }
        controller.selectedEmail.value = ""; // Clear after sync
      }
    });
  }

  @override
  void dispose() {
    _emailWorker?.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
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
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A4D2E).withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 30,
                        color: Color(0xFF1A4D2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Pushtaka",
                      style: GoogleFonts.quicksand(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A4D2E),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      "Manajemen Perpustakaan",
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildEmailFieldWithAutocomplete(),
                    const SizedBox(height: 12),
                    _buildThemeTextField(
                      textController: passwordController,
                      label: "Password",
                      icon: Icons.lock_outline,
                      isPasswordField: true,
                      hintText: "masukkan password",
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      onSubmitted: (_) {
                        controller.login(
                          emailController.text,
                          passwordController.text,
                        );
                      },
                    ),

                    _buildSavedAccountsDropdown(),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Transform.scale(
                            scale: 0.8,
                            child: Obx(
                              () => Checkbox(
                                value: controller.isRememberMe.value,
                                onChanged: (_) => controller.toggleRememberMe(),
                                activeColor: const Color(0xFF1A4D2E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.toggleRememberMe(),
                            child: Text(
                              "Ingat Saya",
                              style: GoogleFonts.quicksand(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Obx(
                      () =>
                          controller.loginErrorMessage.value.isEmpty
                              ? const SizedBox(height: 8)
                              : Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        controller.loginErrorMessage.value,
                                        style: GoogleFonts.quicksand(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : () {
                                    controller.login(
                                      emailController.text,
                                      passwordController.text,
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A4D2E),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: const Color(
                              0xFF1A4D2E,
                            ).withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
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
                                    "MASUK",
                                    style: GoogleFonts.quicksand(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Get.toNamed(Routes.FORGOT_PWD),
                          child: Text(
                            "Lupa Password?",
                            style: GoogleFonts.quicksand(
                              color: const Color(0xFF1A4D2E),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(Routes.REGISTER),
                          child: Text(
                            "Daftar",
                            style: GoogleFonts.quicksand(
                              color: const Color(0xFF1A4D2E),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SharedBottomNav(
        selectedIndex: 1,
        authTabLabel: "Masuk",
        onDestinationSelected: (index) {
          if (index == 0) Get.offNamed(Routes.HOME);
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

  Widget _buildThemeTextField({
    required TextEditingController textController,
    required String label,
    required IconData icon,
    bool isPasswordField = false,
    TextInputType? keyboardType,
    String? hintText,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onSubmitted,
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
        isPasswordField
            ? Obx(
              () => TextField(
                controller: textController,
                obscureText: !controller.isPasswordVisible.value,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                inputFormatters: inputFormatters,
                onSubmitted: onSubmitted,
                style: GoogleFonts.quicksand(
                  color: Colors.black87,
                  fontSize: 14,
                ),
                decoration: _buildInputDecoration(icon, true, hintText),
              ),
            )
            : TextField(
              controller: textController,
              obscureText: false,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              style: GoogleFonts.quicksand(color: Colors.black87, fontSize: 14),
              decoration: _buildInputDecoration(icon, false, hintText),
            ),
      ],
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

  Widget _buildEmailFieldWithAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            "Email",
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue val) {
            String text = val.text;
            if (!text.contains('@')) return const Iterable<String>.empty();
            List<String> parts = text.split('@');
            if (parts.length > 2) return const Iterable<String>.empty();
            String prefix = parts[0].toLowerCase();
            String domainPart = parts.length > 1 ? parts[1] : "";
            return _emailDomains
                .where((domain) => domain.startsWith(domainPart))
                .map((domain) => "$prefix@$domain");
          },
          onSelected: (String sel) => emailController.text = sel,
          fieldViewBuilder: (context, autoCtrl, focus, onSub) {
            _autocompleteController = autoCtrl;
            autoCtrl.addListener(() => emailController.text = autoCtrl.text);
            return TextField(
              controller: autoCtrl,
              focusNode: focus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => Get.focusScope?.nextFocus(),
              style: GoogleFonts.quicksand(color: Colors.black87, fontSize: 14),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                TextInputFormatter.withFunction(
                  (old, newV) => newV.copyWith(text: newV.text.toLowerCase()),
                ),
              ],
              decoration: _buildInputDecoration(
                Icons.email_outlined,
                false,
                "masukkan email",
              ),
            );
          },
          optionsViewBuilder: (context, onSel, options) {
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
                    itemBuilder: (ctx, idx) {
                      final opt = options.elementAt(idx);
                      return ListTile(
                        title: Text(
                          opt,
                          style: GoogleFonts.quicksand(fontSize: 13),
                        ),
                        onTap: () => onSel(opt),
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
    bool isPwd,
    String? hint,
  ) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 18),
      suffixIcon:
          isPwd
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
      hintText: hint,
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

  Widget _buildSavedAccountsDropdown() {
    return Obx(() {
      if (controller.savedAccounts.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                "Akun Tersimpan",
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: PopupMenuButton<Map<String, String>>(
                offset: const Offset(0, 50),
                position: PopupMenuPosition.under,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pilih akun...",
                        style: GoogleFonts.quicksand(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                onSelected: (account) {
                  controller.selectedEmail.value = account['email'] ?? "";
                  passwordController.text = account['password'] ?? "";
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                itemBuilder:
                    (ctx) =>
                        controller.savedAccounts
                            .map(
                              (account) => PopupMenuItem(
                                value: account,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        account['email'] ?? "",
                                        style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        controller.removeAccount(
                                          account['email'] ?? "",
                                        );
                                        Get.back();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
              ),
            ),
          ],
        ),
      );
    });
  }
}
