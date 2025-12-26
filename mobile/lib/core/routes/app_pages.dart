import 'package:get/get.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/forgot_pwd_page.dart';
import '../../features/auth/presentation/pages/forgot_pwd_otp_page.dart';
import '../../features/auth/presentation/pages/reset_pwd_page.dart';
import '../../features/auth/presentation/pages/change_pwd_page.dart';
import '../../features/auth/presentation/pages/edit_profile_page.dart';
import '../../features/user/presentation/pages/user_list_page.dart';
import '../../features/user/presentation/bindings/user_binding.dart';
import '../../features/book/presentation/pages/book_management_page.dart';
import '../../features/book/presentation/pages/book_detail_page.dart';
import '../../features/book/presentation/pages/book_form_page.dart';

import '../../features/main_page/presentation/pages/main_page.dart';
import '../../features/main_page/presentation/bindings/main_binding.dart';

import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/book/presentation/bindings/book_binding.dart';
import '../../features/intro/presentation/pages/introduction_page.dart';
import '../../features/main_page/presentation/pages/about_app_page.dart';
import '../../features/transaction/presentation/pages/transaction_page.dart';
import '../../features/transaction/presentation/pages/transaction_settings_page.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    // Main (Bottom Nav)
    GetPage(
      name: Routes.HOME,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),

    // Auth
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(name: Routes.PROFILE, page: () => const ProfilePage()),
    GetPage(
      name: Routes.USER_MANAGEMENT,
      page: () => const UserListPage(),
      binding: UserBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PWD,
      page: () => const ForgotPwdPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_OTP,
      page: () => const ForgotPwdOtpPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.RESET_PWD,
      page: () => const ResetPwdPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.CHANGE_PWD,
      page: () => const ChangePwdPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfilePage(),
      binding: AuthBinding(),
    ),

    // Book
    GetPage(
      name: Routes.BOOK_MANAGEMENT,
      page: () => const BookManagementPage(),
      binding: BookBinding(),
    ),
    GetPage(name: Routes.BOOK_DETAIL, page: () => const BookDetailPage()),
    GetPage(
      name: Routes.BOOK_FORM,
      page: () {
        final book = Get.arguments;
        return BookFormPage(book: book);
      },
      binding: BookBinding(),
    ),
    GetPage(name: Routes.INTRODUCTION, page: () => const IntroductionPage()),
    GetPage(name: Routes.ABOUT_APP, page: () => const AboutAppPage()),
    GetPage(name: Routes.TRANSACTIONS, page: () => const TransactionPage()),
    GetPage(
      name: Routes.TRANSACTION_SETTINGS,
      page: () => const TransactionSettingsPage(),
    ),
  ];
}
