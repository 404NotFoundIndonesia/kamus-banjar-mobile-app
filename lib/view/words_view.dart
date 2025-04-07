import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/view/alphabets_view.dart';
import 'package:kamus_banjar_mobile_app/view/components/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/view/components/error_view.dart';
import 'package:kamus_banjar_mobile_app/view/components/gradient_background.dart';
import 'package:kamus_banjar_mobile_app/view/word_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordsView extends StatefulWidget {
  final DictionaryRepository dictionaryRepository;
  final Widget? pageToRefresh;
  final String alphabet;

  const WordsView(
      {super.key,
      required this.alphabet,
      required this.dictionaryRepository,
      this.pageToRefresh});

  @override
  State<WordsView> createState() => _WordsViewState();
}

class _WordsViewState extends State<WordsView> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _alphabets;
  late Future<List<String>> _words = Future.value([]);
  Timer? _debounce;
  List<String> _fuzzyWords = [];

  @override
  void initState() {
    super.initState();
    _alphabets = widget.dictionaryRepository.getAlphabets();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final selected = prefs.getString('selectedAlphabet') ?? widget.alphabet;

    setState(() {
      _words = widget.dictionaryRepository.getWords(selected);
    });
  }

  double getStopValue(double width, double pixelValue) {
    return pixelValue / width;
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _fetchWords(query);
      } else {
        setState(() {
          _fuzzyWords = [];
        });
      }
    });
  }

  void _fetchWords(String query) async {
    try {
      List<String> fuzzyWords =
          await widget.dictionaryRepository.searchWords(query);
      final words = await _words;

      setState(() {
        _fuzzyWords = fuzzyWords.where((word) {
          return !words.contains(_searchController.text);
        }).toList();
      });
    } catch (e) {
      setState(() {
        _fuzzyWords = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String selectedAlphabet = "";
    return Scaffold(
      appBar: CustomAppBar(
        title: "Kamus Banjar",
        isClipped: isClipped,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : const Color.fromARGB(255, 243, 243, 243),
                        border: Border.all(
                          color: Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Icon(Icons.search),
                          ),
                          Expanded(
                            child: Container(
                              height: 48,
                              margin: const EdgeInsets.all(0),
                              padding: const EdgeInsets.all(0),
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(fontSize: 18),
                                decoration: const InputDecoration(
                                  hintText: 'Cari Kosakata',
                                  border: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                ),
                                onChanged: (value) => _onSearchChanged(value),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _alphabets,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Container();
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Container();
                          } else {
                            final List<Map<String, dynamic>> alphabets =
                                snapshot.data!;
                            return Row(
                              spacing: 8.0,
                              children:
                                  List.generate(alphabets.length, (index) {
                                final letter = alphabets[index]['letter'];
                                final total = alphabets[index]['total'];

                                return GestureDetector(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32.0),
                                      side: BorderSide(
                                        color: total == 0
                                            ? (isDarkMode
                                                ? Colors.white12
                                                : Colors.black12)
                                            : Colors.transparent,
                                        width: 1,
                                      ),
                                    ),
                                    elevation: 0,
                                    color: total == 0
                                        ? (isDarkMode
                                            ? Colors.black
                                            : Colors.white)
                                        : (isDarkMode
                                            ? const Color.fromARGB(
                                                255, 30, 50, 70)
                                            : const Color.fromARGB(
                                                255, 237, 247, 255)),
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 60,
                                        minWidth: 60,
                                        minHeight: 115,
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              letter.toUpperCase(),
                                              style: GoogleFonts.poppins()
                                                  .copyWith(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: total == 0
                                                    ? (isDarkMode
                                                        ? Colors.grey.shade400
                                                        : Colors.grey)
                                                    : (isDarkMode
                                                        ? Colors
                                                            .lightBlue.shade200
                                                        : const Color.fromARGB(
                                                            255, 50, 116, 182)),
                                              ),
                                            ),
                                            Divider(
                                              color: total == 0
                                                  ? (isDarkMode
                                                      ? Colors.white12
                                                      : Colors.black12)
                                                  : (isDarkMode
                                                      ? Colors.blueGrey.shade600
                                                      : const Color.fromARGB(
                                                          55, 25, 118, 210)),
                                              thickness: 1,
                                              indent: 1,
                                              endIndent: 1,
                                              height: 10,
                                            ),
                                            Text(
                                              '$total',
                                              style: GoogleFonts.poppins()
                                                  .copyWith(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: total == 0
                                                    ? (isDarkMode
                                                        ? Colors.grey.shade400
                                                        : Colors.grey)
                                                    : (isDarkMode
                                                        ? Colors
                                                            .lightBlue.shade200
                                                        : const Color.fromARGB(
                                                            255, 50, 116, 182)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString('selectedAlphabet',
                                        letter.toUpperCase());
                                    setState(() {
                                      selectedAlphabet =
                                          prefs.getString('selectedAlphabet') ??
                                              "A";
                                      _words = widget.dictionaryRepository
                                          .getWords(selectedAlphabet);
                                    });
                                  },
                                );
                              }),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    child: _fuzzyWords.isNotEmpty
                        ? SizedBox(
                            height: 72,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _fuzzyWords.length,
                              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 160,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color.fromARGB(55, 25, 118, 210)
                                        : const Color.fromARGB(
                                            255, 219, 239, 255),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WordView(
                                            dictionaryRepository:
                                                widget.dictionaryRepository,
                                            word: _fuzzyWords[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Center(
                                      child: Text(
                                        _fuzzyWords[index],
                                        style: GoogleFonts.poppins().copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(),
                  ),
                  FutureBuilder(
                    future: _words,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(60),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color.fromARGB(113, 33, 149, 243),
                              backgroundColor: Color.fromARGB(41, 33, 149, 243),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return ErrorView(
                          pageToRefresh: widget.pageToRefresh ??
                              AlphabetsView(
                                dictionaryRepository:
                                    widget.dictionaryRepository,
                              ),
                          shortErrorMessage: 'Server tidak ditemukan!',
                          detailedErrorMessage: snapshot.error.toString(),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return ErrorView(
                          shortErrorMessage: 'Abjad Bahasa Banjar tidak ada!',
                          pageToRefresh: widget.pageToRefresh ??
                              AlphabetsView(
                                dictionaryRepository:
                                    widget.dictionaryRepository,
                              ),
                        );
                      } else {
                        final List<String> words = snapshot.data!
                            .where(
                                (word) => word.contains(_searchController.text))
                            .toList();
                        return Expanded(
                          child: Stack(
                            children: [
                              GridView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 24, 30, 30),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      (MediaQuery.of(context).size.width / 180)
                                          .floor(),
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 2,
                                ),
                                itemCount: words.length,
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WordView(
                                        dictionaryRepository:
                                            widget.dictionaryRepository,
                                        word: words[index],
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color.fromARGB(
                                              55, 25, 118, 210)
                                          : const Color.fromARGB(
                                              255, 219, 239, 255),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.transparent,
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            words[index],
                                            style:
                                                GoogleFonts.poppins().copyWith(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? [
                                            Colors.black,
                                            Colors.transparent,
                                          ]
                                        : [
                                            Colors.white,
                                            const Color.fromARGB(
                                                0, 255, 255, 255),
                                          ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.3, 1],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
