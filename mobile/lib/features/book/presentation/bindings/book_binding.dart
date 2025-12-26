import 'package:get/get.dart';
import '../../../../injection_container.dart';
import '../controllers/book_controller.dart';

class BookBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookController>(() => BookController(repository: sl()));
  }
}
