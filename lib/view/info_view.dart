import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/view/components/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/view/components/gradient_background.dart';
import 'package:kamus_banjar_mobile_app/view/word_type_view.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoView extends StatelessWidget {
  const InfoView({super.key});

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
    return Scaffold(
        appBar: CustomAppBar(
          title: "Tentang Kamus Banjar",
          isClipped: isClipped,
        ),
        body: Container(
          color: Colors.white,
          child: SafeArea(
            child: Stack(
              children: [
                const GradientBackground(),
                SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Kamus Banjar API",
                            style: GoogleFonts.poppins().copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        const Text(
                          "Tujuan dari proyek ini adalah membuat API untuk kamus Bahasa Banjar-Indonesia, yang memberikan pengguna kemampuan untuk menerjemahkan kata dari Bahasa Banjar ke Bahasa Indonesia.",
                        ),
                        Text("Tentang Bahasa Banjar",
                            style: GoogleFonts.poppins().copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        const Text(
                          "Salah satu provinsi di pulau Kalimantan adalah Kalimantan Selatan (Kalsel). Hampir seluruh wilayah Kalsel dihuni oleh orang Banjar. Bahasa Banjar (BB) bagi masyarakat Banjar merupakan bahasa pengantar yang berfungsi sebagai alat komunikasi sehari-hari.",
                        ),
                        const Text(
                          "Bahasa Banjar dalam penyebarannya tidak hanya dikenal di wilayah Kalsel saja, tetapi juga di pesisir Kalimantan Tengah (Kalteng) dan Kalimantan Timur (Kaltim) bahkan sampai di sebagian kecil daerah Sumatera, seperti Muara Tungkal, Sapat, dan Tambilahan.",
                        ),
                        const Text(
                          "Bahasa Banjar memiliki dua dialek, yaitu Banjar Dialek Hulu dan Banjar Kuala. Ada sebagian fonem maupun kosakata Bahasa Banjar Dialek Hulu (BBDH) yang memiliki persamaan dan kemiripan dengan Bahasa Indonesia (BI) meski kedudukannya berbeda.",
                        ),
                        const Text(
                          "Persamaan fonem dan kosakata antara BBDH dan BI, contohnya,",
                        ),
                        DataTable(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columns: const [
                            DataColumn(
                                label: Text('BI',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('BBDH',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                          rows: const [
                            DataRow(cells: [
                              DataCell(Text('lambat')),
                              DataCell(Text('lambat'))
                            ]),
                            DataRow(cells: [
                              DataCell(Text('kayu')),
                              DataCell(Text('kayu'))
                            ]),
                            DataRow(cells: [
                              DataCell(Text('malam')),
                              DataCell(Text('malam'))
                            ]),
                            DataRow(cells: [
                              DataCell(Text('makan')),
                              DataCell(Text('makan'))
                            ]),
                          ],
                        ),
                        const Text(
                          "Kemiripan fonem dan kosakata antara BBDH dan BI, contohnya,",
                        ),
                        DataTable(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columns: const [
                            DataColumn(
                                label: Text('BI',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('BBDH',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                          rows: const [
                            DataRow(cells: [
                              DataCell(Text('beri')),
                              DataCell(Text('bari'))
                            ]),
                            DataRow(cells: [
                              DataCell(Text('hari')),
                              DataCell(Text('ari'))
                            ]),
                            DataRow(cells: [
                              DataCell(Text('lubang')),
                              DataCell(Text('luwang'))
                            ]),
                            DataRow(cells: [
                              DataCell(Text('meja')),
                              DataCell(Text('mija'))
                            ]),
                          ],
                        ),
                        const Text(
                          "Berdasarkan pengamatan di atas, antara BBDH dan BI sama-sama mengenal vokal [a], [i], dan [u]. Selain itu, kemiripan dari segi pengungkapan mengarah kepada fonem tertentu yang terdapat pada kosakata BBDH dan BI, contohnya makna hari yang dalam BI tulisan dan pengungkapannya hari sedang dalam BBDH ari.",
                        ),
                        const Text(
                          "Selain hal-hal yang telah dikemukakan, antara BBDH dan BI sebagai dua buah bahasa memiliki perbedaan, contohnya,",
                        ),
                        DataTable(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columns: const [
                            DataColumn(
                                label: Text('BI',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('BBDH',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                          rows: const [
                            DataRow(cells: [
                              DataCell(Text('cantik')),
                              DataCell(Text('bungas'))
                            ]),
                            DataRow(cells: [
                              DataCell(Text('mampu')),
                              DataCell(Text('kawa'))
                            ]),
                            DataRow(cells: [
                              DataCell(Text('arah')),
                              DataCell(Text('ampah'))
                            ]),
                            DataRow(cells: [
                              DataCell(Text('luas')),
                              DataCell(Text('ligar'))
                            ]),
                          ],
                        ),
                        const Text(
                          "Sebagian besar kosakata yang terdapat dalam BI memang tidak terdapat dalam BBDH begitu pula sebaliknya. Tentu saja perbedaan antara BBDH dan BI ini tidak terhitung banyaknya selain persamaan dan kemiripan yang juga tidak bisa diindahkan keberadaannya.",
                        ),
                        Text("Kontibutor",
                            style: GoogleFonts.poppins().copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8,
                            children: [
                              TextButton.icon(
                                onPressed: () =>
                                    _openlink("https://github.com/iqbaleff214"),
                                icon: Icon(Icons.language,
                                    color: Colors.blue.shade700),
                                label: Text(
                                  'M. Iqbal Effendi',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32)),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _openlink(
                                    "https://github.com/andikasujanadi"),
                                icon: Icon(Icons.language,
                                    color: Colors.blue.shade700),
                                label: Text(
                                  'Andika Sujanadi',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32)),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    _openlink("https://github.com/iklabib"),
                                icon: Icon(Icons.language,
                                    color: Colors.blue.shade700),
                                label: Text(
                                  'Iklabib',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text("Links",
                            style: GoogleFonts.poppins().copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8,
                            children: [
                              TextButton.icon(
                                onPressed: () => _openlink(
                                    "https://github.com/iqbaleff214/kamus-banjar-api"),
                                icon: Icon(Icons.link,
                                    color: Colors.blue.shade700),
                                label: Text(
                                  'API Repository',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32)),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _openlink(
                                    "https://github.com/404NotFoundIndonesia/kamus-banjar-mobile-app"),
                                icon: Icon(Icons.link,
                                    color: Colors.blue.shade700),
                                label: Text(
                                  'Mobile App Repository',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32)),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _openlink(
                                    "https://github.com/iqbaleff214/kamus-banjar-api/wiki/Tentang-Bahasa-Banjar"),
                                icon: Icon(Icons.link,
                                    color: Colors.blue.shade700),
                                label: Text(
                                  'Wiki Tentang Bahasa Banjar',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32)),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WordTypeView(),
                                      ));
                                },
                                icon: Icon(Icons.chevron_right_rounded,
                                    color: Colors.blue.shade700),
                                label: Text(
                                  'Kelas Kata',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
