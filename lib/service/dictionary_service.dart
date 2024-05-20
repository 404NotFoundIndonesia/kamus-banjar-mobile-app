import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:kamus_banjar_mobile_app/model/word_model.dart';
import 'package:kamus_banjar_mobile_app/repository/alphabet_repository.dart';
import 'package:kamus_banjar_mobile_app/repository/word_repository.dart';

class DictionaryService extends ChangeNotifier {
  AlphabetRepository _alphabetRepository;
  WordRepository _wordRepository;

  DictionaryService(this._alphabetRepository, this._wordRepository);

  final List<String> _alphabets = [];
  final Map<String, List<String>> _words = {};
  final Map<String, Word> _definitions = {};

  UnmodifiableListView<String> get alphabets => UnmodifiableListView(_alphabets);
  UnmodifiableMapView<String, List<String>> get words => UnmodifiableMapView(_words);
  UnmodifiableMapView<String, Word> get definitions => UnmodifiableMapView(_definitions);


}