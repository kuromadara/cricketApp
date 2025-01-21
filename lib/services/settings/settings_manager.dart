import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Keys for secure storage
  static const String _themeKey = 'app_theme_mode';
  static const String _accountDeleteKey = 'account_delete_preference';

  // Theme Mode Management
  Future<void> setThemeMode(bool isDarkMode) async {
    await _secureStorage.write(key: _themeKey, value: isDarkMode.toString());
  }

  Future<bool> getThemeMode() async {
    final String? themeValue = await _secureStorage.read(key: _themeKey);
    return themeValue == 'true';
  }

  // Account Deletion Preference
  Future<void> setAccountDeletionPreference(bool canDelete) async {
    await _secureStorage.write(
        key: _accountDeleteKey, value: canDelete.toString());
  }

  Future<bool> getAccountDeletionPreference() async {
    final String? deleteValue =
        await _secureStorage.read(key: _accountDeleteKey);
    return deleteValue == 'true';
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    await _secureStorage.deleteAll();
  }
}
