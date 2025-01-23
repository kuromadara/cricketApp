import 'package:flutter/material.dart';
import 'package:cricket/services/services.dart';
import 'package:cricket/common/common.dart';

class SettingsController extends ChangeNotifier {
  bool _isDarkMode = false;
  ApiCallStatus apiStatus = ApiCallStatus.success;
  final SettingsManager _settingsManager = SettingsManager();

  SettingsController() {
    _loadSavedTheme();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _settingsManager.setThemeMode(_isDarkMode);
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    _settingsManager.setThemeMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> _loadSavedTheme() async {
    final savedTheme = await _settingsManager.getThemeMode();
    _isDarkMode = savedTheme;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    try {
      await _settingsManager.setAccountDeletionPreference(true);
    } catch (e) {}
  }

  Future<bool> isAccountMarkedForDeletion() async {
    return await _settingsManager.getAccountDeletionPreference();
  }

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
  );
}
