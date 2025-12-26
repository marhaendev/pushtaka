import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> register(
    String name,
    String email,
    String password,
  );
  Future<Either<Failure, void>> verifyOtp(
    String email,
    String otp,
    String purpose,
  );
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, String>> verifyResetOtp(String email, String otp);
  Future<Either<Failure, void>> resetPassword(String token, String newPassword);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> updateProfile(String name, String email);
  Future<Either<Failure, List<User>>> getUsers();
}
