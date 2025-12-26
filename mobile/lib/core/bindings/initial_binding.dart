import 'package:get/get.dart';
import '../../injection_container.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/app_notification_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Register Global Controllers
    Get.put<AuthController>(AuthController(repository: sl()), permanent: true);
    Get.put<AppNotificationController>(
      AppNotificationController(),
      permanent: true,
    );
  }
}
