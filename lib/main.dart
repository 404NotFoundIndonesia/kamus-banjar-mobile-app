import 'package:flutter/material.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/service/dictionary_service.dart';
import 'package:kamus_banjar_mobile_app/view/alphabets_view.dart';

void main() {
  const DictionaryService dictionaryService = DictionaryService(baseUrl: 'http://kamus-banjar.404notfound.fun');
  const DictionaryRepository dictionaryRepository = DictionaryRepository(dictionaryService: dictionaryService);

  runApp(const MyApp(dictionaryRepository: dictionaryRepository,));
}

class MyApp extends StatelessWidget {
  final DictionaryRepository dictionaryRepository;

  const MyApp({super.key, required this.dictionaryRepository});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.amber),
      debugShowCheckedModeBanner: false,
      home: AlphabetsView(dictionaryRepository: dictionaryRepository),
    );
  }
}
