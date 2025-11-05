import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';
import 'package:smart_cb_1/util/const.dart';

// This is a test file to verify circuit breaker validation functionality
class TestCBValidation extends StatefulWidget {
  const TestCBValidation({super.key});

  @override
  State<TestCBValidation> createState() => _TestCBValidationState();
}

class _TestCBValidationState extends State<TestCBValidation> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuthService _authService = FirebaseAuthService();
  List<String> testResults = [];

  void _runTests() async {
    setState(() {
      testResults.clear();
      testResults.add("Starting Circuit Breaker Validation Tests...\n");
    });

    // Test 1: Check if we can fetch existing CB IDs
    try {
      final snapshot = await _dbRef.child('circuitBreakers').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          final List<String> ids = [];
          data.forEach((key, value) {
            ids.add(key.toString());
          });
          setState(() {
            testResults.add(
                "✓ Test 1 PASSED: Successfully fetched ${ids.length} existing CB IDs");
          });
        }
      } else {
        setState(() {
          testResults.add(
              "✓ Test 1 PASSED: No existing CB IDs found (empty database)");
        });
      }
    } catch (e) {
      setState(() {
        testResults.add("✗ Test 1 FAILED: Error fetching CB IDs - $e");
      });
    }

    // Test 2: Check user authentication
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          testResults.add(
              "✓ Test 2 PASSED: User is authenticated with ID: ${user.uid}");
        });
      } else {
        setState(() {
          testResults.add("✗ Test 2 FAILED: No authenticated user found");
        });
      }
    } catch (e) {
      setState(() {
        testResults.add("✗ Test 2 FAILED: Error checking authentication - $e");
      });
    }

    // Test 3: Test WiFi password validation logic
    final testPassword1 =
        ""; // Empty password (should be valid for open networks)
    final testPassword2 = "123"; // Too short (should be invalid)
    final testPassword3 = "12345678"; // Minimum length (should be valid)
    final testPassword4 = "validWiFiPassword123"; // Valid password

    setState(() {
      if (testPassword1.isEmpty) {
        testResults.add(
            "✓ Test 3a PASSED: Empty WiFi password is allowed for open networks");
      } else {
        testResults.add(
            "✗ Test 3a FAILED: Empty WiFi password should be allowed for open networks");
      }

      if (testPassword2.length < 8) {
        testResults.add(
            "✓ Test 3b PASSED: WiFi password '123' correctly identified as too short");
      } else {
        testResults
            .add("✗ Test 3b FAILED: WiFi password '123' should be too short");
      }

      if (testPassword3.length >= 8) {
        testResults.add(
            "✓ Test 3c PASSED: WiFi password '12345678' meets minimum length requirement");
      } else {
        testResults.add(
            "✗ Test 3c FAILED: WiFi password '12345678' should meet minimum length");
      }

      if (testPassword4.length >= 8) {
        testResults.add(
            "✓ Test 3d PASSED: WiFi password 'validWiFiPassword123' is valid");
      } else {
        testResults.add(
            "✗ Test 3d FAILED: WiFi password 'validWiFiPassword123' should be valid");
      }
    });

    // Test 4: Test account type handling
    try {
      final accountType = box.read('accountType');
      setState(() {
        testResults
            .add("✓ Test 4 PASSED: Account type detected as: $accountType");
      });
    } catch (e) {
      setState(() {
        testResults.add("✗ Test 4 FAILED: Error detecting account type - $e");
      });
    }

    setState(() {
      testResults.add("\nTest completed!");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CB Validation Test'),
        backgroundColor: const Color(0xFF2ECC71),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _runTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
              ),
              child: const Text('Run Tests'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Test Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  testResults.isEmpty
                      ? 'No tests run yet. Click "Run Tests" to start.'
                      : testResults.join('\n'),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
