import 'package:flutter/material.dart';
import 'package:cricket/screens/screens.dart';

class AppRoutes {
  static const String home = "/";
  static const String login = "/login";
  static const String settings = "/settings";
  static const String players = "/players";
  static const String playerDetails = "/player-details";
  static const String stadium = "/stadium";
  static const String match = "/match";

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    players: (context) => const PlayersScreen(),
    playerDetails: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return PlayerDetailsScreen(playerId: args['playerId']);
    },
    settings: (context) => const SettingsScreen(),
    stadium: (context) => const SettingsScreen(),
    match: (context) => const SettingsScreen(),
  };
}
