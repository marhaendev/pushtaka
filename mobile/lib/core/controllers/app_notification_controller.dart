import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppNotificationController extends GetxController {
  static AppNotificationController get to => Get.find();

  final isVisible = false.obs;
  final message = "".obs;
  final icon = Icons.check_circle_outline.obs;
  final color = const Color(0xFF1A4D2E).obs;

  void show({
    required String message,
    IconData icon = Icons.check_circle_outline,
    Color color = const Color(0xFF1A4D2E),
  }) {
    this.message.value = message;
    this.icon.value = icon;
    this.color.value = color;
    isVisible.value = true;
  }

  void showSuccess(String message) {
    show(
      message: message,
      icon: Icons.check_circle_outline,
      color: const Color(0xFF1A4D2E),
    );
  }

  void showError(String message) {
    show(
      message: message,
      icon: Icons.error_outline,
      color: Colors.red.shade700,
    );
  }

  void hide() {
    isVisible.value = false;
  }
}
