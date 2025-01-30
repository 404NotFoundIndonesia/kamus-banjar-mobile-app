import 'package:flutter/material.dart';
import 'package:kamus_banjar_mobile_app/model/word.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/view/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/view/word_detail_mobile.dart';
import 'package:kamus_banjar_mobile_app/view/word_detail_tablet.dart';

class WordView extends StatefulWidget {
  final String word;
  final DictionaryRepository dictionaryRepository;

  const WordView(
      {super.key, required this.word, required this.dictionaryRepository});

  @override
  State<WordView> createState() => _WordViewState();
}

class _WordViewState extends State<WordView> {
  late Future<Word> word;
  bool debugMode = false;

  @override
  void initState() {
    super.initState();
    word = widget.dictionaryRepository.getWord(widget.word);
  }

  double getStopValue(double width, double pixelValue) {
    return pixelValue / width;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    bool isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    return Scaffold(
      appBar: CustomAppBar(title: "Kamus Banjar", isClipped: isClipped),
      backgroundColor: Colors.white,
      body: FutureBuilder<Word>(
        future: word,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: CircularProgressIndicator(
                  color: Color.fromARGB(113, 33, 149, 243),
                  backgroundColor: Color.fromARGB(41, 33, 149, 243),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(
                child: Text('Kosakata Bahasa Banjar tidak ditemukan!'));
          } else {
            final Word word = snapshot.data!;
            return width > 600
                ? WordDetailsTablet(word: word)
                : WordDetailsMobile(word: word);
          }
        },
      ),
    );
  }
}
