import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kamus_banjar_mobile_app/core/models/token_pair.dart';
import 'package:kamus_banjar_mobile_app/core/models/user.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class AuthService {
  final String baseUrl;

  const AuthService({required this.baseUrl});

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  Map<String, String> _bearerHeaders(String accessToken) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

  T _parse<T>(http.Response response, T Function(dynamic data) parser) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return parser(body['data']);
    }
    throw ApiException(
      response.statusCode,
      body['message'] ?? 'Terjadi kesalahan',
    );
  }

  Future<User> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return _parse(response, (data) => User.fromJson(data));
  }

  Future<TokenPair> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _parse(response, (data) => TokenPair.fromJson(data));
  }

  Future<TokenPair> refresh(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/refresh'),
      headers: _jsonHeaders,
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    return _parse(response, (data) => TokenPair.fromJson(data));
  }

  Future<void> logout(String accessToken, String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/logout'),
      headers: _bearerHeaders(accessToken),
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    _parse(response, (_) {});
  }

  Future<User> getMe(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/auth/me'),
      headers: _bearerHeaders(accessToken),
    );
    return _parse(response, (data) => User.fromJson(data));
  }

  Future<User> updateMe(
    String accessToken, {
    String? name,
    String? oldPassword,
    String? newPassword,
  }) async {
    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (oldPassword != null) body['old_password'] = oldPassword;
    if (newPassword != null) body['new_password'] = newPassword;

    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/auth/me'),
      headers: _bearerHeaders(accessToken),
      body: jsonEncode(body),
    );
    return _parse(response, (data) => User.fromJson(data));
  }
}
