import 'package:flutter/material.dart';
import 'package:cricket/screens/screens.dart';

class AppRoutes {
  static const String home = "/";
  static const String login = "/login";
  static const String settings = "/settings";

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
