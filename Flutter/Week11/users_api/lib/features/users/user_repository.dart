import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

class UserRepository {
  const UserRepository(this._api, this._cache);

  final ApiClient _api;

  final UsersCache _cache;

  Future<({List<User> items, bool fromCache})> getAll() async {
    try {
      final items = await _fetch();
      try {
        await _cache.save(items);
      } on FileSystemException {
      }
      return (items: items, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<List<User>> _fetch() async {
    final response = await _api.get(Uri.https(_api.host, '/users'));
    try {
      final data = _api.decode(response) as List<dynamic>;
      return [
        for (final item in data) User.fromJson(item as Map<String, dynamic>),
      ];
    } on TypeError catch (error) {
      throw BadResponseException('users: $error');
    } on FormatException catch (error) {
      throw BadResponseException('users: $error');
    }
  }

  Future<User> getById(int id) async {
    final response = await _api.get(Uri.https(_api.host, '/users/$id'));
    return _readUser(response, 'users/$id');
  }

  Future<User> create(User draft) async {
    final body = draft.toJson()..remove('id');
    final response = await _api.post(Uri.https(_api.host, '/users'), body);
    if (response.statusCode != 201) {
      throw BadResponseException('Expected 201, got ${response.statusCode}');
    }
    return _readUser(response, 'POST users');
  }

  User _readUser(http.Response response, String source) {
    try {
      return User.fromJson(_api.decode(response) as Map<String, dynamic>);
    } on TypeError catch (error) {
      throw BadResponseException('$source: $error');
    } on FormatException catch (error) {
      throw BadResponseException('$source: $error');
    }
  }

  void close() => _api.close();
}
