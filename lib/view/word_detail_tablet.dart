import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/model/word.dart';

class WordDetailsTablet extends StatelessWidget {
  final Word word;
  const WordDetailsTablet({super.key, required this.word});

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

  @override
  Widget build(BuildContext context) {
    word.word = word.word
        .split(' ')
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
    return Expanded(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: (word.derivatives.isNotEmpty)
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Row(
                  children: [
                    SizedBox(width: word.derivatives.isNotEmpty ? 64 : 0),
                    Text(
                      word.word,
                      style: GoogleFonts.poppins().copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 32,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.content_copy),
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      iconSize: 24,
                      color: Colors.black26,
                      onPressed: () => _copyToClipboard(context, word.word),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 219, 239, 255),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...word.definitions.expand((meaning) {
                        return meaning.map((def) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (def.definition.isNotEmpty)
                                Text(
                                  '${def.definition} (${def.partOfSpeech})',
                                  style: const TextStyle(fontSize: 20),
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
                                          Text(example.bjn),
                                          Text(example.id),
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
                            const SizedBox(height: 4),
                            const SizedBox(
                              height: 0,
                              child: Icon(Icons.more_horiz,
                                  size: 24, color: Colors.black45),
                            ),
                            const SizedBox(height: 32),
                            const Text('Turunan',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Flexible(
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
                                              Row(
                                                children: [
                                                  Text(
                                                    derivative.word,
                                                    style: const TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  // const SizedBox(width: 8),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.content_copy),
                                                    iconSize: 16,
                                                    color: Colors.black26,
                                                    onPressed: () =>
                                                        _copyToClipboard(
                                                            context,
                                                            derivative.word),
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
                                                  Text(
                                                      '${def.definition} (${def.partOfSpeech})',
                                                      style: const TextStyle(
                                                          fontSize: 20)),
                                                  if (def
                                                      .examples.isNotEmpty) ...[
                                                    ...def.examples
                                                        .map((example) {
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(example.bjn),
                                                          Text(example.id),
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
                ],
              ),
            ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
