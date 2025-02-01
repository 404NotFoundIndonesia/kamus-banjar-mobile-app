import 'package:flutter/material.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/view/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/view/word_view.dart';

class SavedWordsPage extends StatelessWidget {
  final List<List<List<String>>> savedWords;
  final DictionaryRepository dictionaryRepository;
  const SavedWordsPage({
    super.key,
    required this.dictionaryRepository,
    this.savedWords = const [
      [
        ['worse'],
        ['abilis', 'bungul', 'tambuk']
      ],
      [
        ['sopan'],
        ['ulun', 'pian']
      ],
    ],
  });

  @override
  Widget build(BuildContext context) {
    bool isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    return Scaffold(
      appBar: CustomAppBar(
          title: "Brangkas Kata",
          isClipped: isClipped,
          dictionaryRepository: dictionaryRepository),
      body: savedWords.isEmpty
          ? Container(
              color: Colors.white,
              child:
                  const Center(child: Text('Belum ada kata di dalam brangkas')))
          : Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: savedWords.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final category = savedWords[index][0].join(', ');
                  final words = savedWords[index][1];

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 219, 239, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category
                              .split(' ')
                              .map((e) =>
                                  e[0].toUpperCase() +
                                  e.substring(1).toLowerCase())
                              .join(' '),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: words.map((word) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.blue.shade400,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80),
                                ),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WordView(
                                    dictionaryRepository: dictionaryRepository,
                                    word: word,
                                  ),
                                ),
                              ),
                              child: Text(
                                word
                                    .split(' ')
                                    .map((e) =>
                                        e[0].toUpperCase() +
                                        e.substring(1).toLowerCase())
                                    .join(' '),
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
