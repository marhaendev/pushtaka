import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../../../features/book/presentation/controllers/book_controller.dart';
import '../../../../features/transaction/presentation/controllers/transaction_controller.dart';
import '../../../../features/user/presentation/controllers/user_controller.dart';
import '../../../../injection_container.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    // Also inject downstream controllers so tabs work immediately
    Get.lazyPut<BookController>(() => BookController(repository: sl()));
    Get.lazyPut<TransactionController>(
      () => TransactionController(repository: sl()),
    );
    Get.lazyPut<UserController>(() => UserController(repository: sl()));
  }
}
