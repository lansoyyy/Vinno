import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_AddCB/cb_connection_success.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';
import 'package:smart_cb_1/util/const.dart';

class SearchConnection extends StatefulWidget {
  const SearchConnection({super.key});

  @override
  State<SearchConnection> createState() => _SearchConnectionState();
}

class _SearchConnectionState extends State<SearchConnection> {
  Map<String, dynamic>? cbData;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _saveCircuitBreakerData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (cbData == null) {
      cbData =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    }
  }

  Future<void> _saveCircuitBreakerData() async {
    // Wait a bit to get the data from didChangeDependencies
    await Future.delayed(const Duration(milliseconds: 500));

    if (cbData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No circuit breaker data found')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Get reference to Realtime Database
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

      // Create a unique key for this circuit breaker
      final String cbKey = cbData!['scbId'];

      // Prepare data for Realtime Database

      Map<String, dynamic> circuitBreakerData = {};
      if (box.read('accountType') == 'Admin' ||
          box.read('accountType') == 'Staff') {
        DocumentSnapshot? userData =
            await FirebaseAuthService().getUserData(user.uid);
        if (userData != null && userData.exists) {
          Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
          setState(() {
            circuitBreakerData = {
              'isOn': cbData!['isOn'],
              'scbName': cbData!['scbName'],
              'scbId': cbData!['scbId'],
              'circuitBreakerRating': cbData!['circuitBreakerRating'],
              'wifiName': cbData!['wifiName'],
              'wifiPassword': cbData!['wifiPassword'],
              'voltage': cbData!['voltage'],
              'current': cbData!['current'],
              'temperature': cbData!['temperature'],
              'power': cbData!['power'],
              'energy': cbData!['energy'],
              'latitude': cbData!['latitude'],
              'longitude': cbData!['longitude'],
              'ownerId': data['createdBy'],
              'createdAt': ServerValue.timestamp,
              'servoStatus': '',
            };
          });
        }
      } else {
        setState(() {
          circuitBreakerData = {
            'isOn': cbData!['isOn'],
            'scbName': cbData!['scbName'],
            'scbId': cbData!['scbId'],
            'circuitBreakerRating': cbData!['circuitBreakerRating'],
            'wifiName': cbData!['wifiName'],
            'wifiPassword': cbData!['wifiPassword'],
            'voltage': cbData!['voltage'],
            'current': cbData!['current'],
            'temperature': cbData!['temperature'],
            'power': cbData!['power'],
            'energy': cbData!['energy'],
            'latitude': cbData!['latitude'],
            'longitude': cbData!['longitude'],
            'ownerId': user.uid,
            'createdAt': ServerValue.timestamp,
            'servoStatus': '',
          };
        });
      }

      // Save to: circuitBreakers/{scbId}
      await dbRef.child('circuitBreakers').child(cbKey).set(circuitBreakerData);

      // Also add reference under user's circuit breakers
      await dbRef
          .child('users')
          .child(user.uid)
          .child('circuitBreakers')
          .child(cbKey)
          .set(true);

      setState(() {
        isSaving = false;
      });

      // Navigate to success page after saving
      Timer(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CBConnectionSuccess(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving circuit breaker: $e')),
      );

      // Still navigate after error (optional - you can change this)
      Timer(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CBConnectionSuccess(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF3FDD82),
              height: 500,
              width: 500,
              child: const Icon(
                Icons.wifi_rounded,
                size: 204,
                color: Color(0xFF287740),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Text(
                    isSaving
                        ? "Saving Circuit Breaker..."
                        : "Connection Successful!",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    maxLines: 2,
                    softWrap: true,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  if (isSaving)
                    const CircularProgressIndicator(
                      color: Color(0xFF3FDD82),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    "Ensure your SCB is powered on and within range of your Wi-Fi network",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("• ", style: TextStyle(fontSize: 30)),
                      Expanded(
                        child: Text(
                          "If no connection is found, check your Wi-Fi and try again ",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
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
    );
  }
}
