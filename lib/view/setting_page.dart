import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/view/components/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/view/components/gradient_background.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});
  @override
  Widget build(BuildContext context) {
    bool isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    return Scaffold(
        appBar: CustomAppBar(
          title: "Pengaturan",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              spacing: 4,
                              children: [
                                Container(
                                  height: 160,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8)),
                                      border: Border.all(
                                          color: Colors.grey.shade500)),
                                ),
                                const Text("Terang"),
                              ],
                            ),
                            Column(
                              spacing: 4,
                              children: [
                                Container(
                                  height: 160,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade800,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8)),
                                      border: Border.all(
                                          color: Colors.grey.shade500)),
                                ),
                                const Text("Gelap"),
                              ],
                            ),
                            Column(
                              spacing: 4,
                              children: [
                                Container(
                                  height: 160,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8)),
                                      border: Border.all(
                                          color: Colors.grey.shade500)),
                                ),
                                const Text("Sistem"),
                              ],
                            ),
                          ],
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
