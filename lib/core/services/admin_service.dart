import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kamus_banjar_mobile_app/core/models/admin_stats.dart';
import 'package:kamus_banjar_mobile_app/core/models/contribution.dart';
import 'package:kamus_banjar_mobile_app/core/models/user.dart';
import 'package:kamus_banjar_mobile_app/core/models/word.dart';
import 'package:kamus_banjar_mobile_app/core/services/auth_service.dart';
import 'package:kamus_banjar_mobile_app/core/services/contribution_service.dart';

class WordPage {
  final List<Word> words;
  final int page;
  final int totalPages;
  final int total;

  const WordPage({
    required this.words,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}

class UserPage {
  final List<User> users;
  final int page;
  final int totalPages;
  final int total;

  const UserPage({
    required this.users,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}

class AdminService {
  final String baseUrl;

  const AdminService({required this.baseUrl});

  Map<String, String> _authHeaders(String accessToken) => {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

  T _parse<T>(http.Response res, T Function(dynamic) parser) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return parser(body['data']);
    }
    throw ApiException(
        res.statusCode, body['message']?.toString() ?? 'Terjadi kesalahan');
  }

  // ── Words ──────────────────────────────────────────────────

  Future<WordPage> listWords(
    String accessToken, {
    String? status,
    String? source,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) params['status'] = status;
    if (source != null) params['source'] = source;

    final uri = Uri.parse('$baseUrl/api/v1/admin/words')
        .replace(queryParameters: params);
    final res = await http.get(uri, headers: _authHeaders(accessToken));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = body['data'] as List;
      final meta = body['meta'] as Map<String, dynamic>;
      return WordPage(
        words: data.map((e) => Word.fromJson(e as Map<String, dynamic>)).toList(),
        page: meta['page'] as int,
        totalPages: meta['total_pages'] as int,
        total: meta['total'] as int,
      );
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    throw ApiException(res.statusCode, body['message']?.toString() ?? 'Error');
  }

  Future<Word> createWord(String accessToken, WordSubmitRequest request) async {
    final uri = Uri.parse('$baseUrl/api/v1/admin/words');
    final res = await http.post(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode(request.toJson()),
    );
    return _parse(res, (data) => Word.fromJson(data as Map<String, dynamic>));
  }

  Future<Word> updateWord(
      String accessToken, String id, WordSubmitRequest request) async {
    final uri = Uri.parse('$baseUrl/api/v1/admin/words/$id');
    final res = await http.put(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode(request.toJson()),
    );
    return _parse(res, (data) => Word.fromJson(data as Map<String, dynamic>));
  }

  Future<void> deleteWord(String accessToken, String id) async {
    final uri = Uri.parse('$baseUrl/api/v1/admin/words/$id');
    final res = await http.delete(uri, headers: _authHeaders(accessToken));
    _parse<void>(res, (_) {});
  }

  // ── Contributions ──────────────────────────────────────────

  Future<ContributionPage> listContributions(
    String accessToken, {
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) params['status'] = status;

    final uri = Uri.parse('$baseUrl/api/v1/admin/contributions')
        .replace(queryParameters: params);
    final res = await http.get(uri, headers: _authHeaders(accessToken));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = body['data'] as List;
      final meta = body['meta'] as Map<String, dynamic>;
      return ContributionPage(
        contributions: data
            .map((e) => Contribution.fromJson(e as Map<String, dynamic>))
            .toList(),
        page: meta['page'] as int,
        totalPages: meta['total_pages'] as int,
        total: meta['total'] as int,
      );
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    throw ApiException(res.statusCode, body['message']?.toString() ?? 'Error');
  }

  Future<void> approve(String accessToken, String id) async {
    final uri = Uri.parse('$baseUrl/api/v1/admin/contributions/$id/approve');
    final res = await http.patch(uri, headers: _authHeaders(accessToken));
    _parse<void>(res, (_) {});
  }

  Future<void> reject(String accessToken, String id, {String? notes}) async {
    final uri = Uri.parse('$baseUrl/api/v1/admin/contributions/$id/reject');
    final body = notes != null ? jsonEncode({'notes': notes}) : null;
    final res = await http.patch(
      uri,
      headers: _authHeaders(accessToken),
      body: body,
    );
    _parse<void>(res, (_) {});
  }

  // ── Comments ───────────────────────────────────────────────

  Future<void> deleteComment(
      String accessToken, String word, String commentId) async {
    final uri = Uri.parse(
        '$baseUrl/api/v1/admin/entries/$word/comments/$commentId');
    final res = await http.delete(uri, headers: _authHeaders(accessToken));
    _parse<void>(res, (_) {});
  }

  // ── Users ──────────────────────────────────────────────────

  Future<UserPage> listUsers(
    String accessToken, {
    String? role,
    bool? active,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (role != null) params['role'] = role;
    if (active != null) params['active'] = active.toString();

    final uri = Uri.parse('$baseUrl/api/v1/admin/users')
        .replace(queryParameters: params);
    final res = await http.get(uri, headers: _authHeaders(accessToken));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = body['data'] as List;
      final meta = body['meta'] as Map<String, dynamic>;
      return UserPage(
        users:
            data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList(),
        page: meta['page'] as int,
        totalPages: meta['total_pages'] as int,
        total: meta['total'] as int,
      );
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    throw ApiException(res.statusCode, body['message']?.toString() ?? 'Error');
  }

  Future<void> deactivateUser(String accessToken, String id) async {
    final uri = Uri.parse('$baseUrl/api/v1/admin/users/$id/deactivate');
    final res = await http.patch(uri, headers: _authHeaders(accessToken));
    _parse<void>(res, (_) {});
  }

  Future<void> activateUser(String accessToken, String id) async {
    final uri = Uri.parse('$baseUrl/api/v1/admin/users/$id/activate');
    final res = await http.patch(uri, headers: _authHeaders(accessToken));
    _parse<void>(res, (_) {});
  }

  Future<void> promoteUser(String accessToken, String id) async {
    final uri = Uri.parse('$baseUrl/api/v1/admin/users/$id/promote');
    final res = await http.patch(uri, headers: _authHeaders(accessToken));
    _parse<void>(res, (_) {});
  }

  // ── Stats + WOTD ───────────────────────────────────────────

  Future<AdminStats> getStats(String accessToken) async {
    final uri = Uri.parse('$baseUrl/api/v1/admin/stats');
    final res = await http.get(uri, headers: _authHeaders(accessToken));
    return _parse(
        res, (data) => AdminStats.fromJson(data as Map<String, dynamic>));
  }

  Future<void> setWordOfTheDay(
      String accessToken, String word, String date) async {
    final uri = Uri.parse('$baseUrl/api/v1/admin/word-of-the-day');
    final res = await http.put(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode({'word': word, 'date': date}),
    );
    _parse<void>(res, (_) {});
  }
}
