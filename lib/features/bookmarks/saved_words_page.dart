import 'package:flutter/material.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/auth_repository.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/saved_words_repository.dart';
import 'package:kamus_banjar_mobile_app/features/dictionary/views/word_view.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

class SavedWordsPage extends StatefulWidget {
  final DictionaryRepository dictionaryRepository;

  const SavedWordsPage({super.key, required this.dictionaryRepository});

  @override
  State<SavedWordsPage> createState() => _SavedWordsPageState();
}

class _SavedWordsPageState extends State<SavedWordsPage> {
  List<List<List<String>>> _localSavedWords = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocalWords());
  }

  Future<void> _loadLocalWords() async {
    if (!mounted) return;
    final savedRepo = context.read<SavedWordsRepository>();
    final words = await savedRepo.loadSavedWords();
    if (mounted) {
      setState(() {
        _localSavedWords = words;
      });
    }
  }

  Future<void> _editCategoryName(int index) async {
    final savedRepo = context.read<SavedWordsRepository>();
    final oldCategory = _localSavedWords[index][0][0];
    final controller = TextEditingController(text: oldCategory);

    final newCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah nama kategori'),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('simpan'),
            ),
          ],
        );
      },
    );

    if (newCategory != null &&
        newCategory.isNotEmpty &&
        newCategory != oldCategory) {
      await savedRepo.editCategoryName(oldCategory, newCategory);
      _loadLocalWords();
    }
  }

  String _toTitleCase(String text) {
    return text.split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final bool isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    final auth = context.watch<AuthRepository>();

    return Scaffold(
      appBar: CustomAppBar(title: 'Markah', isClipped: isClipped),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: auth.isAuthenticated
                ? _ServerBookmarksView(
                    dictionaryRepository: widget.dictionaryRepository,
                  )
                : _GuestBookmarksView(
                    savedWords: _localSavedWords,
                    onEditCategory: _editCategoryName,
                    toTitleCase: _toTitleCase,
                    dictionaryRepository: widget.dictionaryRepository,
                    onWordRemoved: _loadLocalWords,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ServerBookmarksView extends StatelessWidget {
  final DictionaryRepository dictionaryRepository;

  const _ServerBookmarksView({required this.dictionaryRepository});

  String _toTitleCase(String text) {
    return text.split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final savedRepo = context.watch<SavedWordsRepository>();

    if (!savedRepo.serverFetched) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(113, 33, 149, 243),
          backgroundColor: Color.fromARGB(41, 33, 149, 243),
        ),
      );
    }

    final words = savedRepo.serverBookmarks.toList()..sort();

    if (words.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Belum ada kata di dalam markah',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Silakan tambah kata yang kalian sukai ke dalam markah',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${words.length} kata ditandai',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: words.map((word) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordView(
                        dictionaryRepository: dictionaryRepository,
                        word: word,
                      ),
                    ),
                  );
                },
                child: Text(
                  _toTitleCase(word),
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _GuestBookmarksView extends StatelessWidget {
  final List<List<List<String>>> savedWords;
  final Future<void> Function(int index) onEditCategory;
  final String Function(String) toTitleCase;
  final DictionaryRepository dictionaryRepository;
  final VoidCallback onWordRemoved;

  const _GuestBookmarksView({
    required this.savedWords,
    required this.onEditCategory,
    required this.toTitleCase,
    required this.dictionaryRepository,
    required this.onWordRemoved,
  });

  @override
  Widget build(BuildContext context) {
    if (savedWords.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
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
          ),
        ),
      );
    }

    return SingleChildScrollView(
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
                      ((MediaQuery.of(context).size.width / 300).floor()) -
                  32,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                        child: Text(
                          toTitleCase(category),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                        onPressed: () =>
                            onEditCategory(savedWords.indexOf(categoryData)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                              borderRadius: BorderRadius.circular(80),
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WordView(
                                  dictionaryRepository: dictionaryRepository,
                                  word: word,
                                ),
                              ),
                            );
                            onWordRemoved();
                          },
                          child: Text(
                            toTitleCase(word),
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
    );
  }
}
