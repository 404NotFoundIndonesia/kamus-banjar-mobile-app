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

  void _showCategoryInputDialog() {
    TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Masukkan Kategori"),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(hintText: "Kategori..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("BATAL"),
            ),
            TextButton(
              onPressed: () async {
                String category = categoryController.text.trim();
                if (category.isNotEmpty) {
                  Navigator.pop(context);
                  await savedWordsRepository.saveWord(category, widget.word);
                  Fluttertoast.showToast(
                    msg: "Kata disimpan ke ${categoryController.text.trim()}",
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
      color: Colors.black26,
      onPressed: _toggleWord,
    );
  }
}
