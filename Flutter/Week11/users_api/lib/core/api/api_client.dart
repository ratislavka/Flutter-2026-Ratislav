import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

typedef HttpClient = http.Client;

class ApiClient {
  ApiClient(
    this._client,
    this._store, {
    this.host = 'jsonplaceholder.typicode.com',
  });

  final http.Client _client;
  final String host;
  final SecureStore _store;

  Future<Map<String, String>> _headers() async => {
    'Accept': 'application/json',
    if (await _store.readToken() case final token?)
      'Authorization': 'Bearer $token',
  };

  Future<http.Response> get(Uri uri) =>
      _send(() async => _client.get(uri, headers: await _headers()));

  Future<http.Response> post(Uri uri, Map<String, dynamic> body) => _send(
    () async => _client.post(
      uri,
      headers: {...await _headers(), 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ),
  );

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    final http.Response response;
    try {
      response = await call().timeout(const Duration(seconds: 10));
    } on SocketException catch (error) {
      _logConnectionError(error);
      throw const NoConnectionException();
    } on TimeoutException catch (error) {
      _logConnectionError(error);
      throw const NoConnectionException();
    } on http.ClientException catch (error) {
      _logConnectionError(error);
      throw const NoConnectionException();
    } on HandshakeException catch (error) {
      _logConnectionError(error);
      throw const NoConnectionException();
    }

    if (kDebugMode) {
      developer.log(
        '${response.request?.method} ${response.request?.url.path} → '
        '${response.statusCode}',
        name: 'api',
      );
    }

    _check(response);
    return response;
  }

  void _logConnectionError(Exception error) {
    if (kDebugMode) {
      developer.log('Could not reach $host', name: 'api', error: error);
    }
  }

  void _check(http.Response response) {
    final status = response.statusCode;
    if (status == 401) throw const UnauthorizedException();
    if (status == 404) throw const NotFoundException();
    if (status >= 500) throw ServerException(status);
    if (status < 200 || status >= 300) {
      throw BadResponseException('Unexpected HTTP status: $status');
    }
  }

  dynamic decode(http.Response response) => _decode(response);

  dynamic _decode(http.Response response) {
    try {
      return jsonDecode(response.body);
    } on FormatException catch (error) {
      throw BadResponseException('Invalid JSON: $error');
    }
  }

  void close() async => _client.close();
}
