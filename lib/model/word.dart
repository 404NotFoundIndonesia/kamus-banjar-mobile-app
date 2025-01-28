class Word {
  late String word;
  late String alphabet;
  late String syllable;
  late List<List<WordDefinition>> definitions;
  late List<WordDerivative> derivatives; // Added derivatives property

  Word.fromJson(Map<String, dynamic> json) {
    word = json['word'];
    alphabet = json['alphabet'];
    syllable = json['syllables'] ?? '';

    // Parsing definitions
    List<List<WordDefinition>> tempDefinitions = [];
    for (var meaning in json['meanings']) {
      List<WordDefinition> meaningDefinition = [];
      for (var definition in meaning['definitions'] ?? []) {
        meaningDefinition.add(WordDefinition.fromJson(definition));
      }
      tempDefinitions.add(meaningDefinition);
    }
    definitions = tempDefinitions;

    // Parsing derivatives
    List<WordDerivative> tempDerivatives = [];
    for (var derivative in json['derivatives'] ?? []) {
      tempDerivatives.add(WordDerivative.fromJson(derivative));
    }
    derivatives = tempDerivatives;
  }
}

class WordDefinition {
  late String definition;
  late String partOfSpeech;
  late List<WordExample> examples;

  WordDefinition.fromJson(Map<String, dynamic> json) {
    definition = json['definition'] ?? '-';
    partOfSpeech = json['partOfSpeech'] ?? '-';
    List<WordExample> tempExamples = [];
    for (var example in json['examples'] ?? []) {
      tempExamples.add(WordExample.fromJson(example));
    }
    examples = tempExamples;
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

class WordDerivative {
  late String word;
  late String syllable;
  late List<WordDefinition> definitions;

  WordDerivative.fromJson(Map<String, dynamic> json) {
    word = json['word'];
    syllable = json['syllables'] ?? '';
    List<WordDefinition> tempDefinitions = [];
    for (var definition in json['definitions'] ?? []) {
      tempDefinitions.add(WordDefinition.fromJson(definition));
    }
    definitions = tempDefinitions;
  }
}
