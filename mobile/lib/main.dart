import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/bindings/initial_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/controllers/app_notification_controller.dart';
import 'core/widgets/app_notification_alert.dart';
import 'injection_container.dart' as di;

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await di.init();

  final prefs = di.sl<SharedPreferences>();
  final hasSeenIntro = prefs.getBool('has_seen_intro') ?? false;

  runApp(MyApp(initialRoute: hasSeenIntro ? Routes.HOME : Routes.INTRODUCTION));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pushtaka',
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            // Global Notification Alert
            Obx(() {
              final notification = Get.find<AppNotificationController>();
              if (!notification.isVisible.value) {
                return const SizedBox.shrink();
              }
              return Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween(begin: -80.0, end: 0.0),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: AppNotificationAlert(
                        message: notification.message.value,
                        icon: notification.icon.value,
                        color: notification.color.value,
                        onDismiss: () => notification.hide(),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
