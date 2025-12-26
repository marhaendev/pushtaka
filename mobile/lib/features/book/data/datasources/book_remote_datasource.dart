import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> getBooks();
  Future<BookModel> getBookDetail(int id);
  Future<void> addBook(Map<String, dynamic> data);
  Future<void> updateBook(int id, Map<String, dynamic> data);
  Future<void> deleteBook(int id);
  Future<List<BookModel>> getFavorites();
  Future<void> addFavorite(int bookId);
  Future<void> removeFavorite(int bookId);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final DioClient dioClient;

  BookRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<BookModel>> getBooks() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.books);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      // API Response: { "data": [ ... ] }
      final List data = response.data['data'];
      return data.map((e) => BookModel.fromJson(e)).toList();
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Load Books Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<BookModel> getBookDetail(int id) async {
    try {
      final response = await dioClient.dio.get("${ApiConstants.books}/$id");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      final data = response.data['data'];
      return BookModel.fromJson(data);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Load Book Detail Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> addBook(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.dio.post(ApiConstants.books, data: data);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? 'Add Book Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> updateBook(int id, Map<String, dynamic> data) async {
    try {
      final response = await dioClient.dio.put(
        "${ApiConstants.books}/$id",
        data: data,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Update Book Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> deleteBook(int id) async {
    try {
      final response = await dioClient.dio.delete("${ApiConstants.books}/$id");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Delete Book Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<List<BookModel>> getFavorites() async {
    try {
      final response = await dioClient.dio.get("/favorites");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      final List data = response.data['data'];
      return data.map((e) => BookModel.fromJson(e)).toList();
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Load Favorites Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> addFavorite(int bookId) async {
    try {
      final response = await dioClient.dio.post("/favorites/$bookId");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Add Favorite Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> removeFavorite(int bookId) async {
    try {
      final response = await dioClient.dio.delete("/favorites/$bookId");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Remove Favorite Failed';
      throw Exception(msg);
    }
  }
}
