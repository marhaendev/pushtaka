import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/book.dart';

abstract class BookRepository {
  Future<Either<Failure, List<Book>>> getBooks();
  Future<Either<Failure, Book>> getBookDetail(int id);
  Future<Either<Failure, void>> addBook(Map<String, dynamic> data);
  Future<Either<Failure, void>> updateBook(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteBook(int id);
  Future<Either<Failure, List<Book>>> getFavorites();
  Future<Either<Failure, void>> addFavorite(int bookId);
  Future<Either<Failure, void>> removeFavorite(int bookId);
}
