import 'package:flutter/material.dart';

class PetLoader extends StatelessWidget {
  const PetLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.2),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: const Icon(
              Icons.pets,
              size: 60,
              color: Color.fromARGB(255, 92, 163, 221),
            ),
          );
        },
      ),
    );
  }
}
