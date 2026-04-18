import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamus_banjar_mobile_app/core/services/auth_service.dart';

class CommunityService {
  final String baseUrl;

  const CommunityService({required this.baseUrl});

  Map<String, String> _headers(String accessToken) => {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

  T _parse<T>(http.Response res, T Function(dynamic) parser) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return parser(body['data']);
    }
    throw ApiException(
        res.statusCode, body['message']?.toString() ?? 'Error');
  }

  Future<List<String>> getBookmarks(String accessToken,
      {int page = 1, int limit = 100}) async {
    final uri =
        Uri.parse('$baseUrl/api/v1/me/bookmarks?page=$page&limit=$limit');
    final res = await http.get(uri, headers: _headers(accessToken));
    return _parse(res, (data) => List<String>.from(data as List));
  }

  Future<void> addBookmark(String accessToken, String word) async {
    final uri = Uri.parse('$baseUrl/api/v1/me/bookmarks/$word');
    final res = await http.post(uri, headers: _headers(accessToken));
    _parse<void>(res, (_) {});
  }

  Future<void> removeBookmark(String accessToken, String word) async {
    final uri = Uri.parse('$baseUrl/api/v1/me/bookmarks/$word');
    final res = await http.delete(uri, headers: _headers(accessToken));
    _parse<void>(res, (_) {});
  }
}
