import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_datasource.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    try {
      final books = await remoteDataSource.getBooks();
      return Right(books);
    } catch (e, stackTrace) {
      debugPrint("BookRepository Error: $e");
      debugPrint(stackTrace.toString());
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book>> getBookDetail(int id) async {
    try {
      final book = await remoteDataSource.getBookDetail(id);
      return Right(book);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addBook(Map<String, dynamic> data) async {
    try {
      await remoteDataSource.addBook(data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBook(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      await remoteDataSource.updateBook(id, data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBook(int id) async {
    try {
      await remoteDataSource.deleteBook(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getFavorites() async {
    try {
      final books = await remoteDataSource.getFavorites();
      return Right(books);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(int bookId) async {
    try {
      await remoteDataSource.addFavorite(bookId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(int bookId) async {
    try {
      await remoteDataSource.removeFavorite(bookId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
