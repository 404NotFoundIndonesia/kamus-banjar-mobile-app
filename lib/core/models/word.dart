class WordVotes {
  final int up;
  final int down;

  WordVotes({required this.up, required this.down});

  factory WordVotes.fromJson(Map<String, dynamic> json) {
    return WordVotes(
      up: json['up'] ?? 0,
      down: json['down'] ?? 0,
    );
  }
}

class WordMeaning {
  late List<WordDefinition> definitions;

  WordMeaning.fromJson(Map<String, dynamic> json) {
    List<WordDefinition> temp = [];
    for (var definition in json['definitions'] ?? []) {
      temp.add(WordDefinition.fromJson(definition));
    }
    definitions = temp;
  }
}

class Word {
  late String? id;
  late String word;
  late String alphabet;
  late String syllables;
  late String? source;
  late WordVotes? votes;
  late List<WordMeaning> meanings;
  late List<WordDerivative> derivatives;

  Word.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    word = json['word'];
    alphabet = json['alphabet'];
    syllables = json['syllables'] ?? '';
    source = json['source'];
    votes = json['votes'] != null ? WordVotes.fromJson(json['votes']) : null;

    List<WordMeaning> tempMeanings = [];
    for (var meaning in json['meanings'] ?? []) {
      tempMeanings.add(WordMeaning.fromJson(meaning));
    }
    meanings = tempMeanings;

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
  late String syllables;
  late List<WordDefinition> definitions;

  WordDerivative.fromJson(Map<String, dynamic> json) {
    word = json['word'];
    syllables = json['syllables'] ?? '';
    List<WordDefinition> tempDefinitions = [];
    for (var definition in json['definitions'] ?? []) {
      tempDefinitions.add(WordDefinition.fromJson(definition));
    }
    definitions = tempDefinitions;
  }
}
