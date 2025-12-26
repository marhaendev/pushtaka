import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/routes/app_pages.dart';

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({super.key});

  void _onIntroEnd(context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_intro', true);
    Get.offAllNamed(Routes.HOME);
  }

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: GoogleFonts.merriweather(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A4D2E),
      ),
      bodyTextStyle: GoogleFonts.poppins(fontSize: 16.0, color: Colors.black54),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: const EdgeInsets.only(top: 10, bottom: 20),
      imageFlex: 1,
    );

    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: true,
      autoScrollDuration: 30000,
      pages: [
        PageViewModel(
          title: "Selamat Datang di Pushtaka",
          body:
              "Aplikasi manajemen perpustakaan yang memudahkan Anda mengelola peminjaman buku.",
          image: _buildImage(Icons.library_books),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Koleksi Buku Lengkap",
          body:
              "Temukan ribuan buku dari berbagai kategori. Cari, pilih, dan pinjam buku favorit Anda dalam sekejap.",
          image: _buildImage(Icons.search),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Kelola Peminjaman",
          body:
              "Pantau status peminjaman, tanggal pengembalian, dan riwayat baca Anda dengan mudah.",
          image: _buildImage(Icons.manage_history),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Mulai Membaca",
          body:
              "Tunggu apa lagi? Mari mulai petualangan literasi Anda bersama Pushtaka sekarang!",
          image: _buildImage(Icons.rocket_launch),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back, color: Color(0xFF1A4D2E)),
      skip: const Text(
        'Lewati',
        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A4D2E)),
      ),
      next: const Icon(Icons.arrow_forward, color: Color(0xFF1A4D2E)),
      done: const Text(
        'Mulai',
        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A4D2E)),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeColor: Color(0xFF1A4D2E),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  Widget _buildImage(IconData icon) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF1A4D2E).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 80, color: const Color(0xFF1A4D2E)),
    );
  }
}
