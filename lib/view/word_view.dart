import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/model/word.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';

class WordView extends StatefulWidget {
  final String word;
  final DictionaryRepository dictionaryRepository;

  const WordView(
      {super.key, required this.word, required this.dictionaryRepository});

  @override
  State<WordView> createState() => _WordViewState();
}

class _WordViewState extends State<WordView> {
  late Future<Word> word;

  @override
  void initState() {
    super.initState();
    word = widget.dictionaryRepository.getWord(widget.word);
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
                  widget.word,
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
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.word,
                  style: GoogleFonts.poppins().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                FutureBuilder<Word>(future: word, builder: (context, snapshot) {
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
                  } else if (!snapshot.hasData) {
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
                    final Word word = snapshot.data!;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        word.syllable.isEmpty ? const SizedBox(): Text(word.syllable, style: GoogleFonts.poppins()
                            .copyWith(fontSize: 14, color: Colors.black45),),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: ListView.builder(
                            itemBuilder: (context, index1) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Definisi', style: GoogleFonts.poppins().copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),),
                                  ListView.builder(itemBuilder: (context, index2) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(word.definitions[index1][index2].definition, style: GoogleFonts.poppins()
                                          .copyWith(fontSize: 14),),
                                    );
                                  }, itemCount: word.definitions[index1].length, shrinkWrap: true,)
                                ],
                              );
                            },
                            itemCount: word.definitions.length,
                            shrinkWrap: true,
                          ),
                        )
                      ],
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
