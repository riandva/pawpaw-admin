import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'config/admin_theme.dart';
import 'controllers/admin_dashboard_controller.dart';
import 'services/admin_notification_service.dart';
import 'views/admin_main_screen.dart';
import 'views/landing/admin_landing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kDebugMode) {
      await dotenv.load(fileName: ".env.dev");
    } else {
      await dotenv.load(fileName: ".env.prod");
    }
  } catch (e) {
    debugPrint("Dotenv loading error: $e");
    try {
      await dotenv.load(fileName: ".env.dev");
    } catch (_) {}
  }

  // Initialize Firebase Cloud Messaging for Push Notifications on Tablet / Mobile
  await AdminNotificationService().initialize();

  Get.put(AdminDashboardController());

  runApp(const PawPawAdminApp());
}

class PawPawAdminApp extends StatelessWidget {
  const PawPawAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AdminDashboardController>()
        ? Get.find<AdminDashboardController>()
        : Get.put(AdminDashboardController());

    return GetMaterialApp(
      title: 'PawPaw Admin Console',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.lightTheme,
      home: Obx(() {
        if (controller.isLoggedIn.value) {
          return const AdminMainScreen();
        }
        return const AdminLandingScreen();
      }),
    );
  }
}
