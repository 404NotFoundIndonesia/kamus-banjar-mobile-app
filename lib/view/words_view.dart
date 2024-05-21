import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kamus Banjar",
                style: GoogleFonts.poppins().copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  'Abjad ${widget.alphabet.toUpperCase()}',
                  style: GoogleFonts.poppins().copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.yellowAccent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Cari Kosakata...',
                    border: InputBorder.none,
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),
            FutureBuilder(
                future: _words,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(60.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.poppins()
                              .copyWith(fontSize: 12, color: Colors.redAccent),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Text(
                          'Kosakata Bahasa Banjar tidak ditemukan!',
                          style: GoogleFonts.poppins()
                              .copyWith(fontSize: 12, color: Colors.black45),
                        ),
                      ),
                    );
                  } else {
                    final List<String> words = snapshot.data!.where((word) => word.contains(_searchController.text)).toList();
                    return Expanded(child: ListView.builder(
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WordView(dictionaryRepository: widget.dictionaryRepository, word: words[index],))),
                          child: Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Text(
                                words[index],
                                style: GoogleFonts.poppins().copyWith(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        itemCount: words.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                    ));
                  }
                }),
          ],
        ),
      ),
    );
  }
}
