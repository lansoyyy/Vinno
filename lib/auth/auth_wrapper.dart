import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';
import 'package:smart_cb_1/Login_ForgotPass/Login/login.dart';
import 'package:smart_cb_1/IntroAndRegistration/initial_setup.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Navigation/navigation_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) async {
      if (mounted) {
        if (user == null) {
          // User is not authenticated, show initial setup/login flow
          setState(() {
            _isLoading = false;
          });
        } else {
          // User is authenticated, check account type and navigate accordingly
          DocumentSnapshot? userData = await _authService.getUserData(user.uid);
          if (userData != null && userData.exists) {
            Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
            String accountType = data['accountType'] ?? 'Owner';

            setState(() {
              _isLoading = false;
            });

            // Navigate based on account type
            if (accountType == 'Owner') {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/cblist',
                (route) => false,
              );
            } else if (accountType == 'Admin') {
              // Navigate to admin page when implemented
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/cblist', // Temporary route, update when admin page is ready
                (route) => false,
              );
            } else if (accountType == 'Staff') {
              // Navigate to staff page when implemented
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/cblist', // Temporary route, update when staff page is ready
                (route) => false,
              );
            } else {
              // Default to owner navigation
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/navigationpage',
                (route) => false,
              );
            }
          } else {
            // User data not found, but user is authenticated
            // Navigate to default page
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/cblist',
              (route) => false,
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFE8E8E8),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'images/Vinno-logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If not loading and user is not authenticated, show initial setup
    return const InitialSetup();
  }
}
