import 'dart:convert';
import 'package:http/http.dart' as http;

class AlphabetRepository {
  Future<List<String>> getAll() async {
    List<String> result = [];

    Uri url = Uri.parse('https://kamus-banjar.iqbaleff214.com/api/v1/alphabets');
    var response = await http.get(url);

    List letters = jsonDecode(response.body)['data'];
    for (var letter in letters) {
      result.add(letter['letter']);
    }

    return result;
  }
}