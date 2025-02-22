import 'package:flutter/material.dart';
import 'package:kamus_banjar_mobile_app/view/components/gradient_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/view/components/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/view/word_view.dart';
import 'package:kamus_banjar_mobile_app/utils/saved_words_repository.dart';

class SavedWordsPage extends StatefulWidget {
  final DictionaryRepository dictionaryRepository;
  const SavedWordsPage({super.key, required this.dictionaryRepository});

  @override
  State<SavedWordsPage> createState() => _SavedWordsPageState();
}

class _SavedWordsPageState extends State<SavedWordsPage> {
  List<List<List<String>>> savedWords = [];
  final SavedWordsRepository _savedWordsRepository = SavedWordsRepository();

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

  Future<void> _editCategoryName(int index) async {
    String oldCategory = savedWords[index][0][0];
    TextEditingController controller = TextEditingController(text: oldCategory);

    String? newCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Category Name"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (newCategory != null &&
        newCategory.isNotEmpty &&
        newCategory != oldCategory) {
      await _savedWordsRepository.editCategoryName(oldCategory, newCategory);
      _loadSavedWords();
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: savedWords.map((categoryData) {
                          final category = categoryData[0][0];
                          final words = categoryData[1];

                          return Container(
                            width: MediaQuery.of(context).size.width /
                                    ((MediaQuery.of(context).size.width / 300)
                                        .floor()) -
                                32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 16, 0, 0),
                                      child: Text(
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
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.black38,
                                        size: 20,
                                      ),
                                      onPressed: () => _editCategoryName(
                                          savedWords.indexOf(categoryData)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Wrap(
                                    spacing: 4,
                                    children: words.map((word) {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.blue.shade400,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(80),
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
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
