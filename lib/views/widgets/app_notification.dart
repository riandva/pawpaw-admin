import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppNotificationType { success, error, info, warning }

class AppNotification {
  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      type: AppNotificationType.success,
      duration: duration,
    );
  }

  static void showError({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      title: title,
      message: message,
      type: AppNotificationType.error,
      duration: duration,
    );
  }

  static void showInfo({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      type: AppNotificationType.info,
      duration: duration,
    );
  }

  static void showWarning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      type: AppNotificationType.warning,
      duration: duration,
    );
  }

  static void show({
    required String title,
    required String message,
    AppNotificationType type = AppNotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    IconData icon;
    Color iconColor;

    switch (type) {
      case AppNotificationType.success:
        icon = Icons.check_circle_rounded;
        iconColor = const Color(0xFF10B981); // Emerald
        break;
      case AppNotificationType.error:
        icon = Icons.error_rounded;
        iconColor = const Color(0xFFEF4444); // Red
        break;
      case AppNotificationType.warning:
        icon = Icons.warning_rounded;
        iconColor = const Color(0xFFF59E0B); // Amber
        break;
      case AppNotificationType.info:
        icon = Icons.info_rounded;
        iconColor = const Color(0xFF0284C7); // Blue
        break;
    }

    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      messageText: Padding(
        padding: const EdgeInsets.only(left: 34),
        child: Text(
          message,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: const Color(0xFF0F172A),
      borderRadius: 14,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderWidth: 1,
      borderColor: const Color(0xFFE2E8F0),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 6),
          spreadRadius: 1,
        ),
      ],
      duration: duration,
      animationDuration: const Duration(milliseconds: 300),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }
}
