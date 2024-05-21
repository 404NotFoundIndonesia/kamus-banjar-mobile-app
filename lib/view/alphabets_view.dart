import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/view/words_view.dart';

class AlphabetsView extends StatefulWidget {
  final DictionaryRepository dictionaryRepository;

  const AlphabetsView({super.key, required this.dictionaryRepository});

  @override
  State<AlphabetsView> createState() => _AlphabetsViewState();
}

class _AlphabetsViewState extends State<AlphabetsView> {
  late Future<List<String>> _alphabets;

  @override
  void initState() {
    super.initState();
    _alphabets = widget.dictionaryRepository.getAlphabets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(20),
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
                  "Daftar Abjad",
                  style: GoogleFonts.poppins().copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.yellowAccent,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<String>>(
                future: _alphabets,
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
                          style: GoogleFonts.poppins().copyWith(fontSize: 12, color: Colors.redAccent),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Text(
                          'Abjad Bahasa Banjar tidak ada!',
                          style: GoogleFonts.poppins().copyWith(fontSize: 12, color: Colors.black45),
                        ),
                      ),
                    );
                  } else {
                    final List<String> alphabets = snapshot.data!;
                    return Expanded(
                      child: GridView.count(
                        crossAxisCount: 4,
                        children: List.generate(alphabets.length, (index) {
                          return GestureDetector(
                            child: Card(
                              color: Colors.white,
                              child: Center(
                                child: Text(
                                  alphabets[index].toUpperCase(),
                                  style: GoogleFonts.poppins().copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WordsView(alphabet: alphabets[index], dictionaryRepository: widget.dictionaryRepository))),
                          );
                        }),
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
