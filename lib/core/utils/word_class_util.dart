Map<String, String> wordClasses = {
  'n': 'nomina',
  'v': 'verba',
  'a': 'adjektiva',
  'pro': 'pronomina',
  'adv': 'adverbia',
  'num': 'numeralia',
  'p': 'partikel',
  'konj': 'konjungsi',
  'prep': 'preposisi',
  'interj': 'interjeksi',
  'klit': 'klitika',
  'dem': 'demonstrativa',
  'art': 'artikel',
};

String getWordClass(String input) {
  return wordClasses[input] ?? input;
}
