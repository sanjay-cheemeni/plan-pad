
import 'package:flutter/material.dart';

enum SnackbarType {
  success,
  error,
  warning,
  info,
}

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);

    final (Color backgroundColor, IconData icon) = switch (type) {
      SnackbarType.success => (
          Colors.green.shade700,
          Icons.check_circle_outline,
        ),
      SnackbarType.error => (
          Colors.red.shade700,
          Icons.error_outline,
        ),
      SnackbarType.warning => (
          Colors.orange.shade800,
          Icons.warning_amber_rounded,
        ),
      SnackbarType.info => (
          Colors.blue.shade700,
          Icons.info_outline,
        ),
    };

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.info);
  }
}