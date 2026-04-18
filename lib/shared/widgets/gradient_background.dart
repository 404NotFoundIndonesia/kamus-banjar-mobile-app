import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.bottomRight,
          radius: 1.5,
          colors: isDark
              ? [
                  const Color.fromARGB(255, 49, 38, 22),
                  Colors.black,
                ]
              : const [
                  Color.fromARGB(255, 255, 240, 217),
                  Colors.white,
                ],
          stops: isDark ? const [0, 0.3] : const [0, 0.3],
        ),
      ),
    );
  }
}
