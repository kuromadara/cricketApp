import 'package:cricket/common/common.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cricket/models/models.dart';

class SessionManagerServcie {
  late FlutterSecureStorage secureStorage;

  SessionManagerServcie() {
    secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ));
  }

  Future<void> saveAuthToken(String token) async {
    await secureStorage.write(key: keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: keyToken);
  }

  Future<void> deleteToken() async {
    await secureStorage.delete(key: keyToken);
  }

  Future<void> deleteAll() async {
    await secureStorage.deleteAll();
  }

  Future<bool> deleteSession() async {
    await deleteAll();
    return true;
  }

  Future<bool> hasSession() async {
    String? token = await getToken();
    return token != null;
  }

  Future<void> saveUserId(String userId) async {
    await secureStorage.write(key: keyUserId, value: userId);
  }

  Future<String?> getUserId() async {
    return await secureStorage.read(key: keyUserId);
  }

}
