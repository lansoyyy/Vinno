import 'package:flutter/material.dart';
import 'package:smart_cb_1/util/background_img.dart';

class MobileSetup extends StatefulWidget {
  const MobileSetup({super.key});

  @override
  State<MobileSetup> createState() => MobileSetupState();
}

class MobileSetupState extends State<MobileSetup> {
  final TextEditingController mobileController = TextEditingController();

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double imgScale = 240;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    'images/Vinno-logo.png',
                    width: imgScale,
                    height: imgScale,
                  ),
                ),

                const SizedBox(height: 75),

                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 50),
                    child: const Text(
                      'Enter your mobile number',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),

                    /// TextField
                    child: TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,

                      decoration: InputDecoration(
                        hintText: "09xxxxxxxxx",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),

                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                    ),
                  ),
                ),

                ///Textfild-END
                const SizedBox(height: 195),

                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: const Text(
                      '"Register quickly and securely using your contact number to access and manage your Smart Circuit Breaker anytime, anywhere"',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// Next button
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
                    String mobileNum = mobileController.text;

                    Navigator.pushNamed(context, '/otp_page');
                    print(mobileNum); //test lng for parsing?
                  },

                  child: const Text("Next", style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
