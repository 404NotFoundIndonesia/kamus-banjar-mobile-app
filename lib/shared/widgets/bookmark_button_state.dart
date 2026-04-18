import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/auth_repository.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/saved_words_repository.dart';
import 'package:provider/provider.dart';

class BookmarkButton extends StatefulWidget {
  final String word;

  const BookmarkButton({super.key, required this.word});

  @override
  BookmarkButtonState createState() => BookmarkButtonState();
}

class BookmarkButtonState extends State<BookmarkButton> {
  bool _isWordSaved = false;
  String? _savedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfWordSaved());
  }

  Future<void> _checkIfWordSaved() async {
    if (!mounted) return;
    final savedRepo = context.read<SavedWordsRepository>();
    final savedWords = await savedRepo.loadSavedWords();

    for (var category in savedWords) {
      if (category.length > 1 && category[1].contains(widget.word)) {
        if (mounted) {
          setState(() {
            _isWordSaved = true;
            _savedCategory = category[0][0];
          });
        }
        return;
      }
    }

    if (mounted) {
      setState(() {
        _isWordSaved = false;
        _savedCategory = null;
      });
    }
  }

  String _toTitleCase(String text) {
    return text.split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    }).join(' ');
  }

  void _toggleWord(bool isAuthenticated, SavedWordsRepository savedRepo) {
    if (isAuthenticated) {
      _toggleServer(savedRepo);
    } else {
      if (_isWordSaved) {
        _showDeleteConfirmationDialog(savedRepo);
      } else {
        _showCategoryInputDialog(savedRepo);
      }
    }
  }

  Future<void> _toggleServer(SavedWordsRepository savedRepo) async {
    final isSaved = savedRepo.serverBookmarks.contains(widget.word);
    try {
      if (isSaved) {
        await savedRepo.removeBookmark(widget.word);
        Fluttertoast.showToast(
          msg: 'Kata dihapus dari markah',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 72, 93, 112),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        await savedRepo.addBookmark(widget.word);
        Fluttertoast.showToast(
          msg: 'Kata disimpan ke markah',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 72, 93, 112),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Terjadi kesalahan. Coba lagi.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _showCategoryInputDialog(SavedWordsRepository savedRepo) async {
    TextEditingController categoryController = TextEditingController();
    List<String> categories = await savedRepo.getAllCategories();
    String? selectedCategory;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masukkan Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (categories.isNotEmpty)
                DropdownButton<String>(
                  value: selectedCategory,
                  hint: const Text('Pilih kategori'),
                  isExpanded: true,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategory = value;
                    categoryController.text = value ?? '';
                  },
                ),
              TextField(
                controller: categoryController,
                decoration:
                    const InputDecoration(hintText: 'Kategori baru...'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BATAL'),
            ),
            TextButton(
              onPressed: () async {
                final category =
                    categoryController.text.trim().toLowerCase();
                if (category.isNotEmpty) {
                  Navigator.pop(context);
                  await savedRepo.saveWord(category, widget.word);
                  Fluttertoast.showToast(
                    msg: 'Kata disimpan ke ${_toTitleCase(category)}',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                    backgroundColor: const Color.fromARGB(255, 72, 93, 112),
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  if (mounted) {
                    setState(() {
                      _isWordSaved = true;
                      _savedCategory = category;
                    });
                  }
                }
              },
              child: const Text('SIMPAN'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(SavedWordsRepository savedRepo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Markah'),
          content: const Text(
              'Apakah Anda yakin ingin menghapus kata ini dari markah?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BATAL'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await savedRepo.removeWord(_savedCategory!, widget.word);
                Fluttertoast.showToast(
                  msg: 'Kata dihapus dari favorit',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: const Color.fromARGB(255, 72, 93, 112),
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                if (mounted) {
                  setState(() {
                    _isWordSaved = false;
                    _savedCategory = null;
                  });
                }
              },
              child: const Text('HAPUS'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedRepo = context.watch<SavedWordsRepository>();
    final auth = context.read<AuthRepository>();

    final bool isSaved = auth.isAuthenticated
        ? savedRepo.serverBookmarks.contains(widget.word)
        : _isWordSaved;

    return IconButton(
      icon: isSaved
          ? const Icon(Icons.bookmark)
          : const Icon(Icons.bookmark_outline),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      iconSize: 24,
      color: Colors.grey.shade600,
      onPressed: () => _toggleWord(auth.isAuthenticated, savedRepo),
    );
  }
}
