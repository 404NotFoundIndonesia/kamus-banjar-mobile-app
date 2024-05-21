import 'package:kamus_banjar_mobile_app/model/word.dart';
import 'package:kamus_banjar_mobile_app/service/dictionary_service.dart';

class DictionaryRepository {
  final DictionaryService dictionaryService;

  const DictionaryRepository({required this.dictionaryService});

  Future<List<String>> getAlphabets() async {
    return await dictionaryService.getAlphabets();
  }

  Future<List<String>> getWords(String alphabet) async {
    return await dictionaryService.getWords(alphabet);
  }

  Future<Word> getWord(String word) async {
    return await dictionaryService.getWord(word);
  }
}