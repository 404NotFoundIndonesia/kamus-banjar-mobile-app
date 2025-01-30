import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/repository/dictionary_repository.dart';
import 'package:kamus_banjar_mobile_app/view/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/view/words_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    bool isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    return Scaffold(
      appBar: CustomAppBar(
        title: "Kamus Banjar",
        isClipped: isClipped,
        showBackButton: false,
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
                            Icons.error_outline,
                            size: 40,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Abjad Bahasa Banjar tidak ada!',
                            style: GoogleFonts.poppins().copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black45,
                            ),
                            textAlign: TextAlign.center,
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
                            side: BorderSide(
                              color: total == 0
                                  ? Colors.black12
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                          color: total == 0
                              ? Colors.white
                              : const Color.fromARGB(255, 237, 247, 255),
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 60,
                              minWidth: 60,
                              minHeight: 115,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    letter.toUpperCase(),
                                    style: GoogleFonts.poppins().copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: total == 0
                                          ? Colors.grey
                                          : const Color.fromARGB(
                                              255, 50, 116, 182),
                                    ),
                                  ),
                                  Divider(
                                    color: total == 0
                                        ? Colors.black12
                                        : const Color.fromARGB(
                                            55, 25, 118, 210),
                                    thickness: 1,
                                    indent: 1,
                                    endIndent: 1,
                                    height: 10,
                                  ),
                                  Text(
                                    '$total',
                                    style: GoogleFonts.poppins().copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: total == 0
                                          ? Colors.grey
                                          : const Color.fromARGB(
                                              255, 50, 116, 182),
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
                                  builder: (context) => WordsView(
                                    alphabet: letter,
                                    dictionaryRepository:
                                        widget.dictionaryRepository,
                                  ),
                                ),
                              )
                            : Fluttertoast.showToast(
                                msg: "Kosakata belum tersedia di data server",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 2,
                                backgroundColor:
                                    const Color.fromARGB(255, 161, 75, 70),
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
      ),
    );
  }
}
