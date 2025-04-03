import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kamus_banjar_mobile_app/utils/saved_words_repository.dart';

class BookmarkButton extends StatefulWidget {
  final String word;

  const BookmarkButton({super.key, required this.word});

  @override
  BookmarkButtonState createState() => BookmarkButtonState();
}

class BookmarkButtonState extends State<BookmarkButton> {
  final SavedWordsRepository savedWordsRepository = SavedWordsRepository();
  bool _isWordSaved = false;
  String? _savedCategory;

  @override
  void initState() {
    super.initState();
    _checkIfWordSaved();
  }

  void _checkIfWordSaved() async {
    final savedWords = await savedWordsRepository.loadSavedWords();

    for (var category in savedWords) {
      if (category[1].contains(widget.word)) {
        setState(() {
          _isWordSaved = true;
          _savedCategory = category[0][0];
        });
        return;
      }
    }

    setState(() {
      _isWordSaved = false;
      _savedCategory = null;
    });
  }

  void _toggleWord() async {
    if (_isWordSaved) {
      _showDeleteConfirmationDialog();
    } else {
      _showCategoryInputDialog();
    }
  }

  String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
    }).join(' ');
  }

  void _showCategoryInputDialog() async {
    TextEditingController categoryController = TextEditingController();
    List<String> categories = await savedWordsRepository
        .getAllCategories(); // Get existing categories
    String? selectedCategory;

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Masukkan Kategori"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (categories
                  .isNotEmpty) // Show dropdown only if there are categories
                DropdownButton<String>(
                  value: selectedCategory,
                  hint: const Text("Pilih kategori"),
                  isExpanded: true,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategory = value;
                    categoryController.text = value ?? ""; // Update text field
                  },
                ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(hintText: "Kategori baru..."),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("BATAL"),
            ),
            TextButton(
              onPressed: () async {
                String category = categoryController.text.trim().toLowerCase();
                if (category.isNotEmpty) {
                  Navigator.pop(context);
                  await savedWordsRepository.saveWord(category, widget.word);
                  Fluttertoast.showToast(
                    msg: "Kata disimpan ke ${toTitleCase(category)}",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                    backgroundColor: const Color.fromARGB(255, 72, 93, 112),
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  _checkIfWordSaved();
                }
              },
              child: const Text("SIMPAN"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Markah"),
          content: const Text(
              "Apakah Anda yakin ingin menghapus kata ini dari markah?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("BATAL"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await savedWordsRepository.removeWord(
                    _savedCategory!, widget.word);
                Fluttertoast.showToast(
                  msg: "Kata dihapus dari favorit",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: const Color.fromARGB(255, 72, 93, 112),
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                _checkIfWordSaved();
              },
              child: const Text("HAPUS"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isWordSaved
          ? const Icon(Icons.bookmark)
          : const Icon(Icons.bookmark_outline),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      iconSize: 24,
      color: Colors.grey.shade600,
      onPressed: _toggleWord,
    );
  }
}
