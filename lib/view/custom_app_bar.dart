import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isClipped;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.isClipped,
    this.showBackButton = true,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                title,
                style: GoogleFonts.poppins().copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          canPop && showBackButton
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          height: 1.0,
          color: Colors.black12,
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (isClipped ? 24 : 0));
}
