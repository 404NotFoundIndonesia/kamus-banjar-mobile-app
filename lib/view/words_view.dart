import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/view/components/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/view/components/error_view.dart';
import 'package:kamus_banjar_mobile_app/view/components/gradient_background.dart';
import 'package:kamus_banjar_mobile_app/view/word_view.dart';

class WordsView extends StatefulWidget {
  final String alphabet;
  final DictionaryRepository dictionaryRepository;

  const WordsView(
      {super.key, required this.alphabet, required this.dictionaryRepository});

  @override
  State<WordsView> createState() => _WordsViewState();
}

class _WordsViewState extends State<WordsView> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<String>> _words;

  @override
  void initState() {
    super.initState();
    _words = widget.dictionaryRepository.getWords(widget.alphabet);
  }

  double getStopValue(double width, double pixelValue) {
    return pixelValue / width;
  }

  @override
  Widget build(BuildContext context) {
    bool isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    return Scaffold(
      appBar: CustomAppBar(
          title: "Kamus Banjar",
          isClipped: isClipped,
          subtitle: widget.alphabet.toUpperCase(),
          dictionaryRepository: widget.dictionaryRepository),
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
                        color: const Color.fromARGB(255, 243, 243, 243),
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
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                            shortErrorMessage: 'Server tidak ditemukan!',
                            detailedErrorMessage: snapshot.error.toString());
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const ErrorView(
                            shortErrorMessage:
                                'Kosakata Bahasa Banjar tidak ditemukan!');
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
                                      color: const Color.fromARGB(
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
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 24,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 255, 255, 255),
                                      Color.fromARGB(0, 255, 255, 255)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: [0.3, 1],
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
