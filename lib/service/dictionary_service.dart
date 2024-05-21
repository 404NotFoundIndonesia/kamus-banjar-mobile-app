import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kamus_banjar_mobile_app/model/word.dart';

class DictionaryService {
  final String baseUrl;

  const DictionaryService({required this.baseUrl});

  Future<List<String>> getAlphabets() async {
    List<String> result = [];

    final response = await http.get(Uri.parse('$baseUrl/api/v1/alphabets'));
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      for(var letter in body['data']) {
        result.add(letter['letter'].toString());
      }
      return result;
    } else {
      throw Exception(body['message']);
    }
  }

  Future<List<String>> getWords(String alphabet) async {
    List<String> result = [];

    final response = await http.get(Uri.parse('$baseUrl/api/v1/alphabets/$alphabet'));
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      for(var word in body['data']['words']) {
        result.add(word.toString());
      }
      return result;
    } else {
      throw Exception(body['message']);
    }
  }

  Future<Word> getWord(String word) async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/entries/$word'));
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Word.fromJson(body['data']);
    } else {
      throw Exception(body['message']);
    }
  }
}
