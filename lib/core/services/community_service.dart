import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamus_banjar_mobile_app/core/models/comment.dart';
import 'package:kamus_banjar_mobile_app/core/models/word.dart';
import 'package:kamus_banjar_mobile_app/core/services/auth_service.dart';

class CommunityService {
  final String baseUrl;

  const CommunityService({required this.baseUrl});

  Map<String, String> _authHeaders(String accessToken) => {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

  static const Map<String, String> _jsonHeaders = {
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

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  Future<List<String>> getBookmarks(String accessToken,
      {int page = 1, int limit = 100}) async {
    final uri =
        Uri.parse('$baseUrl/api/v1/me/bookmarks?page=$page&limit=$limit');
    final res = await http.get(uri, headers: _authHeaders(accessToken));
    return _parse(res, (data) => List<String>.from(data as List));
  }

  Future<void> addBookmark(String accessToken, String word) async {
    final uri = Uri.parse('$baseUrl/api/v1/me/bookmarks/$word');
    final res = await http.post(uri, headers: _authHeaders(accessToken));
    _parse<void>(res, (_) {});
  }

  Future<void> removeBookmark(String accessToken, String word) async {
    final uri = Uri.parse('$baseUrl/api/v1/me/bookmarks/$word');
    final res = await http.delete(uri, headers: _authHeaders(accessToken));
    _parse<void>(res, (_) {});
  }

  // ── Votes ─────────────────────────────────────────────────────────────────

  Future<void> vote(String accessToken, String word, int voteValue) async {
    final uri = Uri.parse('$baseUrl/api/v1/entries/$word/votes');
    final res = await http.post(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode({'vote': voteValue}),
    );
    _parse<void>(res, (_) {});
  }

  // ── Comments ──────────────────────────────────────────────────────────────

  Future<List<Comment>> getComments(String word) async {
    final uri = Uri.parse('$baseUrl/api/v1/entries/$word/comments');
    final res = await http.get(uri);
    return _parse(res,
        (data) => (data as List).map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList());
  }

  Future<Comment> postComment(
    String accessToken,
    String word,
    String body, {
    String? parentId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/entries/$word/comments');
    final payload = <String, dynamic>{'body': body};
    if (parentId != null) payload['parent_id'] = parentId;
    final res = await http.post(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode(payload),
    );
    return _parse(res, (data) => Comment.fromJson(data as Map<String, dynamic>));
  }

  Future<void> deleteOwnComment(
      String accessToken, String word, String commentId) async {
    final uri =
        Uri.parse('$baseUrl/api/v1/entries/$word/comments/$commentId');
    final res = await http.delete(uri, headers: _authHeaders(accessToken));
    _parse<void>(res, (_) {});
  }

  // ── Word of the Day ───────────────────────────────────────────────────────

  Future<Word> getWordOfTheDay() async {
    final uri = Uri.parse('$baseUrl/api/v1/word-of-the-day');
    final res = await http.get(uri, headers: _jsonHeaders);
    return _parse(
        res, (data) => Word.fromJson(data as Map<String, dynamic>));
  }
}
