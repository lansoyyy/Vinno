import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';

class AdminStaffRegistrationSuccess extends StatefulWidget {
  const AdminStaffRegistrationSuccess({super.key});

  @override
  State<AdminStaffRegistrationSuccess> createState() =>
      _AdminStaffRegistrationSuccessState();
}

class _AdminStaffRegistrationSuccessState
    extends State<AdminStaffRegistrationSuccess> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 60,
                  ),
                ),

                const SizedBox(height: 40),

                // Success Title
                const Text(
                  "Registration Successful",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Success Message
                const Text(
                  "The account registration was successful! This can be now logged in and start using this account securely.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 80),

                // Go back to Managers Button
                ElevatedButton(
                  onPressed: () async {
                    // Check if the current user is the newly created admin/staff
                    User? currentUser = _authService.currentUser;
                    if (currentUser != null) {
                      // Get user data to check account type
                      DocumentSnapshot? userData =
                          await _authService.getUserData(currentUser.uid);
                      if (userData != null && userData.exists) {
                        Map<String, dynamic> data =
                            userData.data() as Map<String, dynamic>;
                        String accountType = data['accountType'] ?? '';

                        // If current user is Admin or Staff, sign them out
                        if (accountType == 'Admin' || accountType == 'Staff') {
                          await _authService.signOut();

                          // Navigate to login page since the owner is not signed in
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                          return;
                        }
                      }
                    }

                    // Navigate back to connected devices/managers page
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/connectedDevices',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Go back to Managers",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
