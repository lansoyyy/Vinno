import 'package:flutter/material.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
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
                "PRIVACY POLICY",
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
                    BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))
                  ],
                ),
                child: SingleChildScrollView(
                  child: const Text(
                    "Our smart circuit breaker application values your privacy and is committed to protecting your personal information. We collect personal data such as your name, email, and contact details when you register, as well as device usage data like model, software version, and circuit breaker data (such as energy consumption and operational status). This information is used to enhance user experience, optimize app performance, and troubleshoot any issues that may arise.\n\nWe prioritize data security by employing encryption and secure storage practices. Access to data is restricted to authorized personnel only, and we conduct regular security audits. You have the right to request access, correction, or deletion of your personal data, and may also opt out of data collection, though doing so may limit certain features of the app. Our Privacy Policy may be updated periodically, and we will notify users of significant changes. By continuing to use the app, you accept any revised policies.\n\nYour data is used solely for providing, maintaining, and improving the smart circuit breaker service, and may also be utilized to communicate important updates, offer customer support, and deliver energy usage insights. We do not sell or share data with third parties for marketing purposes. Data may only be shared with trusted service providers, like cloud hosting providers, to support app functionality, or in response to legal requests or requirements.",
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
                      "By checking this box, I confirm that I have read, understood, and agree to the Privacy Policy.",
                      style: TextStyle(fontSize: 12), textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isChecked
                    ? () {
                        Navigator.pushNamed(context, '/terms');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
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
