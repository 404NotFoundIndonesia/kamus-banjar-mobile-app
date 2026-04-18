import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/auth_repository.dart';
import 'package:kamus_banjar_mobile_app/core/services/community_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedWordsRepository extends ChangeNotifier {
  final CommunityService _communityService;
  final AuthRepository _authRepository;

  static const String _key = 'saved_words';

  Set<String> _serverBookmarks = {};
  bool _serverFetched = false;
  AuthRole _lastRole = AuthRole.guest;

  SavedWordsRepository({
    required CommunityService communityService,
    required AuthRepository authRepository,
  })  : _communityService = communityService,
        _authRepository = authRepository {
    _lastRole = authRepository.role;
    authRepository.addListener(_onAuthChanged);
  }

  Set<String> get serverBookmarks => Set.unmodifiable(_serverBookmarks);
  bool get serverFetched => _serverFetched;

  // ── Auth listener ─────────────────────────────────────────────────────────

  void _onAuthChanged() {
    final newRole = _authRepository.role;
    if (_lastRole == AuthRole.guest && newRole != AuthRole.guest) {
      _lastRole = newRole;
      _migrateAndFetch();
    } else if (_lastRole != AuthRole.guest && newRole == AuthRole.guest) {
      _lastRole = newRole;
      _serverBookmarks = {};
      _serverFetched = false;
      notifyListeners();
    } else {
      _lastRole = newRole;
    }
  }

  Future<void> _migrateAndFetch() async {
    await migrateLocalToServer();
    await fetchBookmarks();
  }

  // ── Server-side (authenticated) ──────────────────────────────────────────

  Future<void> fetchBookmarks() async {
    final token = _authRepository.accessToken;
    if (token == null) return;
    try {
      final words = await _communityService.getBookmarks(token);
      _serverBookmarks = Set<String>.from(words);
      _serverFetched = true;
      notifyListeners();
    } catch (_) {
      // keep existing cache on error
    }
  }

  Future<void> addBookmark(String word) async {
    final token = _authRepository.accessToken;
    if (token == null) return;
    _serverBookmarks.add(word);
    notifyListeners();
    try {
      await _communityService.addBookmark(token, word);
    } catch (_) {
      _serverBookmarks.remove(word);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeBookmark(String word) async {
    final token = _authRepository.accessToken;
    if (token == null) return;
    _serverBookmarks.remove(word);
    notifyListeners();
    try {
      await _communityService.removeBookmark(token, word);
    } catch (_) {
      _serverBookmarks.add(word);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> migrateLocalToServer() async {
    final token = _authRepository.accessToken;
    if (token == null) return;
    final localWords = await _loadAllLocalWords();
    if (localWords.isEmpty) return;
    for (final word in localWords) {
      try {
        await _communityService.addBookmark(token, word);
      } catch (_) {
        // skip individual failures
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<List<String>> _loadAllLocalWords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final saved = List<List<List<String>>>.from(jsonDecode(data).map(
      (c) => List<List<String>>.from(c.map((l) => List<String>.from(l))),
    ));
    return [for (final cat in saved) if (cat.length > 1) ...cat[1]];
  }

  // ── Local (guest) ────────────────────────────────────────────────────────

  Future<List<List<List<String>>>> loadSavedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    return List<List<List<String>>>.from(jsonDecode(data).map(
      (c) => List<List<String>>.from(c.map((l) => List<String>.from(l))),
    ));
  }

  Future<void> saveWord(String category, String word) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await loadSavedWords();

    final idx = saved.indexWhere((c) => c[0][0] == category);
    if (idx != -1) {
      if (!saved[idx][1].contains(word)) saved[idx][1].add(word);
    } else {
      saved.add([
        [category],
        [word],
      ]);
    }

    await prefs.setString(_key, jsonEncode(saved));
    notifyListeners();
  }

  Future<void> removeWord(String category, String word) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await loadSavedWords();

    for (int i = 0; i < saved.length; i++) {
      saved[i][1].remove(word);
      if (saved[i][1].isEmpty) {
        saved.removeAt(i);
        i--;
      }
    }

    await prefs.setString(_key, jsonEncode(saved));
    notifyListeners();
  }

  Future<bool> isWordSaved(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return false;
    final saved = List<List<List<String>>>.from(jsonDecode(data).map(
      (c) => List<List<String>>.from(c.map((l) => List<String>.from(l))),
    ));
    return saved.any((cat) => cat.length > 1 && cat[1].contains(word));
  }

  Future<void> editCategoryName(
      String oldCategory, String newCategory) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await loadSavedWords();

    final idx = saved.indexWhere((c) => c[0][0] == oldCategory);
    if (idx != -1) {
      saved[idx][0][0] = newCategory;
      await prefs.setString(_key, jsonEncode(saved));
      notifyListeners();
    }
  }

  Future<List<String>> getAllCategories() async {
    final saved = await loadSavedWords();
    return saved.map((c) => c[0][0]).toList();
  }

  @override
  void dispose() {
    _authRepository.removeListener(_onAuthChanged);
    super.dispose();
  }
}
