import 'package:flutter/material.dart';
import 'package:smart_cb_1/util/background_img.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double imgScale = 240;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFF2F2F2),
      body: Stack(
        children: [
          const BackGroundImg(),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // Logo
                Center(
                  child: Image.asset(
                    'images/Vinno-logotxt.png',
                    width: imgScale,
                    height: imgScale,
                  ),
                ),

                Container(
                  height: MediaQuery.of(context).size.height * .55,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Enter Pin
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 6,
                              ),
                              width: 190,

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '09235235599',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.sync_alt_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 80),

                          Text(
                            "Enter Your Pin",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 20),

                          /// PIN field
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 130,
                            ),
                            height: 100,
                            child: Stack(
                              children: [
                                TextField(
                                  controller: pinController,
                                  obscureText: true,
                                  obscuringCharacter:
                                      '●', // you can replace with *, •, etc.
                                  style: TextStyle(
                                    fontSize: 18, // makes dots bigger
                                    fontWeight: FontWeight.bold, // bold dots
                                    color: Colors.black,
                                  ),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 6,
                                  decoration: InputDecoration(
                                    hintText:
                                        "eg.123456", // 👈 use hintText instead of labelText
                                    hintStyle: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        196,
                                        196,
                                        196,
                                      ),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    filled: true, // enable filling
                                    fillColor: Color(
                                      0xffffffff,
                                    ).withOpacity(0.50), // set background color
                                    counterText: "",

                                    // 👇 customize border radius here
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        16.0,
                                      ), // rounded corners
                                      borderSide: BorderSide(
                                        color: Colors.black,
                                      ), // removes visible border line
                                    ),

                                    // 👇 also style focused border (when user taps)
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),

                                    // 👇 optional - style enabled border
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      /// Login Button
                      Column(
                        children: [
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
                              Navigator.pushNamed(context, '/cblist');
                            },

                            child: const Text(
                              "LOGIN",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),

                          SizedBox(height: 15),

                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/forgot_pin_otp');
                            },
                            child: Text(
                              "Forgot your PIN?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
