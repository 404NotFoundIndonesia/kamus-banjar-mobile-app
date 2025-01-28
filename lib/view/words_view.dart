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

  double getStopValue(double width, double pixelValue) {
    return pixelValue / width;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Text(
            "Kamus Banjar",
            style: GoogleFonts.poppins().copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color.fromARGB(255, 234, 249, 255),
                Color.fromARGB(255, 219, 244, 255),
                Colors.white
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0, getStopValue(width, 50), getStopValue(width, 200)],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: Colors.black12,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black12,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(60),
                        color: Colors.blue[300],
                      ),
                      child: Center(
                        child: Text(
                          widget.alphabet.toUpperCase(),
                          style: GoogleFonts.poppins().copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 60,
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Cari Kosakata...',
                            border: InputBorder.none,
                            fillColor: Colors.transparent,
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 19, horizontal: 16),
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
                    padding: EdgeInsets.all(60.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(113, 33, 149, 243),
                        backgroundColor: Color.fromARGB(41, 33, 149, 243),
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
                  final List<String> words = snapshot.data!
                      .where((word) => word.contains(_searchController.text))
                      .toList();
                  return Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            (MediaQuery.of(context).size.width / 200).floor(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2,
                      ),
                      itemCount: words.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordView(
                              dictionaryRepository: widget.dictionaryRepository,
                              word: words[index],
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  words[index],
                                  style: GoogleFonts.poppins().copyWith(
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
