import 'package:get/get.dart';
import '../../../../injection_container.dart';
import '../controllers/transaction_controller.dart';

class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionController>(
      () => TransactionController(repository: sl()),
    );
  }
}
