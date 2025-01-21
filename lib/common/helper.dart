import 'package:flutter/material.dart';
import 'package:cricket/ui/ui.dart';
import 'package:cricket/routes/routes.dart';

class Helper {
 
 

  static void navigateWithFadeTransition(
    BuildContext context,
    String routeName,
    dynamic arguments,
  ) {
    Navigator.push(
      context,
      FadePageRoute(
        page: AppRoutes.routes[routeName]!(context),
        arguments: arguments,
      ),
    );
  }

 

  
}
