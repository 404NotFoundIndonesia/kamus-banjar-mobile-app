import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/model/word.dart';
import 'package:kamus_banjar_mobile_app/utils/word_class_util.dart';
import 'package:kamus_banjar_mobile_app/view/components/bookmark_button_state.dart';
import 'package:kamus_banjar_mobile_app/view/word_type_view.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WordDetailsMobile extends StatelessWidget {
  WordDetailsMobile({super.key, required this.word});
  final Word word;
  final FlutterTts flutterTts = FlutterTts();

  void _speak(String text) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      Fluttertoast.showToast(
        msg: "Kata $text disalin ke papan klip",
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

  @override
  Widget build(BuildContext context) {
    int index = 0;
    word.word = word.word
        .split(' ')
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 85.4),
        child: IntrinsicHeight(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 8, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          word.word,
                          style: GoogleFonts.poppins().copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 32,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        iconSize: 24,
                        color: Colors.blue,
                        onPressed: () => _speak(word.word),
                      ),
                      IconButton(
                        icon: const Icon(Icons.content_copy),
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        iconSize: 20,
                        color: Colors.grey.shade600,
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
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 18, 41, 58)
                          : const Color.fromARGB(255, 219, 239, 255),
                      borderRadius: BorderRadius.circular(20),
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
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: Text(
                                          def.definition,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
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
                                            borderRadius:
                                                BorderRadius.circular(24),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
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
                                                    _highlightWord(example.id,
                                                        def.definition),
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                              ],
                            );
                          }).toList();
                        }),
                      ],
                    ),
                  ),
                ),
                if (word.derivatives.isNotEmpty) const SizedBox(height: 24),
                if (word.derivatives.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 39, 27, 15)
                            : const Color.fromARGB(255, 255, 218, 138),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            'Turunan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...word.derivatives.asMap().entries.map((entry) {
                            final derivative = entry.value;
                            derivative.word = derivative.word
                                .split(' ')
                                .map((e) =>
                                    e[0].toUpperCase() +
                                    e.substring(1).toLowerCase())
                                .join(' ');
                            return Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color.fromARGB(255, 75, 56, 25)
                                    : const Color.fromARGB(255, 255, 243, 192),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (derivative.word.isNotEmpty)
                                    Wrap(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4),
                                          child: Text(
                                            derivative.word,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 36,
                                          width: 36,
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.volume_up_outlined),
                                            padding: EdgeInsets.zero,
                                            iconSize: 24,
                                            color: Colors.grey.shade600,
                                            onPressed: () => _speak(
                                                derivative.syllable.isNotEmpty
                                                    ? derivative.syllable
                                                        .replaceAll('.', ' ')
                                                    : derivative.word),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 36,
                                          width: 36,
                                          child: IconButton(
                                            icon:
                                                const Icon(Icons.content_copy),
                                            iconSize: 20,
                                            color: Colors.grey.shade600,
                                            onPressed: () => _copyToClipboard(
                                                context, derivative.word),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (derivative.syllable.isNotEmpty)
                                    Text(
                                      derivative.syllable,
                                      style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ...derivative.definitions.map((def) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: Text(
                                                def.definition,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
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
                                                margin: const EdgeInsets.only(
                                                    top: 3),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? const Color(0xFFFB8C00)
                                                      : Colors.orange,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                child: Text(
                                                  getWordClass(
                                                      def.partOfSpeech),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        if (def.examples.isNotEmpty) ...[
                                          ...def.examples.map((example) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 8),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      '[bjn] ',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "monospace"),
                                                    ),
                                                    Expanded(
                                                      child: Text.rich(
                                                        _highlightWord(
                                                            example.bjn,
                                                            derivative.word),
                                                        style: TextStyle(
                                                          color: Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
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
                                                          fontFamily:
                                                              "monospace"),
                                                    ),
                                                    Expanded(
                                                      child: Text.rich(
                                                        _highlightWord(
                                                            example.id,
                                                            def.definition),
                                                        style: TextStyle(
                                                          color: Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
