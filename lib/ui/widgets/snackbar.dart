import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, bool isSuccess) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
      ),
      backgroundColor: isSuccess
          ? Theme.of(context).colorScheme.tertiary
          : Theme.of(context).colorScheme.error,
    ),
  );
}
