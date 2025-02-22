import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/model/word.dart';
import 'package:kamus_banjar_mobile_app/utils/word_class_util.dart';
import 'package:kamus_banjar_mobile_app/utils/saved_words_repository.dart';
import 'package:kamus_banjar_mobile_app/view/components/bookmark_button_state.dart';
import 'package:kamus_banjar_mobile_app/view/word_type_view.dart';

class WordDetailsTablet extends StatelessWidget {
  final Word word;
  WordDetailsTablet({super.key, required this.word});

  final SavedWordsRepository savedWordsRepository = SavedWordsRepository();

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      Fluttertoast.showToast(
        msg: "Kata disalin ke papan klip",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: const Color.fromARGB(255, 72, 93, 112),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  TextSpan _highlightWord(String text, String targets) {
    List<TextSpan> spans = [];
    List<String> targetList = targets.split(';').map((e) => e.trim()).toList();
    if (targetList.isEmpty) {
      return TextSpan(text: text);
    }
    String pattern = targetList.map(RegExp.escape).join('|');
    RegExp regExp = RegExp(pattern, caseSensitive: false);
    Iterable<RegExpMatch> matches = regExp.allMatches(text);
    int lastMatchEnd = 0;
    for (RegExpMatch match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      String matchedWord = match.group(0) ?? '';
      spans.add(
        TextSpan(
          text: matchedWord.toLowerCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }
    return TextSpan(children: spans);
  }

  Future<void> isWordSaved(String wordText) async {
    final isSaved =
        await savedWordsRepository.isWordSaved('default_category', wordText);
    if (isSaved) {
      Fluttertoast.showToast(
        msg: "Kata sudah disimpan",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: const Color.fromARGB(255, 72, 93, 112),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    word.word = word.word
        .split(' ')
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                children: [
                  Text(
                    word.word,
                    style: GoogleFonts.poppins().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 32,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.content_copy),
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    iconSize: 20,
                    color: Colors.black26,
                    onPressed: () => _copyToClipboard(context, word.word),
                  ),
                  BookmarkButton(
                    word: word.word,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5 - 50,
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 219, 239, 255),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...word.definitions.expand((meaning) {
                      index += 1;
                      return meaning.map((def) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (index > 1) const SizedBox(height: 8),
                            if (def.definition.isNotEmpty)
                              Wrap(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      def.definition,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const WordTypeView(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 51, 163, 255),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Text(
                                        getWordClass(def.partOfSpeech),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (def.examples.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  ...def.examples.map((example) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '[bjn] ',
                                              style: TextStyle(
                                                  fontFamily: "monospace"),
                                            ),
                                            Expanded(
                                              child: Text.rich(
                                                _highlightWord(
                                                    example.bjn, word.word),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '[id]  ',
                                              style: TextStyle(
                                                  fontFamily: "monospace"),
                                            ),
                                            Expanded(
                                              child: Text.rich(
                                                _highlightWord(
                                                    example.id, def.definition),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            const SizedBox(height: 8)
                          ],
                        );
                      }).toList();
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (word.derivatives.isNotEmpty)
          Flexible(
            child: Column(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 218, 138),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          const Text('Turunan',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Flexible(
                            child: SafeArea(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    ...word.derivatives
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final derivative = entry.value;
                                      derivative.word = derivative.word
                                          .split(' ')
                                          .map((e) =>
                                              e[0].toUpperCase() +
                                              e.substring(1).toLowerCase())
                                          .join(' ');
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 8, 16, 16),
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 255, 243, 192),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            if (derivative.word.isNotEmpty)
                                              Wrap(
                                                children: [
                                                  Text(
                                                    derivative.word,
                                                    style: const TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2),
                                                    child: SizedBox(
                                                      height: 32,
                                                      width: 32,
                                                      child: IconButton(
                                                        icon: const Icon(
                                                            Icons.content_copy),
                                                        iconSize: 16,
                                                        color: Colors.black26,
                                                        onPressed: () =>
                                                            _copyToClipboard(
                                                                context,
                                                                derivative
                                                                    .word),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (derivative.syllable.isNotEmpty)
                                              Text(derivative.syllable),
                                            ...derivative.definitions
                                                .map((def) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Wrap(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 8),
                                                        child: Text(
                                                            def.definition,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        20)),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const WordTypeView(),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(top: 3),
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  12, 0, 12, 2),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Colors.orange,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        24),
                                                          ),
                                                          child: Text(
                                                            getWordClass(def
                                                                .partOfSpeech),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  if (def
                                                      .examples.isNotEmpty) ...[
                                                    ...def.examples
                                                        .map((example) {
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                              height: 8),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Text(
                                                                '[bjn] ',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        "monospace"),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Text.rich(
                                                                  _highlightWord(
                                                                      example
                                                                          .bjn,
                                                                      derivative
                                                                          .word),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Text(
                                                                '[id]  ',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        "monospace"),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Text.rich(
                                                                  _highlightWord(
                                                                      example
                                                                          .id,
                                                                      def.definition),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                                  ],
                                                ],
                                              );
                                            }),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 24),
      ],
    );
  }
}
