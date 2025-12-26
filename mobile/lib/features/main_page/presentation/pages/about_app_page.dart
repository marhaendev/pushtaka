import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://pushtaka.xapi.my.id');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        "Kesalahan",
        "Tidak dapat membuka website",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Tentang Aplikasi",
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  "assets/icon.png",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "PUSHTAKA",
              style: GoogleFonts.merriweather(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A4D2E),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Manajemen Perpustakaan",
              style: GoogleFonts.sourceCodePro(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6), // Dimmed grey
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 40),
            _buildInfoRow("Versi Aplikasi", "1.0.0"),
            _buildInfoRow("Developer", "Hasan Askari"),
            _buildInfoRow(
              "Website",
              "pushtaka.xapi.my.id",
              onTap: _launchURL,
              isLink: true,
            ),
            _buildInfoRow("Kontak", "hasanaskari.id@gmail.com"),
            const SizedBox(height: 40),
            Text(
              "© ${_getCopyrightYear()} Pushtaka. All Rights Reserved.",
              style: GoogleFonts.sourceCodePro(
                fontSize: 10,
                color: Colors.black.withOpacity(0.4), // More dimmed grey
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    VoidCallback? onTap,
    bool isLink = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.sourceCodePro(
                color: Colors.black.withOpacity(0.6), // Dimmed grey
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.sourceCodePro(
                    color: isLink ? Colors.blue.shade700 : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                if (isLink) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 12,
                    color: Colors.blue.shade700,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCopyrightYear() {
    final int startYear = 2025;
    final int currentYear = DateTime.now().year;
    if (currentYear <= startYear) {
      return startYear.toString();
    } else {
      return "$startYear - $currentYear";
    }
  }
}
