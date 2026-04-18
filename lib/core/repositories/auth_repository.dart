import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kamus_banjar_mobile_app/core/models/user.dart';
import 'package:kamus_banjar_mobile_app/core/services/auth_service.dart';

enum AuthRole { guest, user, admin }

class AuthRepository extends ChangeNotifier {
  final AuthService _authService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _keyAccess = 'auth_access_token';
  static const _keyRefresh = 'auth_refresh_token';

  AuthRole _role = AuthRole.guest;
  User? _user;
  bool _isLoading = false;
  String? _accessToken;
  String? _refreshToken;

  AuthRepository({required AuthService authService})
      : _authService = authService;

  AuthRole get role => _role;
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _role != AuthRole.guest;
  bool get isAdmin => _role == AuthRole.admin;
  String? get accessToken => _accessToken;

  Future<void> init() async {
    _accessToken = await _storage.read(key: _keyAccess);
    _refreshToken = await _storage.read(key: _keyRefresh);

    if (_accessToken == null) return;

    try {
      final user = await _authService.getMe(_accessToken!);
      _setUser(user);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _tryRefresh();
      } else {
        await _clearSession();
      }
    } catch (_) {
      // network error — keep guest, tokens intact for next launch
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final tokens = await _authService.login(email, password);
      await _saveTokens(tokens.accessToken, tokens.refreshToken);
      final user = await _authService.getMe(tokens.accessToken);
      _setUser(user);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _authService.register(name, email, password);
      final tokens = await _authService.login(email, password);
      await _saveTokens(tokens.accessToken, tokens.refreshToken);
      final user = await _authService.getMe(tokens.accessToken);
      _setUser(user);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      if (_accessToken != null && _refreshToken != null) {
        await _authService.logout(_accessToken!, _refreshToken!);
      }
    } catch (_) {
      // best-effort; clear local state regardless
    } finally {
      await _clearSession();
      _setLoading(false);
    }
  }

  Future<void> refreshIfNeeded() async {
    await _tryRefresh();
  }

  Future<void> updateProfile({
    String? name,
    String? oldPassword,
    String? newPassword,
  }) async {
    if (_accessToken == null) return;
    _setLoading(true);
    try {
      final user = await _authService.updateMe(
        _accessToken!,
        name: name,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      _setUser(user);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _tryRefresh() async {
    if (_refreshToken == null) {
      await _clearSession();
      return;
    }
    try {
      final tokens = await _authService.refresh(_refreshToken!);
      await _saveTokens(tokens.accessToken, tokens.refreshToken);
      final user = await _authService.getMe(tokens.accessToken);
      _setUser(user);
    } catch (_) {
      await _clearSession();
    }
  }

  Future<void> _saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    await _storage.write(key: _keyAccess, value: access);
    await _storage.write(key: _keyRefresh, value: refresh);
  }

  Future<void> _clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    _role = AuthRole.guest;
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyRefresh);
    notifyListeners();
  }

  void _setUser(User user) {
    _user = user;
    _role = user.role == 'admin' ? AuthRole.admin : AuthRole.user;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
