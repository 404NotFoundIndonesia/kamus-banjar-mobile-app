class Word {
  late String word;
  late String alphabet;
  late String syllable;
  late List<List<WordDefinition>> definitions;

  Word.fromJson(Map<String, dynamic> json) {
    word = json['word'];
    alphabet = json['alphabet'];
    syllable = json['syllables'] ?? '';
    List<List<WordDefinition>> _definitions = [];

    for(var meaning in json['meanings']) {
      List<WordDefinition> meaningDefinition = [];
      for(var definition in meaning['definitions'] ?? []) {
        meaningDefinition.add(WordDefinition.fromJson(definition));
      }
      _definitions.add(meaningDefinition);
    }
    definitions = _definitions;
  }
}

class WordDefinition {
  late String definition;
  late String partOfSpeech;
  late List<WordExample> examples;

  WordDefinition.fromJson(Map<String, dynamic> json) {
    definition = json['definition'] ?? '-';
    partOfSpeech = json['partOfSpeech'] ?? '-';
    List<WordExample> _examples = [];
    for(var example in json['examples'] ?? []) {
      _examples.add(WordExample.fromJson(example));
    }
    examples = _examples;
  }
}

class WordExample {
  late String bjn;
  late String id;

  WordExample.fromJson(Map<String, dynamic> json) {
    bjn = json['bjn'];
    id = json['id'];
  }
}