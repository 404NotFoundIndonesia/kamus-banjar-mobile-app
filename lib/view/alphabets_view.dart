import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/view/components/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/view/components/error_view.dart';
import 'package:kamus_banjar_mobile_app/view/components/gradient_background.dart';
import 'package:kamus_banjar_mobile_app/view/word_view.dart';
import 'package:kamus_banjar_mobile_app/view/words_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AlphabetsView extends StatefulWidget {
  final DictionaryRepository dictionaryRepository;
  final Widget? pageToRefresh;

  const AlphabetsView({
    super.key,
    required this.dictionaryRepository,
    this.pageToRefresh,
  });

  @override
  State<AlphabetsView> createState() => _AlphabetsViewState();
}

class _AlphabetsViewState extends State<AlphabetsView> {
  late Future<List<Map<String, dynamic>>> _alphabets;
  Timer? _debounce;
  List<String> _words = [];

  @override
  void initState() {
    super.initState();
    _alphabets = widget.dictionaryRepository.getAlphabets();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _fetchWords(query);
      } else {
        setState(() {
          _words = [];
        });
      }
    });
  }

  void _fetchWords(String query) async {
    try {
      List<String> words = await widget.dictionaryRepository.searchWords(query);
      setState(() {
        _words = words;
      });
    } catch (e) {
      setState(() {
        _words = [];
      });
    }
  }

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Kamus Banjar",
        isClipped: isClipped,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            const GradientBackground(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
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
                                controller: searchController,
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
                  _words.isEmpty
                      ? Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              width: double.infinity,
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: _alphabets,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(60.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return ErrorView(
                                      pageToRefresh: widget.pageToRefresh ??
                                          AlphabetsView(
                                            dictionaryRepository:
                                                widget.dictionaryRepository,
                                          ),
                                      shortErrorMessage:
                                          'Server tidak ditemukan!',
                                      detailedErrorMessage:
                                          snapshot.error.toString(),
                                    );
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return ErrorView(
                                      shortErrorMessage:
                                          'Abjad Bahasa Banjar tidak ada!',
                                      pageToRefresh: widget.pageToRefresh ??
                                          AlphabetsView(
                                            dictionaryRepository:
                                                widget.dictionaryRepository,
                                          ),
                                    );
                                  } else {
                                    final List<Map<String, dynamic>> alphabets =
                                        snapshot.data!;
                                    return Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: List.generate(alphabets.length,
                                          (index) {
                                        final letter =
                                            alphabets[index]['letter'];
                                        final total = alphabets[index]['total'];

                                        return GestureDetector(
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32.0),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      letter.toUpperCase(),
                                                      style:
                                                          GoogleFonts.poppins()
                                                              .copyWith(
                                                        fontSize: 32,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: total == 0
                                                            ? (isDarkMode
                                                                ? Colors.grey
                                                                    .shade400
                                                                : Colors.grey)
                                                            : (isDarkMode
                                                                ? Colors
                                                                    .lightBlue
                                                                    .shade200
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    50,
                                                                    116,
                                                                    182)),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: total == 0
                                                          ? (isDarkMode
                                                              ? Colors.white12
                                                              : Colors.black12)
                                                          : (isDarkMode
                                                              ? Colors.blueGrey
                                                                  .shade600
                                                              : const Color
                                                                  .fromARGB(
                                                                  55,
                                                                  25,
                                                                  118,
                                                                  210)),
                                                      thickness: 1,
                                                      indent: 1,
                                                      endIndent: 1,
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      '$total',
                                                      style:
                                                          GoogleFonts.poppins()
                                                              .copyWith(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: total == 0
                                                            ? (isDarkMode
                                                                ? Colors.grey
                                                                    .shade400
                                                                : Colors.grey)
                                                            : (isDarkMode
                                                                ? Colors
                                                                    .lightBlue
                                                                    .shade200
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    50,
                                                                    116,
                                                                    182)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          onTap: () => total > 0
                                              ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        WordsView(
                                                      alphabet: letter,
                                                      dictionaryRepository: widget
                                                          .dictionaryRepository,
                                                    ),
                                                  ),
                                                )
                                              : Fluttertoast.showToast(
                                                  msg:
                                                      "Kosakata belum tersedia di data server",
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 2,
                                                  backgroundColor: isDarkMode
                                                      ? Colors.red.shade900
                                                      : const Color.fromARGB(
                                                          255, 161, 75, 70),
                                                  textColor: Colors.white,
                                                  fontSize: 16.0,
                                                ),
                                        );
                                      }),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: _words.isNotEmpty
                              ? ListView.builder(
                                  itemCount: _words.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 30),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color.fromARGB(
                                                55, 25, 118, 210)
                                            : const Color.fromARGB(
                                                255, 219, 239, 255),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          _words[index],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WordView(
                                              dictionaryRepository:
                                                  widget.dictionaryRepository,
                                              word: _words[index],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
