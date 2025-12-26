import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pushtaka/core/network/dio_client.dart' show DioClient;
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<void> verifyOTP(String email, String otp);
  Future<void> forgotPassword(String email);
  Future<String> verifyResetOTP(String email, String otp);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> updateProfile(String name, String email);
  Future<List<UserModel>> getUsers();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data['data'];

      if (data['user'] != null && data['user'] is Map) {
        final userMap = Map<String, dynamic>.from(data['user']);
        if (data['token'] != null) {
          userMap['token'] = data['token'];
        }
        return UserModel.fromJson(userMap);
      }

      return UserModel.fromJson(data);
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? 'Login Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> register(String name, String email, String password) async {
    try {
      await dioClient.dio.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? 'Register Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> verifyOTP(String email, String otp) async {
    try {
      await dioClient.dio.post(
        ApiConstants.verifyOTP,
        data: {'email': email, 'otp': otp, 'purpose': 'register'},
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Verify OTP Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await dioClient.dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Forgot Password Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<String> verifyResetOTP(String email, String otp) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.verifyOTP,
        data: {'email': email, 'otp': otp, 'purpose': 'reset_password'},
      );
      final token = response.data['data']['token'];
      return token.toString();
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Verify OTP Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await dioClient.dio.post(
        ApiConstants.resetPassword,
        data: {'token': token, 'new_password': newPassword},
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Reset Password Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> updateProfile(String name, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        throw Exception("Authentication required");
      }

      await dioClient.dio.put(
        ApiConstants.profile,
        data: {'name': name},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Update Profile Failed';
      throw Exception(msg);
    }
  }

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception("Authentication required");
      }

      final response = await dioClient.dio.get(
        ApiConstants.users,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List data = response.data['data'];
      return data.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ?? 'Fetch Users Failed';
      throw Exception(msg);
    }
  }
}
