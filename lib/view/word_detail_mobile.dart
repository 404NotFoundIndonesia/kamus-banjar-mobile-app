import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/model/word.dart';

class WordDetailsMobile extends StatelessWidget {
  final Word word;

  const WordDetailsMobile({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 80),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Text(
                    word.word
                        .split(' ')
                        .map((e) =>
                            e[0].toUpperCase() + e.substring(1).toLowerCase())
                        .join(' '),
                    style: GoogleFonts.poppins().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 32,
                      // height: 1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 219, 239, 255),
                      borderRadius: BorderRadius.circular(20),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                if (word.derivatives.isNotEmpty) const SizedBox(height: 24),
                if (word.derivatives.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                          const SizedBox(height: 24),
                          const Text('Turunan',
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          ...word.derivatives.asMap().entries.map((entry) {
                            final derivative = entry.value;
                            return Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 243, 192),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (derivative.word.isNotEmpty)
                                    Text(
                                      derivative.word,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  if (derivative.syllable.isNotEmpty)
                                    Text(derivative.syllable),
                                  ...derivative.definitions.map((def) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${def.definition} (${def.partOfSpeech})',
                                            style:
                                                const TextStyle(fontSize: 20)),
                                        if (def.examples.isNotEmpty) ...[
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
