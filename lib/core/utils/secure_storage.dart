import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user';
  static const _rolesKey = 'roles';

  static Future<void> saveAuthData(String token, String user, String roles) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: user);
    await _storage.write(key: _rolesKey, value: roles);
  }

  static Future<Map<String, String?>> getAuthData() async {
    final token = await _storage.read(key: _tokenKey);
    final user = await _storage.read(key: _userKey);
    final roles = await _storage.read(key: _rolesKey);
    return {'token': token, 'user': user, 'roles': roles};
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
