import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kamus_banjar_mobile_app/utils/saved_words_repository.dart';

class BookmarkButton extends StatefulWidget {
  final String word;
  final String category;

  const BookmarkButton({super.key, required this.word, required this.category});

  @override
  BookmarkButtonState createState() => BookmarkButtonState();
}

class BookmarkButtonState extends State<BookmarkButton> {
  final SavedWordsRepository savedWordsRepository = SavedWordsRepository();
  bool _isWordSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfWordSaved();
  }

  // Function to check if the word is saved
  void _checkIfWordSaved() async {
    final isSaved =
        await savedWordsRepository.isWordSaved(widget.category, widget.word);
    setState(() {
      _isWordSaved = isSaved;
    });
  }

  // Save or remove word function
  void _toggleWord() async {
    if (_isWordSaved) {
      // Remove word if already saved
      await savedWordsRepository.removeWord(widget.category, widget.word);
      Fluttertoast.showToast(
        msg: "Kata dihapus dari favorit",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: const Color.fromARGB(255, 72, 93, 112),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      // Save word if not saved
      await savedWordsRepository.saveWord(widget.category, widget.word);
      Fluttertoast.showToast(
        msg: "Kata disimpan ke favorit",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: const Color.fromARGB(255, 72, 93, 112),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    _checkIfWordSaved(); // Re-check if the word is saved after the operation
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
      onPressed: _toggleWord, // Toggle save/remove on press
    );
  }
}
