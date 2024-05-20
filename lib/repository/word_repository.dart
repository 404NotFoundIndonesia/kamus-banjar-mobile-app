import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamus_banjar_mobile_app/model/word_model.dart';

class WordRepository {
  Future<List<String>> getAllByAlphabet(String alphabet) async {
    List<String> result = [];

    Uri url = Uri.parse('https://kamus-banjar.iqbaleff214.com/api/v1/alphabets/$alphabet');
    var response = await http.get(url);

    List words = jsonDecode(response.body)['data']['words'];
    for (var word in words) {
      result.add(word);
    }

    return result;
  }

  Future<Word> getWord(String word) async {
    Uri url = Uri.parse('https://kamus-banjar.iqbaleff214.com/api/v1/entries/$word');
    var response = await http.get(url);
    return Word.fromJson(jsonDecode(response.body)['data']);
  }
}