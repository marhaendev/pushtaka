import 'package:get/get.dart';
import '../../../../injection_container.dart';
import '../controllers/user_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserController(repository: sl()));
  }
}
