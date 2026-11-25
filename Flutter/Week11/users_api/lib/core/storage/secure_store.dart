import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  const SecureStore();
  static const _storage = FlutterSecureStorage();
  Future<void> saveToken(String token) =>
      _storage.write(key: 'token', value: token);
  Future<String?> readToken() => _storage.read(key: 'token');
  Future<void> clear() => _storage.delete(key: 'token');
}
