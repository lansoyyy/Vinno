import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
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
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/mobile_num');
                  },
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 30,
                ),
              ),
            ),
            const SizedBox(height: 60),
            const Icon(Icons.lock_open, size: 125, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'VERIFICATION CODE',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Never share your Verification code with anyone.',
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
                          event.logicalKey == LogicalKeyboardKey.backspace) {
                        if (_controllers[index].text.isEmpty && index > 0) {
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
                        if (index > 0 && _controllers[index - 1].text.isEmpty) {
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

            const SizedBox(height: 10),
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
            const SizedBox(height: 170),
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
                Navigator.pushReplacementNamed(context, '/accountactivity');
              },
              child: const Text("VERIFY", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
