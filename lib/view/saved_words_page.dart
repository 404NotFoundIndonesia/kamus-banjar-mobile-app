import 'package:flutter/material.dart';
import 'package:kamus_banjar_mobile_app/view/components/gradient_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/view/components/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/view/word_view.dart';

class SavedWordsPage extends StatefulWidget {
  final DictionaryRepository dictionaryRepository;
  const SavedWordsPage({super.key, required this.dictionaryRepository});

  @override
  State<SavedWordsPage> createState() => _SavedWordsPageState();
}

class _SavedWordsPageState extends State<SavedWordsPage> {
  List<List<List<String>>> savedWords = [];

  @override
  void initState() {
    super.initState();
    _loadSavedWords();
  }

  Future<void> _loadSavedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('saved_words');
    if (jsonString != null) {
      setState(() {
        savedWords = List<List<List<String>>>.from(
          jsonDecode(jsonString).map(
            (category) => List<List<String>>.from(
              category.map((sublist) => List<String>.from(sublist)),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    return Scaffold(
      appBar: CustomAppBar(
        title: "Markah",
        isClipped: isClipped,
      ),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: savedWords.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum ada kata di dalam markah',
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Silakan tambah kata yang kalian sukai ke dalam markah',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
                  )
                : ListView.builder(
                    itemCount: savedWords.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final category = savedWords[index][0].join(', ');
                      final words = savedWords[index][1];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
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
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WordView(
                                          dictionaryRepository:
                                              widget.dictionaryRepository,
                                          word: word,
                                        ),
                                      ),
                                    );
                                    _loadSavedWords();
                                  },
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
        ],
      ),
    );
  }
}
