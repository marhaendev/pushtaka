import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<User>>> getUsers({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final remoteUsers = await remoteDataSource.getUsers(
        limit: limit,
        offset: offset,
      );
      return Right(remoteUsers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserDetail(int id) async {
    try {
      final remoteUser = await remoteDataSource.getUserDetail(id);
      return Right(remoteUser);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createUser(
    Map<String, dynamic> userData,
  ) async {
    try {
      await remoteDataSource.createUser(userData);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(
    int id,
    Map<String, dynamic> userData,
  ) async {
    try {
      await remoteDataSource.updateUser(id, userData);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(
    int id, {
    bool permanent = false,
  }) async {
    try {
      await remoteDataSource.deleteUser(id, permanent: permanent);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserBatch(List<int> ids) async {
    try {
      await remoteDataSource.deleteUserBatch(ids);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
