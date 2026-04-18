import 'package:flutter/material.dart';
import 'package:kamus_banjar_mobile_app/core/models/word.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/features/dictionary/widgets/word_detail_mobile.dart';
import 'package:kamus_banjar_mobile_app/features/dictionary/widgets/word_detail_tablet.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/error_view.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/gradient_background.dart';

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

  @override
  void initState() {
    super.initState();
    word = widget.dictionaryRepository.getWord(widget.word);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    bool isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    return Scaffold(
      appBar: CustomAppBar(
        title: "Kamus Banjar",
        subtitle: widget.word,
        isClipped: isClipped,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            bottom: false,
            child: FutureBuilder<Word>(
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
                  return ErrorView(
                      pageToRefresh: WordView(
                        word: widget.word,
                        dictionaryRepository: widget.dictionaryRepository,
                      ),
                      shortErrorMessage:
                          'Kosakata Bahasa Banjar tidak ditemukan!',
                      detailedErrorMessage: snapshot.error.toString());
                } else if (!snapshot.hasData) {
                  return ErrorView(
                      pageToRefresh: WordView(
                        word: widget.word,
                        dictionaryRepository: widget.dictionaryRepository,
                      ),
                      shortErrorMessage:
                          'Kosakata Bahasa Banjar tidak ditemukan!');
                } else {
                  final Word word = snapshot.data!;
                  return width > 600
                      ? WordDetailsTablet(word: word)
                      : WordDetailsMobile(word: word);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
