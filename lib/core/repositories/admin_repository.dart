import 'package:kamus_banjar_mobile_app/core/models/admin_stats.dart';
import 'package:kamus_banjar_mobile_app/core/models/contribution.dart';
import 'package:kamus_banjar_mobile_app/core/models/word.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/auth_repository.dart';
import 'package:kamus_banjar_mobile_app/core/services/admin_service.dart';
import 'package:kamus_banjar_mobile_app/core/services/auth_service.dart';
import 'package:kamus_banjar_mobile_app/core/services/contribution_service.dart';

class UnauthorizedException implements Exception {
  @override
  String toString() => 'Akses ditolak';
}

class AdminRepository {
  final AdminService _service;
  final AuthRepository _authRepository;

  AdminRepository({
    required AdminService service,
    required AuthRepository authRepository,
  })  : _service = service,
        _authRepository = authRepository;

  String get _token {
    if (!_authRepository.isAdmin) throw UnauthorizedException();
    final token = _authRepository.accessToken;
    if (token == null) throw const ApiException(401, 'Tidak terautentikasi');
    return token;
  }

  Future<WordPage> listWords({
    String? status,
    String? source,
    int page = 1,
    int limit = 20,
  }) =>
      _service.listWords(_token,
          status: status, source: source, page: page, limit: limit);

  Future<Word> createWord(WordSubmitRequest request) =>
      _service.createWord(_token, request);

  Future<Word> updateWord(String id, WordSubmitRequest request) =>
      _service.updateWord(_token, id, request);

  Future<void> deleteWord(String id) => _service.deleteWord(_token, id);

  Future<ContributionPage> listContributions({
    String? status,
    int page = 1,
    int limit = 20,
  }) =>
      _service.listContributions(_token,
          status: status, page: page, limit: limit);

  Future<void> approve(String id) => _service.approve(_token, id);

  Future<void> reject(String id, {String? notes}) =>
      _service.reject(_token, id, notes: notes);

  Future<void> deleteComment(String word, String commentId) =>
      _service.deleteComment(_token, word, commentId);

  Future<UserPage> listUsers({
    String? role,
    bool? active,
    int page = 1,
    int limit = 20,
  }) =>
      _service.listUsers(_token,
          role: role, active: active, page: page, limit: limit);

  Future<void> deactivateUser(String id) =>
      _service.deactivateUser(_token, id);

  Future<void> activateUser(String id) => _service.activateUser(_token, id);

  Future<void> promoteUser(String id) => _service.promoteUser(_token, id);

  Future<AdminStats> getStats() => _service.getStats(_token);

  Future<void> setWordOfTheDay(String word, String date) =>
      _service.setWordOfTheDay(_token, word, date);
}
