class Word {
  late String word;
  late String alphabet;
  late String syllable;
  late List<List<WordDefinition>> definitions;

  Word.fromJson(Map<String, dynamic> json) {
    word = json['word'];
    alphabet = json['alphabet'];
    syllable = json['syllables'] ?? '';
    for(var meaning in json['meanings']) {
      List<WordDefinition> meaningDefinition = [];
      for(var definition in meaning['definitions'] ?? []) {
        meaningDefinition.add(WordDefinition.fromJson(definition));
      }
      definitions.add(meaningDefinition);
    }
  }
}

class WordDefinition {
  late String definition;
  late String partOfSpeech;
  late List<WordExample> examples;

  WordDefinition.fromJson(Map<String, dynamic> json) {
    definition = json['definition'] ?? '-';
    partOfSpeech = json['partOfSpeech'] ?? '-';
    for(var example in json['examples'] ?? []) {
      examples.add(WordExample.fromJson(example));
    }
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