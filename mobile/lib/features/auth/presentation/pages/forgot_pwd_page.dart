import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/widgets/app_loading.dart';

class ForgotPwdPage extends GetView<AuthController> {
  const ForgotPwdPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Lupa Password?",
              style: GoogleFonts.quicksand(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A4D2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Masukkan email Anda untuk menerima kode OTP verifikasi.",
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 48),
            _buildEmailFieldWithAutocomplete(emailController),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : () =>
                              controller.forgotPassword(emailController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A4D2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                            "KIRIM KODE OTP",
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
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
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                Get.focusScope?.unfocus();
              },
              style: GoogleFonts.quicksand(color: Colors.black87, fontSize: 14),
              inputFormatters: [
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
                hintText: "masukkan email terdaftar",
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
}
