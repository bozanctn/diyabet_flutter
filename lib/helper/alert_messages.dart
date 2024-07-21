import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class AlertMessages {
  static void showBasicError(BuildContext context, {required String title, required String message}) {
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  static void showBasicSuccess(BuildContext context, {required String title, required String message}) {
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  static void showBasicInfo(BuildContext context, {required String title, required String message}) {
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.blue,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  static void showBasicWarning(BuildContext context, {required String title, required String message}) {
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.orange,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  static void showAdvancedError(BuildContext context, {required String title, required String message, required String buttonTitle, required Function(bool) completion}) {
    Flushbar(
      title: title,
      message: message,
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
      mainButton: TextButton(
        onPressed: () {
          completion(false);
          Navigator.of(context).pop();
        },
        child: Text(buttonTitle, style: const TextStyle(color: Colors.white)),
      ),
    ).show(context);
  }

  static void showAdvancedSuccess(BuildContext context, {required String title, required String message, required String buttonTitle, required Function(bool) completion}) {
    Flushbar(
      title: title,
      message: message,
      backgroundColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
      mainButton: TextButton(
        onPressed: () {
          completion(true);
          Navigator.of(context).pop();
        },
        child: Text(buttonTitle, style: const TextStyle(color: Colors.white)),
      ),
    ).show(context);
  }

  static void showAdvancedInfo(BuildContext context, {required String title, required String message, required String buttonTitle, required Function(bool) completion}) {
    Flushbar(
      title: title,
      message: message,
      backgroundColor: Colors.blue,
      flushbarPosition: FlushbarPosition.TOP,
      mainButton: TextButton(
        onPressed: () {
          completion(true);
          Navigator.of(context).pop();
        },
        child: Text(buttonTitle, style: const TextStyle(color: Colors.white)),
      ),
    ).show(context);
  }

  static void showAdvancedWarning(BuildContext context, {required String title, required String message, required String buttonTitle, required Function(bool) completion}) {
    Flushbar(
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      flushbarPosition: FlushbarPosition.TOP,
      mainButton: TextButton(
        onPressed: () {
          completion(true);
          Navigator.of(context).pop();
        },
        child: Text(buttonTitle, style: const TextStyle(color: Colors.white)),
      ),
    ).show(context);
  }

  static void showAdvancedInfoBottom(BuildContext context, {required String title, required String message, required String buttonTitle, required Function(bool) completion}) {
    Flushbar(
      title: title,
      message: message,
      backgroundColor: Colors.blue,
      flushbarPosition: FlushbarPosition.BOTTOM,
      mainButton: TextButton(
        onPressed: () {
          completion(true);
          Navigator.of(context).pop();
        },
        child: Text(buttonTitle, style: const TextStyle(color: Colors.white)),
      ),
    ).show(context);
  }

  static void showCenterError(BuildContext context, {required String title, required String message}) {
    Flushbar(
      title: title,
      message: message,
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
    ).show(context);
  }
}
