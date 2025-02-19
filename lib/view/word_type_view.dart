import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/view/components/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class WordTypeView extends StatelessWidget {
  const WordTypeView({super.key});

  Future<void> _openlink(String link) async {
    final Uri url = Uri.parse(link);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Fluttertoast.showToast(
          msg: "Tidak dapat membuka $url",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Terjadi kesalahan: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    final Map<String, Map<String, dynamic>> kelasKata = {
      "Nomina (Kata Benda)": {
        "deskripsi": ["Kata yang merujuk pada nama orang, tempat, atau benda."],
        "contoh": ["buku", "rumah", "Jakarta"],
      },
      "Verba (Kata Kerja)": {
        "deskripsi": ["Kata yang menyatakan tindakan atau aktivitas."],
        "contoh": ["makan", "berlari", "menulis"],
      },
      "Adjektiva (Kata Sifat)": {
        "deskripsi": ["Kata yang menggambarkan sifat atau keadaan."],
        "contoh": ["cantik", "tinggi", "panas"],
      },
      "Adverbia (Kata Keterangan)": {
        "deskripsi": ["Kata yang memberikan keterangan tambahan."],
        "contoh": ["cepat", "sangat", "kemarin"],
      },
      "Pronomina (Kata Ganti)": {
        "deskripsi": ["Kata yang menggantikan nomina."],
        "contoh": ["saya", "kamu", "mereka"],
      },
      "Numeralia (Kata Bilangan)": {
        "deskripsi": ["Kata yang menyatakan jumlah atau urutan."],
        "contoh": ["satu", "dua", "ketiga"],
      },
      "Preposisi (Kata Depan)": {
        "deskripsi": ["Kata yang menghubungkan nomina dengan kata lain."],
        "contoh": ["di", "ke", "dari"],
      },
      "Konjungsi (Kata Penghubung)": {
        "deskripsi": ["Kata yang menghubungkan kata, frasa, atau klausa."],
        "contoh": ["dan", "atau", "tetapi"],
      },
      "Interjeksi (Kata Seru)": {
        "deskripsi": ["Kata yang mengungkapkan perasaan spontan."],
        "contoh": ["wah", "aduh", "wow"],
      },
      "Partikel": {
        "deskripsi": ["Kata yang berfungsi dalam struktur kalimat."],
        "contoh": ["lah", "kah", "pun"],
      },
      "Artikel": {
        "deskripsi": ["Kata yang membatasi atau menentukan nomina."],
        "contoh": ["si Kancil", "sang Raja"],
      },
    };
    return Scaffold(
        appBar: CustomAppBar(title: "Kelas Kata", isClipped: isClipped),
        body: Container(
          color: Colors.white,
          height: double.infinity,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mengenal Kelas Kata dalam Bahasa Indonesia",
                      style: GoogleFonts.poppins()
                          .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      "Memahami berbagai kelas kata dalam bahasa Indonesia sangat penting untuk meningkatkan kualitas tulisan dan komunikasi. Berikut adalah penjelasan formal mengenai 11 jenis kelas kata beserta contohnya",
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: kelasKata.entries.map((entry) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width /
                                        ((MediaQuery.of(context).size.width /
                                                240)
                                            .floor()) -
                                    32,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: GoogleFonts.poppins().copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...entry.value["deskripsi"]
                                        .map<Widget>((text) => Text(text))
                                        .toList(),
                                    const SizedBox(height: 4),
                                    const Text("Contoh:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Wrap(
                                      spacing: 4,
                                      children: entry.value["contoh"]
                                          .map<Widget>(
                                            (example) => Chip(
                                              label: Text(
                                                example,
                                                style: TextStyle(
                                                    color:
                                                        Colors.blue.shade700),
                                              ),
                                              backgroundColor:
                                                  Colors.blue.shade50,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32.0),
                                                side: const BorderSide(
                                                    color: Colors.transparent),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Links",
                      style: GoogleFonts.poppins().copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openlink(
                          "https://penerbitdeepublish.com/kelas-kata/"),
                      icon: Icon(Icons.link, color: Colors.blue.shade700),
                      label: Text(
                        'Sumber Referensi',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
