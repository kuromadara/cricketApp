import 'package:flutter/material.dart';
import 'package:cricket/services/services.dart';

class SettingsController extends ChangeNotifier {
  bool _isDarkMode = false;
  final SettingsManager _settingsManager = SettingsManager();

  SettingsController() {
    _loadSavedTheme();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  // Toggle Theme Mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _settingsManager.setThemeMode(_isDarkMode);
    notifyListeners();
  }

  // Set Theme Directly
  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    _settingsManager.setThemeMode(_isDarkMode);
    notifyListeners();
  }

  // Load Saved Theme
  Future<void> _loadSavedTheme() async {
    final savedTheme = await _settingsManager.getThemeMode();
    _isDarkMode = savedTheme;
    notifyListeners();
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      // TODO: Implement actual account deletion logic
      // This might involve calling an API, clearing user data, etc.

      // Mark account for deletion
      await _settingsManager.setAccountDeletionPreference(true);

      // Optional: Additional cleanup or navigation logic
    } catch (e) {
      // Handle deletion errors

      // Optionally show an error dialog
    }
  }

  // Check Account Deletion Status
  Future<bool> isAccountMarkedForDeletion() async {
    return await _settingsManager.getAccountDeletionPreference();
  }

  // Theme Definitions
  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    // Add more light theme configurations
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    // Add more dark theme configurations
  );
}
