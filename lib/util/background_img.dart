import 'package:flutter/material.dart';

class BackGroundImg extends StatelessWidget {
  const BackGroundImg({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/start-bg.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
