import 'package:flutter/material.dart';

class PinSuccess extends StatelessWidget {
  const PinSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 100, color: Colors.green),

                const SizedBox(height: 30),

                const Text(
                  'Successfully PIN set',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Your PIN has been successfully set.\nYou can now use your new PIN to access your account securely.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 300),
                
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/privacy');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade300,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 130,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 5,
                  ),
                  child: const Text('OKAY', style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
