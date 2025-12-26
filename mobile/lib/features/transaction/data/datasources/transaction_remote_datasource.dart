import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/transaction_model.dart';
import '../models/transaction_settings_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getHistory();
  Future<List<TransactionModel>> getAllTransactions();
  Future<void> borrowBook(int bookId);
  Future<void> returnBook(int bookId, {int? userId});
  Future<TransactionSettingsModel> getSettings();
  Future<void> updateSettings(TransactionSettingsModel settings);
  Future<Map<String, dynamic>> payFine(
    int transactionId, {
    required String method,
    String? proof,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final DioClient dioClient;

  TransactionRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<TransactionModel>> getHistory() async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.transactions + "/history",
      ); // Verify Endpoint
      // Endpoint from docs logic: "3. Riwayat Transaksi (Pribadi) -> /transactions/history"

      final List data = response.data['data'] ?? [];
      return data.map((e) => TransactionModel.fromJson(e)).toList();
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Load History Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.transactions);
      final List data = response.data['data'] ?? [];
      return data.map((e) => TransactionModel.fromJson(e)).toList();
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ??
          'Load Transactions Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> borrowBook(int bookId) async {
    try {
      final response = await dioClient.dio.post(
        "${ApiConstants.borrow}/$bookId",
      );

      // Check if response body has error status
      if (response.data != null && response.data['status'] == 'error') {
        final msg = response.data['message']?.toString() ?? 'Borrow Failed';
        throw Exception(msg);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? 'Borrow Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> returnBook(int bookId, {int? userId}) async {
    try {
      final response = await dioClient.dio.post(
        "${ApiConstants.returnBook}/$bookId",
        queryParameters: userId != null ? {'user_id': userId} : null,
      );

      // Check if response body has error status
      if (response.data != null && response.data['status'] == 'error') {
        final msg = response.data['message']?.toString() ?? 'Return Failed';
        throw Exception(msg);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? 'Return Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<TransactionSettingsModel> getSettings() async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.transactionsSettings,
      );
      return TransactionSettingsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Load Settings Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> updateSettings(TransactionSettingsModel settings) async {
    try {
      await dioClient.dio.post(
        ApiConstants.transactionsSettings,
        data: settings.toJson(),
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Update Settings Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<Map<String, dynamic>> payFine(
    int transactionId, {
    required String method,
    String? proof,
  }) async {
    try {
      final response = await dioClient.dio.post(
        "${ApiConstants.transactions}/pay-fine/$transactionId",
        data: {'method': method, if (proof != null) 'proof': proof},
      );

      if (response.data != null && response.data['status'] == 'error') {
        final msg = response.data['message']?.toString() ?? 'Payment Failed';
        throw Exception(msg);
      }

      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? 'Payment Failed';
      throw Exception(msg);
    }
  }
}
