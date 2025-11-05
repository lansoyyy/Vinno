import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;
  String? _userId;
  String _userName = '';
  String _accountType = 'Owner';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    User? currentUser = _authService.currentUser;
    if (currentUser != null) {
      _userId = currentUser.uid;
      DocumentSnapshot? userData =
          await _authService.getUserData(currentUser.uid);

      if (userData != null && userData.exists) {
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;

        setState(() {
          emailController.text = data['email'] ?? '';
          nameController.text = data['name'] ?? '';
          ageController.text = data['age'] ?? '';
          birthdayController.text = data['birthday'] ?? '';
          contactController.text = data['mobile'] ?? '';
          _userName = data['name'] ?? '';
          _accountType = data['accountType'] ?? 'Owner';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    ageController.dispose();
    birthdayController.dispose();
    contactController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    // Validate fields (excluding email)
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        birthdayController.text.isEmpty ||
        contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Validate age
    if (int.tryParse(ageController.text) == null ||
        int.parse(ageController.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update user data in Firestore (excluding email)
      await FirebaseFirestore.instance
          .collection('owners')
          .doc(_userId)
          .update({
        'name': nameController.text.trim(),
        'age': ageController.text.trim(),
        'birthday': birthdayController.text.trim(),
        'mobile': contactController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _userName = nameController.text.trim();
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    }
  }

  void _showTermsAndConditionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Terms & Conditions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: const Text(
                "By using our smart circuit breaker application, you agree to abide by these Terms and Conditions. This agreement grants you a limited, non-exclusive license to use the app for managing your smart circuit breaker device(s). You are responsible for securing your login credentials and adhering to all usage guidelines. Unauthorized use, including any attempts to interfere with the app's operation or security, is prohibited.\n\nThe application may require updates from time to time to maintain functionality or improve security. By using the app, you agree to allow these automatic updates as necessary. We aim to provide reliable service but are not liable for any direct or indirect damages arising from the use or inability to use the application, including data loss, unauthorized access, or device malfunctions.\n\nWe reserve the right to terminate or restrict access to the app if these Terms are violated. These Terms and Conditions are governed by the laws of Philippines, and any disputes will be resolved under local jurisdiction. If you have questions regarding the Privacy Policy or Terms and Conditions, please contact us at SmartCB@gmail.com.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF2ECC71)),
              ),
            ),
          ],
        );
      },
    );
  }

  OutlineInputBorder customBorder({
    double radius = 16.0,
    Color color = Colors.grey,
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
      body: Column(
        children: [
          // Header with curved design
          Stack(
            children: [
              ClipPath(
                clipper: CustomClipPath(),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2ECC71), Color(0xFF1EA557)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  height: 140,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : TextButton(
                              onPressed: _saveProfile,
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Profile Picture
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8E5C2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF2DCC70),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Name and Role
                    _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2ECC71)),
                            ),
                          )
                        : Text(
                            _userName.isNotEmpty
                                ? _userName.split(' ').first
                                : 'User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    Text(
                      _accountType,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Email Address
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 5, bottom: 5),
                          child: Text(
                            'Email address',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: customBorder(color: Colors.grey),
                            focusedBorder: customBorder(
                              color: Colors.grey,
                              width: 2,
                            ),
                            enabledBorder: customBorder(color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Name and Age Row
                    Row(
                      children: [
                        // Name
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 5, bottom: 5),
                                child: Text(
                                  'Name',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: customBorder(),
                                  focusedBorder: customBorder(
                                    color: const Color(0xFF2ECC71),
                                    width: 2,
                                  ),
                                  enabledBorder: customBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Age
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 5, bottom: 5),
                                child: Text(
                                  'Age',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              TextField(
                                controller: ageController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: customBorder(),
                                  focusedBorder: customBorder(
                                    color: const Color(0xFF2ECC71),
                                    width: 2,
                                  ),
                                  enabledBorder: customBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Birthday and Contact Number Row
                    Row(
                      children: [
                        // Birthday
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 5, bottom: 5),
                                child: Text(
                                  'Birthday',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              TextField(
                                controller: birthdayController,
                                readOnly: true,
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2004, 7, 19),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    birthdayController.text =
                                        "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
                                  }
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: customBorder(),
                                  focusedBorder: customBorder(
                                    color: const Color(0xFF2ECC71),
                                    width: 2,
                                  ),
                                  enabledBorder: customBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Contact Number
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 5, bottom: 5),
                                child: Text(
                                  'Contact Number',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              TextField(
                                controller: contactController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: customBorder(),
                                  focusedBorder: customBorder(
                                    color: const Color(0xFF2ECC71),
                                    width: 2,
                                  ),
                                  enabledBorder: customBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Logo
                    Image.asset(
                      'images/Vinno-logotxt.png',
                      width: 120,
                    ),

                    const SizedBox(height: 10),

                    // Terms and Conditions
                    GestureDetector(
                      onTap: _showTermsAndConditionsDialog,
                      child: const Text(
                        'Terms and Conditions',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    final path = Path();

    path.lineTo(0, h - 50);
    path.quadraticBezierTo(
      w * 0.5,
      h,
      w,
      h - 50,
    );
    path.lineTo(w, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
