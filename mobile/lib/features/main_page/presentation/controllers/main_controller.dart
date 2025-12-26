import 'package:get/get.dart';

class MainController extends GetxController {
  var tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Check if redirecting from Detail Page (Return Book)
    if (Get.arguments != null && Get.arguments is String) {
      tabIndex.value = 1; // Switch to History Tab
    }
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
