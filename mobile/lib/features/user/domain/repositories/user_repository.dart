import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, List<User>>> getUsers({
    int limit = 10,
    int offset = 0,
  });
  Future<Either<Failure, User>> getUserDetail(int id);
  Future<Either<Failure, void>> createUser(Map<String, dynamic> userData);
  Future<Either<Failure, void>> updateUser(
    int id,
    Map<String, dynamic> userData,
  );
  Future<Either<Failure, void>> deleteUser(int id, {bool permanent = false});
  Future<Either<Failure, void>> deleteUserBatch(List<int> ids);
}
