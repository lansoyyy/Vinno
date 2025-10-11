import 'package:flutter/material.dart';

class ForgotChangePin extends StatefulWidget {
  const ForgotChangePin({super.key});

  @override
  State<ForgotChangePin> createState() => _ForgotChangePinState();
}

class _ForgotChangePinState extends State<ForgotChangePin> {
  final TextEditingController pinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();

  ///pin toggle
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  @override
  void dispose() {
    pinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    String pin = pinController.text;
    String confirmPin = confirmPinController.text;

    if (pin.length < 4) {
      _showMessage("PIN must be at least 4 digits");
      return;
    }

    if (pin != confirmPin) {
      _showMessage("PINs do not match");
      return;
    }

    // Success logic here (e.g., save PIN, navigate)
    _showMessage("PIN set successfully!");
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // A helper function to build custom input borders
  OutlineInputBorder customBorder({
    double radius = 16.0,
    Color color = Colors.black,
    double width = 1.0,
    bool isFocused = false,
    bool noBorder = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: noBorder
          ? BorderSide.none
          : BorderSide(color: color, width: isFocused ? width : 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: CustomClipPath(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2ECC71), Color(0xFF1EA557)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    height: 140,
                  ),
                ),

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                        top: 50,
                        right: 30,
                        bottom: 30,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/forgot_pin_otp');
                            },
                            child: Icon(Icons.arrow_back, color: Colors.white),
                          ),

                          SizedBox(width: 20),

                          Text(
                            'Change PIN',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Container(
              height: MediaQuery.of(context).size.height * 0.78,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),

                            Icon(
                              Icons.pending_outlined,
                              size: 150,
                              color: Colors.grey,
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              "Change your PIN",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Enter your new PIN to secure your account.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 40),

                            /// PIN field
                            TextField(
                              controller: pinController,
                              obscureText: _obscurePin,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                labelText: "New PIN",
                                border: customBorder(
                                  noBorder: true,
                                ), // removes border
                                focusedBorder: customBorder(
                                  isFocused: true,
                                  color: Colors.grey,
                                  width: 2,
                                ),
                                enabledBorder: customBorder(color: Colors.grey),
                                counterText: "",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePin
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePin = !_obscurePin;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// Confirm PIN field
                            TextField(
                              controller: confirmPinController,
                              obscureText: _obscureConfirmPin,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                labelText: "Confirm PIN",
                                border: customBorder(
                                  noBorder: true,
                                ), // removes border
                                focusedBorder: customBorder(
                                  isFocused: true,
                                  color: Colors.grey,
                                  width: 2,
                                ),
                                enabledBorder: customBorder(color: Colors.grey),
                                counterText: "",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPin
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPin = !_obscureConfirmPin;
                                    });
                                  },
                                ),
                              ),
                            ),

                            SizedBox(height: 20),

                            Text(
                              "Make 4 to 6 PINS (eg. 1234 or 123456)",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _onConfirm();
                      print(pinController); //test parse lng?
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
                    child: const Text(
                      "SET",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    final path = Path();

    // (0,0) 1. Point
    path.lineTo(0, h - 50); //line 2
    path.quadraticBezierTo(
      w * 0.5, // 3 Point
      h, // 3 Point
      w, // 4 Point
      h - 50, // 4 Point
    ); // 4 Point
    path.lineTo(w, 0); // 5 Point
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
