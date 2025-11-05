import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isOldPasswordValid = false;
  bool _isCheckingPassword = false;

  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyOldPassword(String password) async {
    if (password.isEmpty) {
      setState(() {
        _isOldPasswordValid = false;
      });
      return;
    }

    setState(() {
      _isCheckingPassword = true;
    });

    try {
      User? user = _authService.currentUser;
      if (user != null && user.email != null) {
        // Create credential to verify old password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        // Try to reauthenticate with the provided password
        await user.reauthenticateWithCredential(credential);

        setState(() {
          _isOldPasswordValid = true;
        });
      } else {
        setState(() {
          _isOldPasswordValid = false;
        });
      }
    } catch (e) {
      setState(() {
        _isOldPasswordValid = false;
      });
    } finally {
      setState(() {
        _isCheckingPassword = false;
      });
    }
  }

  void _changePassword() async {
    String oldPassword = oldPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Validation
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (newPassword.length < 6) {
      _showMessage('New password must be at least 6 characters');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('New passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _authService.currentUser;
      if (user != null && user.email != null) {
        // Reauthenticate user with old password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );

        await user.reauthenticateWithCredential(credential);

        // Update the password
        await user.updatePassword(newPassword);

        setState(() {
          _isLoading = false;
        });

        _showMessage('Password changed successfully');
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
        });
        _showMessage('User not found. Please log in again.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'An error occurred';
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Current password is incorrect';
          break;
        case 'weak-password':
          errorMessage = 'New password is too weak';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please log in again to change your password';
          break;
        case 'user-mismatch':
          errorMessage = 'User credentials mismatch';
          break;
        case 'user-not-found':
          errorMessage = 'User not found';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid credentials';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }

      _showMessage(errorMessage);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error: ${e.toString()}');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                            'Change Password',
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
                              onPressed: _changePassword,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    // Title and Description
                    const Text(
                      'RESET your Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter and confirm your new Password to regain access',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Old PIN
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 5, bottom: 5),
                          child: Text(
                            'Old Password',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        TextField(
                          controller: oldPasswordController,
                          obscureText: _obscureOldPassword,
                          onChanged: (value) {
                            // Debounce password verification
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              if (oldPasswordController.text == value) {
                                _verifyOldPassword(value);
                              }
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Password validation indicator
                                if (_isCheckingPassword)
                                  const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFF2ECC71),
                                        ),
                                      ),
                                    ),
                                  )
                                else if (oldPasswordController.text.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Icon(
                                      _isOldPasswordValid
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: _isOldPasswordValid
                                          ? Colors.green
                                          : Colors.red,
                                      size: 20,
                                    ),
                                  )
                                else
                                  const SizedBox(width: 40),
                                // Clear button
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  onPressed: () {
                                    oldPasswordController.clear();
                                    setState(() {
                                      _isOldPasswordValid = false;
                                    });
                                  },
                                ),
                                // Visibility toggle
                                IconButton(
                                  icon: Icon(
                                    _obscureOldPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureOldPassword =
                                          !_obscureOldPassword;
                                    });
                                  },
                                ),
                              ],
                            ),
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

                    const SizedBox(height: 20),

                    // New PIN
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 5, bottom: 5),
                          child: Text(
                            'New Password',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        TextField(
                          controller: newPasswordController,
                          obscureText: _obscureNewPassword,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
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

                    const SizedBox(height: 20),

                    // Confirm new PIN
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 5, bottom: 5),
                          child: Text(
                            'Confirm new Password',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
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
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
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

                    const SizedBox(height: 100),

                    // Logo
                    Center(
                      child: Image.asset(
                        'images/Vinno-logotxt.png',
                        width: 120,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Terms and Conditions
                    Center(
                      child: GestureDetector(
                        onTap: _showTermsAndConditionsDialog,
                        child: const Text(
                          'Terms and Conditions',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
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
