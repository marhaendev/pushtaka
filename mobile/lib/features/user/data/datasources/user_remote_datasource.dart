import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers({int limit = 10, int offset = 0});
  Future<UserModel> getUserDetail(int id);
  Future<void> createUser(Map<String, dynamic> data);
  Future<void> updateUser(int id, Map<String, dynamic> data);
  Future<void> deleteUser(int id, {bool permanent = false});
  Future<void> deleteUserBatch(List<int> ids);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient dioClient;

  UserRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<UserModel>> getUsers({int limit = 10, int offset = 0}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      print("DEBUG: Fetching users from ${ApiConstants.users}");
      print("DEBUG: Token: $token");

      final response = await dioClient.dio.get(
        ApiConstants.users,
        queryParameters: {'limit': limit, 'offset': offset},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("DEBUG: Response: ${response.data}");

      final dynamic dataObj = response.data['data'];
      if (dataObj is List) {
        return dataObj.map((e) => UserModel.fromJson(e)).toList();
      } else if (dataObj is Map && dataObj['data'] is List) {
        return (dataObj['data'] as List)
            .map((e) => UserModel.fromJson(e))
            .toList();
      } else if (dataObj is Map && dataObj['users'] is List) {
        // Just in case it's nested under 'users'
        return (dataObj['users'] as List)
            .map((e) => UserModel.fromJson(e))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Load Users Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<UserModel> getUserDetail(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final response = await dioClient.dio.get(
        "${ApiConstants.users}/$id",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data['data'];
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Load User Detail Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> createUser(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      await dioClient.dio.post(
        ApiConstants.users,
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Create User Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      await dioClient.dio.put(
        "${ApiConstants.users}/$id",
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Update User Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> deleteUser(int id, {bool permanent = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      await dioClient.dio.delete(
        "${ApiConstants.users}/$id",
        queryParameters: permanent ? {'permanent': true} : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Delete User Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> deleteUserBatch(List<int> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      await dioClient.dio.delete(
        ApiConstants.users,
        data: {'ids': ids},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ??
          'Batch Delete Users Failed';
      throw Exception(msg);
    }
  }
}
