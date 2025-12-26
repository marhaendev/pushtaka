import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../../data/models/transaction_settings_model.dart';

abstract class TransactionRepository {
  Future<Either<Failure, void>> borrowBook(int bookId);
  Future<Either<Failure, void>> returnBook(int bookId, {int? userId});
  Future<Either<Failure, List<Transaction>>> getHistory();
  Future<Either<Failure, List<Transaction>>> getAllTransactions();
  Future<Either<Failure, TransactionSettingsModel>> getSettings();
  Future<Either<Failure, void>> updateSettings(
    TransactionSettingsModel settings,
  );
  Future<Either<Failure, Map<String, dynamic>>> payFine(
    int transactionId, {
    required String method,
    String? proof,
  });
}
