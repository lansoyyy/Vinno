import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';

class AdminStaffRegistrationStep2 extends StatefulWidget {
  const AdminStaffRegistrationStep2({super.key});

  @override
  State<AdminStaffRegistrationStep2> createState() =>
      _AdminStaffRegistrationStep2State();
}

class _AdminStaffRegistrationStep2State
    extends State<AdminStaffRegistrationStep2> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String accountType = '';

  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get arguments passed from previous screen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      accountType = args['accountType'] ?? '';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Please fill out all fields.");
      return;
    }

    // Email validation - must contain a valid email format with a domain
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showMessage(
          "Please enter a valid email address with a domain (e.g., '@gmail.com').");
      return;
    }

    // Password validation - minimum 8 characters with uppercase, lowercase, numbers, and special characters
    if (password.length < 8) {
      _showMessage("Password must be at least 8 characters long.");
      return;
    }

    if (!RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(password)) {
      _showMessage(
          "Password must contain uppercase, lowercase, numbers, and special characters.");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match.");
      return;
    }

    // Get data from previous step
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      _showMessage("Missing registration information. Please start over.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Register with Firebase
    // Get the current owner's ID before creating the new account
    // We'll pass it through the arguments to avoid issues with Firebase automatically signing in as the new user
    String ownerId = args['createdBy'] ?? '';

    if (ownerId.isEmpty) {
      // Try to get current user as fallback
      User? currentUser = _authService.currentUser;
      if (currentUser != null) {
        ownerId = currentUser.uid;
      } else {
        _showMessage("Owner not authenticated. Please log in again.");
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    try {
      // First, validate the owner's credentials before proceeding
      String ownerEmail = args['ownerEmail'] ?? '';
      String ownerPassword = args['ownerPassword'] ?? '';

      if (ownerEmail.isEmpty || ownerPassword.isEmpty) {
        _showMessage("Owner credentials are missing. Please start over.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Re-authenticate the owner to ensure they have valid credentials
      User? currentUser = _authService.currentUser;
      if (currentUser == null) {
        _showMessage("Owner session expired. Please log in again.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create a credential to verify the owner's password
      AuthCredential credential = EmailAuthProvider.credential(
        email: ownerEmail,
        password: ownerPassword,
      );

      // Re-authenticate the owner with their credentials
      await currentUser.reauthenticateWithCredential(credential);

      // If re-authentication is successful, proceed with registration
      String? error = await _authService.registerAdminOrStaff(
        email: email,
        password: password,
        name: args['name'],
        age: args['age'],
        address: args['address'],
        mobile: args['mobile'],
        birthday: args['birthday'],
        accountType: accountType,
        ownerId: ownerId,
        ownerEmail: ownerEmail,
        ownerPassword: ownerPassword,
      );

      setState(() {
        _isLoading = false;
      });

      if (error != null) {
        // Check if widget is still mounted before showing message
        if (mounted) {
          _showMessage(error);
        }
      } else {
        // Check if widget is still mounted before showing dialog
        if (mounted) {
          // Show email verification dialog
          _showEmailVerificationDialog();
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Handle specific Firebase Auth errors
      String errorMessage = 'Registration failed';
      switch (e.code) {
        case 'invalid-credential':
          errorMessage =
              'Invalid owner credentials. Please check your password and try again.';
          break;
        case 'wrong-password':
          errorMessage = 'Invalid owner password. Please verify and try again.';
          break;
        case 'user-mismatch':
          errorMessage = 'Owner session mismatch. Please log in again.';
          break;
        case 'user-not-found':
          errorMessage = 'Owner account not found. Please log in again.';
          break;
        case 'email-already-in-use':
          errorMessage =
              'This email is already registered. Please use a different email.';
          break;
        case 'weak-password':
          errorMessage =
              'Password is too weak. Please choose a stronger password.';
          break;
        case 'invalid-email':
          errorMessage =
              'Invalid email format. Please enter a valid email address.';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }
      _showMessage(errorMessage);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('An unexpected error occurred. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Email Verification Sent",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 60,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(height: 20),
              Text(
                "A verification email has been sent to:\n\n${emailController.text.trim()}\n\nPlease check your inbox and click the verification link to complete your registration.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushNamed(
                  context,
                  '/admin_staff_registration_success',
                  arguments: {'accountType': accountType},
                );
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
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
                    "Make an Account:",
                    style: TextStyle(fontSize: 14),
                  ),
                ),

                const SizedBox(height: 25),

                // Email
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter your Email Address",
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

                // Password
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
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

                // Confirm Password
                TextField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: "Confirm Password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
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

                const SizedBox(height: 120),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Back Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDDDDDD),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 45,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "BACK",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Register Button
                    _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF4CAF50)),
                          )
                        : ElevatedButton(
                            onPressed: _onRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 35,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              "REGISTER",
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
