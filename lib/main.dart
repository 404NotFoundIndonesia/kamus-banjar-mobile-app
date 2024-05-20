import 'package:flutter/material.dart';
import 'package:kamus_banjar_mobile_app/repository/alphabet_repository.dart';
import 'package:kamus_banjar_mobile_app/repository/word_repository.dart';
import 'package:kamus_banjar_mobile_app/service/dictionary_service.dart';
import 'package:kamus_banjar_mobile_app/view/alphabets_view.dart';
import 'package:provider/provider.dart';

void main() {
  final AlphabetRepository alphabetRepository = AlphabetRepository();
  final WordRepository wordRepository = WordRepository();

  runApp(MultiProvider(
    providers: [
      ListenableProvider(create: (_) => DictionaryService(alphabetRepository, wordRepository)),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final dictionaryService = Provider.of<DictionaryService>(context);
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.amber),
      debugShowCheckedModeBanner: false,
      home: AlphabetsView(dictionaryService: dictionaryService),
    );
  }
}
