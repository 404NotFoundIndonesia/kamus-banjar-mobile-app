import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamus_banjar_mobile_app/model/word.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/view/components/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/view/components/error_view.dart';
import 'package:kamus_banjar_mobile_app/view/components/gradient_background.dart';
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

  @override
  void initState() {
    super.initState();
    word = widget.dictionaryRepository.getWord(widget.word);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.orange,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  double getStopValue(double width, double pixelValue) {
    return pixelValue / width;
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
          dictionaryRepository: widget.dictionaryRepository),
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
                      shortErrorMessage:
                          'Kosakata Bahasa Banjar tidak ditemukan!',
                      detailedErrorMessage: snapshot.error.toString());
                } else if (!snapshot.hasData) {
                  return const ErrorView(
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
