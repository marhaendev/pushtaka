import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? "https://pushtaka.xapi.my.id";

  // Auth
  static String get login => "$baseUrl/auth/login";
  static String get register => "$baseUrl/auth/register";
  static String get verifyOTP => '$baseUrl/auth/verify-otp';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get resetPassword => '$baseUrl/auth/reset-password';
  static String get verifyOtp => "$baseUrl/auth/verify-otp";
  static String get profile => "$baseUrl/profile";

  // Books
  static String get books => "$baseUrl/books";

  // Users
  static String get users => "$baseUrl/users";

  // Transactions
  static String get transactions => "$baseUrl/transactions";
  static String get borrow => "$baseUrl/transactions/borrow";
  static String get returnBook => "$baseUrl/transactions/return";
  static String get transactionsSettings => "$baseUrl/transactions/settings";

  // Google Books
  static String get googleBooks =>
      dotenv.env['GOOGLE_BOOKS_API_URL'] ??
      "https://www.googleapis.com/books/v1/volumes";

  // Open Library
  static String get openLibrary =>
      dotenv.env['OPEN_LIBRARY_API_URL'] ??
      "https://openlibrary.org/search.json";
  static String get openLibraryCover =>
      dotenv.env['OPEN_LIBRARY_COVER_URL'] ??
      "https://covers.openlibrary.org/b";
}
