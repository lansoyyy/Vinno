import 'package:flutter/material.dart';
import 'package:smart_cb_1/util/background_img.dart';

class InitialSetup extends StatefulWidget {
  const InitialSetup({super.key});

  @override
  State<InitialSetup> createState() => _InitialSetupState();
}

class _InitialSetupState extends State<InitialSetup> {
  @override
  Widget build(BuildContext context) {
    double imgScale = 240;
    double imgTop = 50;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackGroundImg(),

          // Logo Image
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

          // Initial Setup
          Positioned(
            top: 300,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Intitial Setup',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
          ),

          //Dialog Box
          Positioned(
            top: 360,
            left: 20,
            right: 20,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  const SizedBox(height: 20),
                  const Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 16),
                      children: [
                        TextSpan(
                          text:
                              'We\'ll start configuring your SCB\nin just a few steps!\n\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        TextSpan(
                          text:
                              '1. Create your account \n2. Permission Requests\n3. App Walkthrough',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ), //Dialog Box
          //Next Btn
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,

            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade300,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 130,
                    vertical: 16,
                  ),

                  elevation: 5,
                ),

                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/mobile_num",
                    (route) => false, // this removes all previous routes
                  );
                },

                child: Text("Next", style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ], // children
      ),
    );
  }
}
