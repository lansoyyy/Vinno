import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotPassOTP extends StatefulWidget {
  const ForgotPassOTP({super.key});

  @override
  State<ForgotPassOTP> createState() => _ForgotPassOTPState();
}

class _ForgotPassOTPState extends State<ForgotPassOTP> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String getOtpCode() {
    String code = "";
    for (final controller in _controllers) {
      code += controller.text;
    }
    return code;
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
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Icon(Icons.arrow_back, color: Colors.white),
                          ),

                          SizedBox(width: 20),

                          Text(
                            'Authentication',
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
                      Container(
                        padding: EdgeInsets.all(30.0),
                        width: MediaQuery.of(context).size.width * 0.85,
                        decoration: BoxDecoration(
                          color: Color(0xFF38CC77).withOpacity(0.20),

                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Match button shape
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Verify with Text Message',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              'A 6-digit code will be sent to',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            Text(
                              '09245299923',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 60),

                      const Text(
                        'Please Enter the Authentication Code',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),

                      /// OTP FIELDS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: RawKeyboardListener(
                              focusNode: FocusNode(),
                              onKey: (event) {
                                if (event is RawKeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.backspace) {
                                  if (_controllers[index].text.isEmpty &&
                                      index > 0) {
                                    // clear previous field and move focus back
                                    _controllers[index - 1].clear();
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_focusNodes[index - 1]);
                                  }
                                }
                              },
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                textInputAction: index < 5
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                decoration: const InputDecoration(
                                  counterText: "",
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    if (index < 5) {
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(_focusNodes[index + 1]);
                                    } else {
                                      _focusNodes[index].unfocus();
                                    }
                                  }
                                },
                                onTap: () {
                                  // prevent skipping forward
                                  if (index > 0 &&
                                      _controllers[index - 1].text.isEmpty) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_focusNodes[index - 1]);
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 30),
                      const Text.rich(
                        TextSpan(
                          style: TextStyle(fontSize: 16),
                          children: [
                            TextSpan(text: 'Didn\'t receive the code? '),
                            TextSpan(
                              text: 'RESEND',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
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
                    onPressed: () {
                      print(getOtpCode());
                      Navigator.pushReplacementNamed(
                        context,
                        '/forgot_change_pin',
                      );
                    },
                    child: const Text("VERIFY", style: TextStyle(fontSize: 20)),
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
