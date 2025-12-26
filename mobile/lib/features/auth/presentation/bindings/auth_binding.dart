import 'package:get/get.dart';
import '../../../../injection_container.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(repository: sl()));
  }
}
