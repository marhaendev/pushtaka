import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SharedBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final bool showTransactionTab;
  final bool isAdmin;
  final String? authTabLabel; // "Masuk" or "Daftar" for auth pages

  const SharedBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.showTransactionTab = false,
    this.isAdmin = false,
    this.authTabLabel,
  });

  @override
  Widget build(BuildContext context) {
    List<NavigationDestination> destinations = [
      const NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: "Discover",
      ),
    ];

    // Add transaction tab if logged in
    if (showTransactionTab) {
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: "Transaksi",
        ),
      );
    }

    // Add User Management tab if Admin
    if (isAdmin && showTransactionTab) {
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.manage_accounts_outlined),
          selectedIcon: Icon(Icons.manage_accounts),
          label: "User",
        ),
      );
    }

    // Add auth or profile tab
    if (authTabLabel != null) {
      // Auth pages (Login/Register)
      destinations.add(
        NavigationDestination(
          icon: Icon(authTabLabel == "Masuk" ? Icons.login : Icons.how_to_reg),
          selectedIcon: Icon(
            authTabLabel == "Masuk" ? Icons.login : Icons.how_to_reg,
          ),
          label: authTabLabel!,
        ),
      );
    } else if (showTransactionTab) {
      // Main page with login (has all tabs)
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.account_circle_outlined),
          selectedIcon: Icon(Icons.account_circle_rounded),
          label: "Profil",
        ),
      );
    } else {
      // Main page without login (Discover + Masuk)
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.login),
          selectedIcon: Icon(Icons.login),
          label: "Masuk",
        ),
      );
    }

    // Safe selectedIndex check
    final int safeIndex =
        selectedIndex >= 0 && selectedIndex < destinations.length
            ? selectedIndex
            : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: const Color(0xFF1A4D2E).withOpacity(0.1),
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF1A4D2E), size: 20);
            }
            return const IconThemeData(color: Colors.grey, size: 20);
          }),
        ),
        child: NavigationBar(
          height: 55,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          selectedIndex: safeIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations,
        ),
      ),
    );
  }
}
