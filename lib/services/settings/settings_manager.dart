import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _themeKey = 'app_theme_mode';
  static const String _accountDeleteKey = 'account_delete_preference';

  Future<void> setThemeMode(bool isDarkMode) async {
    await _secureStorage.write(key: _themeKey, value: isDarkMode.toString());
  }

  Future<bool> getThemeMode() async {
    final String? themeValue = await _secureStorage.read(key: _themeKey);
    return themeValue == 'true';
  }

  Future<void> setAccountDeletionPreference(bool canDelete) async {
    await _secureStorage.write(
        key: _accountDeleteKey, value: canDelete.toString());
  }

  Future<bool> getAccountDeletionPreference() async {
    final String? deleteValue =
        await _secureStorage.read(key: _accountDeleteKey);
    return deleteValue == 'true';
  }

  Future<void> clearAllSettings() async {
    await _secureStorage.deleteAll();
  }
}
