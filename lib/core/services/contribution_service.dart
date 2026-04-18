import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kamus_banjar_mobile_app/core/models/contribution.dart';
import 'package:kamus_banjar_mobile_app/core/services/auth_service.dart';

class WordSubmitRequest {
  final String word;
  final String? syllables;
  final String alphabet;
  final List<Map<String, dynamic>> meanings;
  final List<Map<String, dynamic>>? derivatives;

  const WordSubmitRequest({
    required this.word,
    this.syllables,
    required this.alphabet,
    required this.meanings,
    this.derivatives,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'word': word,
      'alphabet': alphabet,
      'meanings': meanings,
    };
    if (syllables != null && syllables!.isNotEmpty) {
      map['syllables'] = syllables;
    }
    if (derivatives != null && derivatives!.isNotEmpty) {
      map['derivatives'] = derivatives;
    }
    return map;
  }
}

class ContributionService {
  final String baseUrl;

  const ContributionService({required this.baseUrl});

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
        res.statusCode, body['message']?.toString() ?? 'Error');
  }

  Future<Contribution> submit(
      String accessToken, WordSubmitRequest request) async {
    final uri = Uri.parse('$baseUrl/api/v1/contributions');
    final res = await http.post(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode(request.toJson()),
    );
    return _parse(
        res, (data) => Contribution.fromJson(data as Map<String, dynamic>));
  }

  Future<ContributionPage> getMine(String accessToken,
      {int page = 1, int limit = 20}) async {
    final uri = Uri.parse(
        '$baseUrl/api/v1/contributions/mine?page=$page&limit=$limit');
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
    throw ApiException(
        res.statusCode, body['message']?.toString() ?? 'Error');
  }

  Future<Contribution> getById(String accessToken, String id) async {
    final uri = Uri.parse('$baseUrl/api/v1/contributions/$id');
    final res = await http.get(uri, headers: _authHeaders(accessToken));
    return _parse(
        res, (data) => Contribution.fromJson(data as Map<String, dynamic>));
  }

  Future<Contribution> edit(
      String accessToken, String id, WordSubmitRequest request) async {
    final uri = Uri.parse('$baseUrl/api/v1/contributions/$id');
    final res = await http.put(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode(request.toJson()),
    );
    return _parse(
        res, (data) => Contribution.fromJson(data as Map<String, dynamic>));
  }

  Future<void> delete(String accessToken, String id) async {
    final uri = Uri.parse('$baseUrl/api/v1/contributions/$id');
    final res = await http.delete(uri, headers: _authHeaders(accessToken));
    _parse<void>(res, (_) {});
  }
}
