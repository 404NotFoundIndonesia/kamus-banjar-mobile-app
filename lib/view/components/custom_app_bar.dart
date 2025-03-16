import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kamus_banjar_mobile_app/view/info_view.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final bool isClipped;
  final bool showBackButton;
  final bool showSavedButton;
  final bool showMoreButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.isClipped,
    this.showBackButton = true,
    this.showSavedButton = false,
    this.showMoreButton = false,
  });

  double getStopValue(double width, double value) {
    return value / width;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool canPop = Navigator.of(context).canPop();

    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Colors.white,
                  Color.fromARGB(255, 234, 249, 255),
                  Color.fromARGB(255, 219, 244, 255),
                  Colors.white
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  getStopValue(width, 5),
                  getStopValue(width, 50),
                  getStopValue(width, 100),
                  getStopValue(width, 200)
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      child: Text(
                        subtitle,
                        style: GoogleFonts.poppins().copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (canPop && showBackButton)
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          if (showMoreButton)
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: IconButton(
                    icon: const Icon(Icons.subject),
                    color: Colors.black,
                    tooltip: "Tentang",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InfoView(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(height: 1, width: width, color: Colors.black12),
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: SizedBox(),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (isClipped ? 30 : 0));
}
