import 'package:kamus_banjar_mobile_app/core/models/contribution.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/auth_repository.dart';
import 'package:kamus_banjar_mobile_app/core/services/contribution_service.dart';

class ContributionRepository {
  final ContributionService _service;
  final AuthRepository _authRepository;

  ContributionRepository({
    required ContributionService service,
    required AuthRepository authRepository,
  })  : _service = service,
        _authRepository = authRepository;

  String get _token => _authRepository.accessToken!;

  Future<Contribution> submit(WordSubmitRequest request) =>
      _service.submit(_token, request);

  Future<ContributionPage> getMine({int page = 1, int limit = 20}) =>
      _service.getMine(_token, page: page, limit: limit);

  Future<Contribution> getById(String id) => _service.getById(_token, id);

  Future<Contribution> edit(String id, WordSubmitRequest request) =>
      _service.edit(_token, id, request);

  Future<void> delete(String id) => _service.delete(_token, id);
}
