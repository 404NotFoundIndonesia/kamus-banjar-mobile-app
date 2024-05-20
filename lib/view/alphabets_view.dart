import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/service/dictionary_service.dart';

class AlphabetsView extends StatefulWidget {
  const AlphabetsView({super.key, required this.dictionaryService});

  final DictionaryService dictionaryService;

  @override
  State<AlphabetsView> createState() => _AlphabetsViewState();
}

class _AlphabetsViewState extends State<AlphabetsView> {
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellowAccent,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kamus Banjar", style: GoogleFonts.poppins().copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                "Daftar Abjad",
                style: GoogleFonts.poppins().copyWith(fontSize: 12),
              ),
            ),
            loading ? const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
            ) :Expanded(
              child: GridView.count(
                  crossAxisCount: 4,
                  children: List.generate(27, (index) {
                    return GestureDetector(
                      child: Card(
                        color: Colors.white,
                        child: Center(
                          child: Text('A', style: GoogleFonts.poppins().copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {},
                    );
                  }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}