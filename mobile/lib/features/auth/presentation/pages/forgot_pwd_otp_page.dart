import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/widgets/app_loading.dart';

class ForgotPwdOtpPage extends StatefulWidget {
  const ForgotPwdOtpPage({super.key});

  @override
  State<ForgotPwdOtpPage> createState() => _ForgotPwdOtpPageState();
}

class _ForgotPwdOtpPageState extends State<ForgotPwdOtpPage> {
  final AuthController controller = Get.find<AuthController>();
  late List<TextEditingController> otpControllers;
  late List<FocusNode> otpFocusNodes;

  @override
  void initState() {
    super.initState();
    otpControllers = List.generate(6, (index) => TextEditingController());
    otpFocusNodes = List.generate(6, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.mark_email_read_outlined,
              size: 80,
              color: const Color(0xFF1A4D2E).withOpacity(0.8),
            ),
            const SizedBox(height: 24),
            Text(
              "Verifikasi Email",
              style: GoogleFonts.quicksand(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A4D2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Masukkan 6 digit kode OTP yang dikirim ke:",
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            Obx(
              () => Text(
                controller.resetEmail.value,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => _buildOTPBox(
                  context,
                  otpControllers[index],
                  otpFocusNodes[index],
                  index,
                  otpFocusNodes,
                  otpControllers,
                ),
              ),
            ),
            Obx(() {
              if (controller.otpErrorMessage.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    controller.otpErrorMessage.value,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : () {
                            String otp =
                                otpControllers.map((e) => e.text).join();
                            if (otp.length == 6) {
                              controller.verifyResetOtp(otp);
                            }
                          },
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
                            "VERIFIKASI",
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

  Widget _buildOTPBox(
    BuildContext context,
    TextEditingController textController,
    FocusNode focusNode,
    int index,
    List<FocusNode> focusNodes,
    List<TextEditingController> controllers,
  ) {
    return SizedBox(
      width: 45,
      child: RawKeyboardListener(
        focusNode: FocusNode(), // Dummy node to capture raw keys
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.backspace) {
              if (textController.text.isEmpty && index > 0) {
                // If current is empty and backspace pressed, move to previous
                FocusScope.of(context).requestFocus(focusNodes[index - 1]);
              }
            }
          }
        },
        child: TextField(
          controller: textController,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: GoogleFonts.quicksand(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
              borderSide: const BorderSide(
                color: Color(0xFF1A4D2E),
                width: 1.5,
              ),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < 5) {
                FocusScope.of(context).requestFocus(focusNodes[index + 1]);
              } else {
                focusNode.unfocus();
              }
            } else {
              // If cleared (backspace on char), move back
              if (index > 0) {
                FocusScope.of(context).requestFocus(focusNodes[index - 1]);
              }
            }
          },
        ),
      ),
    );
  }
}
