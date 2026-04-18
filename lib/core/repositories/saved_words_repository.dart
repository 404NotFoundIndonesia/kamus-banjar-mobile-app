import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedWordsRepository {
  static const String _key = 'saved_words';

  Future<List<List<List<String>>>> loadSavedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    var savedWords = List<List<List<String>>>.from(json.decode(data).map(
          (category) => List<List<String>>.from(category.map(
            (list) => List<String>.from(list),
          )),
        ));
    return savedWords;
  }

  Future<void> saveWord(String category, String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<List<List<String>>> savedWords = await loadSavedWords();

    final categoryIndex = savedWords.indexWhere((c) => c[0][0] == category);
    if (categoryIndex != -1) {
      if (!savedWords[categoryIndex][1].contains(word)) {
        savedWords[categoryIndex][1].add(word);
      }
    } else {
      savedWords.add([
        [category],
        [word]
      ]);
    }

    await prefs.setString(_key, json.encode(savedWords));
  }

  Future<void> removeWord(String category, String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<List<List<String>>> savedWords = await loadSavedWords();

    for (int i = 0; i < savedWords.length; i++) {
      savedWords[i][1].remove(word);
      if (savedWords[i][1].isEmpty) {
        savedWords.removeAt(i);
        i--;
      }
    }

    await prefs.setString(_key, json.encode(savedWords));
  }

  Future<bool> isWordSaved(String category, String word) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return false;

    final savedWords = List<List<List<String>>>.from(json
        .decode(data)
        .map((category) => List<List<String>>.from(category.map(
              (list) => List<String>.from(list),
            ))));
    for (var cat in savedWords) {
      if (cat[1].contains(word)) {
        return true;
      }
    }

    return false;
  }

  Future<void> editCategoryName(String oldCategory, String newCategory) async {
    final prefs = await SharedPreferences.getInstance();
    List<List<List<String>>> savedWords = await loadSavedWords();

    final categoryIndex = savedWords.indexWhere((c) => c[0][0] == oldCategory);
    if (categoryIndex != -1) {
      savedWords[categoryIndex][0][0] = newCategory;
      await prefs.setString(_key, json.encode(savedWords));
    }
  }

  Future<List<String>> getAllCategories() async {
    List<List<List<String>>> savedWords = await loadSavedWords();
    return savedWords.map((category) => category[0][0]).toList();
  }
}
