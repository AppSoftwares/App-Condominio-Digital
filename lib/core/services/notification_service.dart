import 'package:flutter/material.dart';

class NotificationService {
  static void showNotification(BuildContext context, {required String title, required String body}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(body),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
