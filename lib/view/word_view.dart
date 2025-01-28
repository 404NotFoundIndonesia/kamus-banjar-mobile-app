import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/model/word.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';

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

  double getStopValue(double width, double pixelValue) {
    return pixelValue / width;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Text(
            "Kamus Banjar",
            style: GoogleFonts.poppins().copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color.fromARGB(255, 234, 249, 255),
                Color.fromARGB(255, 219, 244, 255),
                Colors.white
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0, getStopValue(width, 50), getStopValue(width, 200)],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: Colors.black12,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.word
                  .split(' ')
                  .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
                  .join(' '),
              style: GoogleFonts.poppins().copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 42,
                height: 1.2,
              ),
            ),
            FutureBuilder<Word>(
              future: word,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(
                      child: Text('Kosakata Bahasa Banjar tidak ditemukan!'));
                } else {
                  final Word word = snapshot.data!;
                  return Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...word.definitions.expand((meaning) {
                            return meaning.map((def) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${def.definition} (${def.partOfSpeech})',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                      ]
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Turunan',
                                            style: TextStyle(fontSize: 20)),
                                        const SizedBox(height: 8),
                                        ...word.derivatives
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final index = entry.key;
                                          final derivative = entry.value;
                                          return Container(
                                            padding: const EdgeInsets.all(16.0),
                                            margin: EdgeInsets.only(
                                                bottom: index ==
                                                        word.derivatives
                                                                .length -
                                                            1
                                                    ? 0
                                                    : 16.0),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Text(
                                                  derivative.word,
                                                  style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                Text(derivative.syllable),
                                                ...derivative.definitions
                                                    .map((def) {
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          '${def.definition} (${def.partOfSpeech})',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      20)),
                                                      if (def.examples
                                                          .isNotEmpty) ...[
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
                                  )
                                ],
                              );
                            }).toList();
                          }),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),
                              Text('Raw data:',
                                  style: GoogleFonts.poppins().copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  )),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Word: ${word.word}'),
                                      Text('Alphabet: ${word.alphabet}'),
                                      const Text('Meanings:'),
                                      ...word.definitions.expand((meaning) {
                                        return meaning.map((def) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${def.definition} (${def.partOfSpeech})'),
                                              if (def.examples.isNotEmpty) ...[
                                                const Text('Examples:'),
                                                ...def.examples.map((example) {
                                                  return Text(
                                                      'BJN: ${example.bjn}, ID: ${example.id}');
                                                }),
                                              ]
                                            ],
                                          );
                                        }).toList();
                                      }),
                                      const Text('Derivatives:'),
                                      ...word.derivatives.map((derivative) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Word: ${derivative.word}'),
                                            Text(
                                                'Syllables: ${derivative.syllable}'),
                                            const Text('Definitions:'),
                                            ...derivative.definitions
                                                .map((def) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      '${def.definition} (${def.partOfSpeech})'),
                                                  if (def
                                                      .examples.isNotEmpty) ...[
                                                    const Text('Examples:'),
                                                    ...def.examples
                                                        .map((example) {
                                                      return Text(
                                                          'BJN: ${example.bjn}, ID: ${example.id}');
                                                    }),
                                                  ],
                                                ],
                                              );
                                            }),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
