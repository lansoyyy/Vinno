import 'package:flutter/material.dart';
import 'package:smart_cb_1/Login_ForgotPass/Login/login.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 70),

              const Text(
                "TERMS & CONDITIONS",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Container(
                constraints: const BoxConstraints(
                  maxHeight: 400,
                  minHeight: 200,
                  maxWidth: double.infinity,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: const Text(
                    "By using our smart circuit breaker application, you agree to abide by these Terms and Conditions. This agreement grants you a limited, non-exclusive license to use the app for managing your smart circuit breaker device(s). You are responsible for securing your login credentials and adhering to all usage guidelines. Unauthorized use, including any attempts to interfere with the app’s operation or security, is prohibited.\n\nThe application may require updates from time to time to maintain functionality or improve security. By using the app, you agree to allow these automatic updates as necessary. We aim to provide reliable service but are not liable for any direct or indirect damages arising from the use or inability to use the application, including data loss, unauthorized access, or device malfunctions.\n\nWe reserve the right to terminate or restrict access to the app if these Terms are violated. These Terms and Conditions are governed by the laws of Philippines, and any disputes will be resolved under local jurisdiction. If you have questions regarding the Privacy Policy or Terms and Conditions, please contact us at SmartCB@gmail.com.",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),

              const SizedBox(height: 70),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "By checking this box, I confirm that I have read, understood, and agree to the Terms & Conditions.",
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isChecked
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade300,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text(
                  'ACCEPT',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
