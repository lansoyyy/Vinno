import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';

class AdminStaffRegistrationStep1 extends StatefulWidget {
  final String accountType; // 'Admin' or 'Staff'

  const AdminStaffRegistrationStep1({
    super.key,
    required this.accountType,
  });

  @override
  State<AdminStaffRegistrationStep1> createState() =>
      _AdminStaffRegistrationStep1State();
}

class _AdminStaffRegistrationStep1State
    extends State<AdminStaffRegistrationStep1> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    addressController.dispose();
    mobileController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  void _onNext() {
    String name = nameController.text.trim();
    String age = ageController.text.trim();
    String address = addressController.text.trim();
    String mobile = mobileController.text.trim();
    String birthday = birthdayController.text.trim();

    if (name.isEmpty ||
        age.isEmpty ||
        address.isEmpty ||
        mobile.isEmpty ||
        birthday.isEmpty) {
      _showMessage("Please fill out all fields.");
      return;
    }

    // Name validation - only alphabetic characters allowed
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      _showMessage("Name must only contain letters (no numbers or symbols).");
      return;
    }

    // Age validation - must be numeric
    if (int.tryParse(age) == null || int.parse(age) <= 0) {
      _showMessage("Please enter a valid age.");
      return;
    }

    // Mobile number validation - must be exactly 11 digits and start with "09"
    if (!RegExp(r'^09\d{9}$').hasMatch(mobile)) {
      _showMessage(
          "Mobile number must be exactly 11 digits and start with '09'.");
      return;
    }

    // Get the current owner's ID
    User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      _showMessage("Owner not authenticated. Please log in again.");
      return;
    }

    // Show password confirmation dialog
    _showPasswordConfirmationDialog(currentUser.uid, currentUser.email!, name,
        age, address, mobile, birthday);
  }

  void _showPasswordConfirmationDialog(
    String ownerId,
    String ownerEmail,
    String name,
    String age,
    String address,
    String mobile,
    String birthday,
  ) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Confirm Your Identity',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'To create a new account, please confirm your password:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String password = passwordController.text.trim();
                if (password.isEmpty) {
                  _showMessage("Please enter your password.");
                  return;
                }

                // Close the password dialog first
                Navigator.of(dialogContext).pop();

                // Show loading indicator with a separate context
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (loadingContext) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  // Verify the owner's password by attempting to re-authenticate
                  User? currentUser = _authService.currentUser;
                  if (currentUser == null) {
                    // Close loading dialog using a different approach
                    Navigator.of(context, rootNavigator: true).pop();
                    _showMessage("Owner session expired. Please log in again.");
                    return;
                  }

                  // Create a credential to verify the password
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: ownerEmail,
                    password: password,
                  );

                  // Re-authenticate to verify password
                  await currentUser.reauthenticateWithCredential(credential);

                  // Close loading dialog using rootNavigator to avoid context issues
                  Navigator.of(context, rootNavigator: true).pop();

                  // Check if widget is still mounted
                  if (!mounted) return;

                  // Prepare navigation arguments
                  Map<String, dynamic> navigationArgs;

                  if (widget.accountType == 'Admin') {
                    DocumentSnapshot? userData =
                        await _authService.getUserData(currentUser.uid);
                    if (userData != null && userData.exists) {
                      Map<String, dynamic> data =
                          userData.data() as Map<String, dynamic>;

                      navigationArgs = {
                        'accountType': widget.accountType,
                        'name': name,
                        'age': age,
                        'address': address,
                        'mobile': mobile,
                        'birthday': birthday,
                        'createdBy': data['createdBy'],
                        'ownerEmail': ownerEmail,
                        'ownerPassword': password,
                      };
                    } else {
                      // Fallback if userData is not available
                      navigationArgs = {
                        'accountType': widget.accountType,
                        'name': name,
                        'age': age,
                        'address': address,
                        'mobile': mobile,
                        'birthday': birthday,
                        'createdBy': ownerId,
                        'ownerEmail': ownerEmail,
                        'ownerPassword': password,
                      };
                    }
                  } else {
                    navigationArgs = {
                      'accountType': widget.accountType,
                      'name': name,
                      'age': age,
                      'address': address,
                      'mobile': mobile,
                      'birthday': birthday,
                      'createdBy': ownerId,
                      'ownerEmail': ownerEmail,
                      'ownerPassword': password,
                    };
                  }

                  // Check if widget is still mounted before navigating
                  if (!mounted) return;

                  // Navigate to step 2 with data
                  Navigator.pushNamed(
                    context,
                    '/admin_staff_registration_step2',
                    arguments: navigationArgs,
                  );
                } on FirebaseAuthException catch (e) {
                  // Close loading dialog using rootNavigator to avoid context issues
                  try {
                    Navigator.of(context, rootNavigator: true).pop();
                  } catch (e) {
                    // Dialog might already be closed, ignore
                  }

                  String errorMessage = 'Authentication failed';
                  switch (e.code) {
                    case 'invalid-credential':
                    case 'wrong-password':
                      errorMessage =
                          'Invalid password. Please check your password and try again.';
                      break;
                    case 'user-mismatch':
                      errorMessage = 'Session mismatch. Please log in again.';
                      break;
                    case 'user-not-found':
                      errorMessage =
                          'Owner account not found. Please log in again.';
                      break;
                    default:
                      errorMessage = 'Authentication failed: ${e.message}';
                  }

                  // Check if widget is still mounted before showing message
                  if (mounted) {
                    _showMessage(errorMessage);
                  }
                } catch (e) {
                  // Close loading dialog using rootNavigator to avoid context issues
                  try {
                    Navigator.of(context, rootNavigator: true).pop();
                  } catch (e) {
                    // Dialog might already be closed, ignore
                  }

                  // Check if widget is still mounted before showing message
                  if (mounted) {
                    _showMessage(
                        "An unexpected error occurred. Please try again.");
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  OutlineInputBorder customBorder({
    double radius = 20.0,
    Color color = Colors.black,
    double width = 1.0,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Title
                const Text(
                  "Registration",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // Instruction
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Fill out the Personal Information:",
                    style: TextStyle(fontSize: 14),
                  ),
                ),

                const SizedBox(height: 25),

                // Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: customBorder(),
                    focusedBorder: customBorder(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                    enabledBorder: customBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Age
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter your Age",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: customBorder(),
                    focusedBorder: customBorder(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                    enabledBorder: customBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Address
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: "Enter your address",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: customBorder(),
                    focusedBorder: customBorder(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                    enabledBorder: customBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Mobile Number
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Enter your Mobile Number",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: customBorder(),
                    focusedBorder: customBorder(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                    enabledBorder: customBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Birthday
                TextField(
                  controller: birthdayController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      birthdayController.text =
                          "${picked.month}/${picked.day}/${picked.year}";
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Birthday",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: customBorder(),
                    focusedBorder: customBorder(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                    enabledBorder: customBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDDDDDD),
                        foregroundColor: Colors.black,
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
                        "CANCEL",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Next Button
                    ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "NEXT",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
