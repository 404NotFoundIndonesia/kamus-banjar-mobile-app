import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.bottomRight,
        radius: 1.5,
        colors: [
          Color.fromARGB(255, 255, 240, 217),
          Colors.white,
        ],
        stops: [0, 0.3],
      ),
    ));
  }
}
