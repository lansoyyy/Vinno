import 'package:flutter/material.dart';
import 'package:smart_cb_1/util/background_img.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double imgScale = 240;
    double imgTop = 80;

    return Scaffold(
      body: Stack(
        children: [
          const BackGroundImg(),

          //vinno logo
          Positioned(
            top: imgTop,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'images/Vinno-logo.png',
                width: imgScale,
                height: imgScale,
              ),
            ),
          ),

          //dialog intro
          Positioned(
            top: imgTop + imgScale + 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                "Transform your electrical system management with our innovative Vinno app. Developed using cutting-edge technology, this app allows users to remotely control and monitor circuit breakers through devices, thus eliminating the hassle of manual interaction. With real-time system updates and amplified flexibility, our app ensures efficient energy management, faster response to electrical issues, and greater ease of use. Whether you are at home or away, you now have complete control over your power with an innovative solution tailored for today's smart infrastructure.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.justify,
              ),
            ),
          ),

          // lets begin btn
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cblist');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C896),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Let’s Begin",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
