part of 'app_pages.dart';

abstract class Routes {
  // Public
  static const HOME = '/'; // Daftar Buku (Public)
  static const BOOK_DETAIL = '/book-detail';

  // Auth
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const PROFILE = '/profile';
  static const FORGOT_PWD = '/forgot-password';
  static const FORGOT_OTP = '/forgot-otp';
  static const RESET_PWD = '/reset-password';
  static const CHANGE_PWD = '/change-password';
  static const EDIT_PROFILE = '/edit-profile';

  // Admin
  static const USER_MANAGEMENT = '/users';
  static const BOOK_MANAGEMENT = '/books-admin'; // CRUD Buku
  static const BOOK_FORM = '/book-form';

  // Transaction
  static const TRANSACTIONS = '/transactions';
  static const TRANSACTION_SETTINGS = '/transactions/settings';
  static const INTRODUCTION = '/introduction';
  static const ABOUT_APP = '/about-app';
}
