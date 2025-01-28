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
  late Future<List<Map<String, dynamic>>> _alphabets;

  @override
  void initState() {
    super.initState();
    _alphabets = widget.dictionaryRepository.getAlphabets();
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
          preferredSize: const Size.fromHeight(1.0), // Height of the border
          child: Container(
            height: 1.0, // Border height
            color: const Color.fromARGB(14, 0, 0, 0), // Border color
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _alphabets,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(60.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(113, 33, 149, 243),
                          backgroundColor: Color.fromARGB(41, 33, 149, 243),
                        ),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons
                                .error_outline, // Adding an error icon to enhance the visual cue
                            size: 40,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(
                              height:
                                  10), // Adding spacing between the icon and text
                          Text(
                            'Abjad Bahasa Banjar tidak ada!',
                            style: GoogleFonts.poppins().copyWith(
                              fontSize:
                                  14, // Slightly larger font size for better readability
                              fontWeight: FontWeight.w600,
                              color: Colors.black45,
                            ),
                            textAlign:
                                TextAlign.center, // Center align the text
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  final List<Map<String, dynamic>> alphabets = snapshot.data!;
                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(alphabets.length, (index) {
                      final letter = alphabets[index]['letter'];
                      final total = alphabets[index]['total'];

                      return GestureDetector(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                            side: const BorderSide(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                          color: Colors.white,
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 50,
                              minHeight: 90,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    letter.toUpperCase(),
                                    style: GoogleFonts.poppins().copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: total == 0
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                  const Divider(
                                    color: Colors.black12,
                                    thickness: 1,
                                    indent: 1,
                                    endIndent: 1,
                                    height: 10,
                                  ),
                                  Text(
                                    '$total',
                                    style: GoogleFonts.poppins().copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: total == 0
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordsView(
                              alphabet: letter,
                              dictionaryRepository: widget.dictionaryRepository,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
