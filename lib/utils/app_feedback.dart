library;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppFeedback {
  static void success(BuildContext context, String message) {
    _snack(context, message, Colors.green.shade700);
    Fluttertoast.showToast(msg: message);
  }

  static void error(BuildContext context, String message) {
    _snack(context, message, Colors.red.shade700);
    Fluttertoast.showToast(msg: message);
  }

  static void info(BuildContext context, String message) {
    _snack(context, message, Colors.blueGrey.shade700);
  }

  static void _snack(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
