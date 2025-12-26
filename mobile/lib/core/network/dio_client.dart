import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../core/controllers/app_notification_controller.dart';
import '../../core/routes/app_pages.dart';
import '../constants/api_constants.dart';

class DioClient {
  late Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) => status! < 400, // 4xx and 5xx are errors
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            try {
              // Try to find AuthController
              if (Get.isRegistered<AuthController>()) {
                final authController = Get.find<AuthController>();
                if (authController.isLoggedIn.value) {
                  AppNotificationController.to.showError(
                    "Sesi berakhir, silakan login kembali",
                  );
                  await authController.logout();
                }
              } else {
                // Fallback if controller not registered
                Get.offAllNamed(Routes.LOGIN);
              }
            } catch (_) {
              Get.offAllNamed(Routes.LOGIN);
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}
