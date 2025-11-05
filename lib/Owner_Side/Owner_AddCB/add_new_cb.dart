import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';
import 'package:smart_cb_1/util/const.dart';

class AddNewCb extends StatefulWidget {
  const AddNewCb({super.key});

  @override
  State<AddNewCb> createState() => _AddNewCbState();
}

class _AddNewCbState extends State<AddNewCb> {
  final TextEditingController cbName = TextEditingController();
  final TextEditingController cbID = TextEditingController();
  final TextEditingController ampValue = TextEditingController();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuthService _authService = FirebaseAuthService();

  List<String> existingCBIds = [];
  bool isLoadingCBIds = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchExistingCBIds();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Future<void> _fetchExistingCBIds() async {
    setState(() {
      isLoadingCBIds = true;
    });

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
            existingCBIds = ids;
            isLoadingCBIds = false;
          });
        }
      }
      setState(() {
        isLoadingCBIds = false;
      });
    } catch (e) {
      print('Error fetching CB IDs: $e');
      setState(() {
        isLoadingCBIds = false;
      });
    }
  }

  Future<bool> _checkIfCBIsOwned(String cbId) async {
    try {
      final snapshot = await _dbRef.child('circuitBreakers').child(cbId).get();
      if (snapshot.exists) {
        final cbData = Map<String, dynamic>.from(snapshot.value as Map);
        final ownerId = cbData['ownerId'];

        if (ownerId != null) {
          // Check if the current user is the owner
          if (box.read('accountType') == 'Admin' ||
              box.read('accountType') == 'Staff') {
            DocumentSnapshot? userData =
                await _authService.getUserData(currentUserId ?? '');
            if (userData != null && userData.exists) {
              Map<String, dynamic> data =
                  userData.data() as Map<String, dynamic>;
              return ownerId == data['createdBy'];
            }
          } else {
            return ownerId == currentUserId;
          }
        }
      }
      return false;
    } catch (e) {
      print('Error checking CB ownership: $e');
      return false;
    }
  }

  // A helper function to build custom input borders
  OutlineInputBorder customBorder({
    double radius = 16.0,
    Color color = Colors.black,
    double width = 1.0,
    bool isFocused = false,
    bool noBorder = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: noBorder
          ? BorderSide.none
          : BorderSide(color: color, width: isFocused ? width : 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/cblist');
                        },
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Add Circuit Breaker",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      // SCB Name
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Enter SCB Name:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextField(
                            controller: cbName,
                            decoration: InputDecoration(
                              hintText: "eg. Kitchen CB",
                              border: customBorder(
                                noBorder: true,
                              ), // removes border
                              focusedBorder: customBorder(
                                isFocused: true,
                                color: Colors.grey,
                                width: 2,
                              ),
                              enabledBorder: customBorder(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),

                      // SCB ID
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Enter SCB ID:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return existingCBIds.where((String option) {
                                return option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase());
                              });
                            },
                            onSelected: (String selection) {
                              cbID.text = selection;
                            },
                            fieldViewBuilder: (context, controller, focusNode,
                                onEditingComplete) {
                              controller.text = cbID.text;
                              controller.addListener(() {
                                cbID.text = controller.text;
                              });
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                onEditingComplete: onEditingComplete,
                                decoration: InputDecoration(
                                  hintText: "eg. AAAA-BBBB-CCCC-DDDD-1234",
                                  border: customBorder(
                                    noBorder: true,
                                  ), // removes border
                                  focusedBorder: customBorder(
                                    isFocused: true,
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  enabledBorder:
                                      customBorder(color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 30),

                      // SCB Amperage
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Enter the circuit breaker rating (A):',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextField(
                            controller: ampValue,
                            decoration: InputDecoration(
                              hintText: "eg. 100",
                              border: customBorder(
                                noBorder: true,
                              ), // removes border
                              focusedBorder: customBorder(
                                isFocused: true,
                                color: Colors.grey,
                                width: 2,
                              ),
                              enabledBorder: customBorder(color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '*Note: The maximum current it can handle is 200 A.',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Validate inputs
                        if (cbName.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter SCB Name')),
                          );
                          return;
                        }
                        if (cbID.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter SCB ID')),
                          );
                          return;
                        }
                        if (ampValue.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please enter circuit breaker rating')),
                          );
                          return;
                        }

                        // Parse amperage value
                        final rating = double.tryParse(ampValue.text.trim());
                        if (rating == null || rating <= 0 || rating > 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please enter a valid rating (1-200 A)')),
                          );
                          return;
                        }

                        // Check if CB ID exists and validate ownership
                        final String inputCbId = cbID.text.trim();
                        if (existingCBIds.contains(inputCbId)) {
                          // Check if this CB is already owned by someone else
                          final isOwned = await _checkIfCBIsOwned(inputCbId);
                          if (isOwned) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'This circuit breaker is already owned by you. Please use a different ID.')),
                            );
                            return;
                          } else {
                            // Check if it's owned by someone else
                            try {
                              final snapshot = await _dbRef
                                  .child('circuitBreakers')
                                  .child(inputCbId)
                                  .get();
                              if (snapshot.exists) {
                                final cbData = Map<String, dynamic>.from(
                                    snapshot.value as Map);
                                final ownerId = cbData['ownerId'];
                                if (ownerId != null &&
                                    ownerId != currentUserId) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'This circuit breaker is already owned by another user. Please use a different ID.')),
                                  );
                                  return;
                                }
                              }
                            } catch (e) {
                              print('Error checking CB ownership: $e');
                            }
                          }
                        }

                        // Navigate with data (WiFi password will be entered in next screen)
                        Navigator.pushNamed(
                          context,
                          '/wifi_connection_list',
                          arguments: {
                            'scbName': cbName.text.trim(),
                            'scbId': cbID.text.trim(),
                            'circuitBreakerRating': rating,
                          },
                        );
                      },
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
                      child: const Text(
                        'Add CB',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/cblist');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDDDDDD),
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
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
