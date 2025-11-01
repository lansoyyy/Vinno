import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_cb_1/util/const.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register owner with email and password
  Future<String?> registerOwner({
    required String email,
    required String password,
    required String name,
    required String age,
    required String address,
    required String mobile,
    required String birthday,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user ID
      String uid = userCredential.user!.uid;

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Store additional user data in Firestore
      await _firestore.collection('owners').doc(uid).set({
        'uid': uid,
        'name': name,
        'age': age,
        'address': address,
        'mobile': mobile,
        'birthday': birthday,
        'email': email,
        'accountType': 'Owner',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'latitude': 0,
        'longitude': 0,
        'emailVerified': false, // Track email verification status
      });

      return null; // Success, return null for no error
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.message}');
      }
      return _getErrorMessage(e.code);
    } catch (e) {
      if (kDebugMode) {
        print('Error registering owner: $e');
      }
      return 'An unknown error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        // await _auth.signOut(); // Sign out the user
        return 'Please verify your email before signing in. Check your inbox for the verification email.';
      }

      box.write('loggedIn', true);

      return null; // Success, return null for no error
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.message}');
      }
      return _getErrorMessage(e.code);
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in: $e');
      }
      return 'An unknown error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }

  // Reset password
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success, return null for no error
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.message}');
      }
      return _getErrorMessage(e.code);
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting password: $e');
      }
      return 'An unknown error occurred. Please try again.';
    }
  }

  // Register admin or staff with email and password
  Future<String?> registerAdminOrStaff({
    required String email,
    required String password,
    required String name,
    required String age,
    required String address,
    required String mobile,
    required String birthday,
    required String accountType, // 'Admin' or 'Staff'
    required String ownerId, // Owner who is creating this account
    required String ownerEmail, // Owner's email for re-authentication
    required String ownerPassword, // Owner's password for re-authentication
  }) async {
    try {
      // Get current user (owner) to verify authentication
      User? owner = _auth.currentUser;
      if (owner == null) {
        return 'Owner not authenticated. Please log in again.';
      }

      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the new user ID
      String uid = userCredential.user!.uid;

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Determine collection based on account type
      String collection =
          accountType.toLowerCase() == 'admin' ? 'admins' : 'staff';

      // Store additional user data in Firestore
      await _firestore.collection(collection).doc(uid).set({
        'uid': uid,
        'name': name,
        'age': age,
        'address': address,
        'mobile': mobile,
        'birthday': birthday,
        'email': email,
        'accountType': accountType,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'createdBy': ownerId, // Owner who created this account
        'latitude': 0,
        'longitude': 0,
        'emailVerified': false, // Track email verification status
      });

      // Sign out the newly created user
      await _auth.signOut();

      // Sign back in as the owner
      await _auth.signInWithEmailAndPassword(
        email: ownerEmail,
        password: ownerPassword,
      );

      return null; // Success, return null for no error
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.message}');
      }
      return _getErrorMessage(e.code);
    } catch (e) {
      if (kDebugMode) {
        print('Error registering $accountType: $e');
      }
      return 'An unknown error occurred. Please try again.';
    }
  }

  // Check email verification status and update Firestore
  Future<String?> checkEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return 'No user is currently signed in.';
      }

      // Reload user to get latest email verification status
      await user.reload();
      user = _auth.currentUser;

      if (user!.emailVerified) {
        // Update email verification status in Firestore
        String uid = user.uid;

        // Check in owners collection first
        DocumentSnapshot doc =
            await _firestore.collection('owners').doc(uid).get();
        if (doc.exists) {
          await _firestore.collection('owners').doc(uid).update({
            'emailVerified': true,
            'emailVerifiedAt': FieldValue.serverTimestamp(),
          });
          return null;
        }

        // Check in admins collection
        doc = await _firestore.collection('admins').doc(uid).get();
        if (doc.exists) {
          await _firestore.collection('admins').doc(uid).update({
            'emailVerified': true,
            'emailVerifiedAt': FieldValue.serverTimestamp(),
          });
          return null;
        }

        // Check in staff collection
        doc = await _firestore.collection('staff').doc(uid).get();
        if (doc.exists) {
          await _firestore.collection('staff').doc(uid).update({
            'emailVerified': true,
            'emailVerifiedAt': FieldValue.serverTimestamp(),
          });
          return null;
        }

        return 'User document not found in Firestore.';
      } else {
        return 'Email not verified yet.';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking email verification: $e');
      }
      return 'Failed to check email verification status.';
    }
  }

  // Resend email verification
  Future<String?> resendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return 'No user is currently signed in.';
      }

      if (user.emailVerified) {
        return 'Email is already verified.';
      }

      await user.sendEmailVerification();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.message}');
      }
      return _getErrorMessage(e.code);
    } catch (e) {
      if (kDebugMode) {
        print('Error resending verification email: $e');
      }
      return 'Failed to resend verification email. Please try again.';
    }
  }

  // Block/unblock a user
  Future<String?> toggleUserStatus(
      String uid, String accountType, bool isActive) async {
    try {
      String collection =
          accountType.toLowerCase() == 'admin' ? 'admins' : 'staff';

      await _firestore.collection(collection).doc(uid).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user status: $e');
      }
      return 'Failed to update user status. Please try again.';
    }
  }

  // Get all admins for an owner
  Future<QuerySnapshot> getAdmins(String ownerId) async {
    try {
      return await _firestore
          .collection('admins')
          .where('createdBy', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting admins: $e');
      }
      rethrow;
    }
  }

  // Get all staff for an owner
  Future<QuerySnapshot> getStaff(String ownerId) async {
    try {
      return await _firestore
          .collection('staff')
          .where('createdBy', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting staff: $e');
      }
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<DocumentSnapshot?> getUserData(String uid) async {
    try {
      // Check in owners collection first
      DocumentSnapshot doc =
          await _firestore.collection('owners').doc(uid).get();
      if (doc.exists) {
        return doc;
      }

      // Check in admins collection
      doc = await _firestore.collection('admins').doc(uid).get();
      if (doc.exists) {
        return doc;
      }

      // Check in staff collection
      doc = await _firestore.collection('staff').doc(uid).get();
      if (doc.exists) {
        return doc;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      return null;
    }
  }

  // Convert Firebase Auth error codes to user-friendly messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An authentication error occurred: $errorCode';
    }
  }
}
