import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';
import 'package:smart_cb_1/util/const.dart';

// For Adding Accounts
void showNavigateDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
        child: const Text('Add Account', style: TextStyle(fontSize: 30)),
      ),
      content: const Text(
        'For:',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
      actions: [
        Center(
          child: Column(
            children: [
              // Admin
              Visibility(
                visible: box.read('accountType') != 'Admin',
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: Offset(0, 4), // x, y offset
                        blurRadius: 2,
                        spreadRadius: 0,
                      ),
                    ],
                    borderRadius:
                        BorderRadius.circular(12), // Match button shape
                  ),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.zero,
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Colors.black,
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.white,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    child: Text(
                      'Admin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog first
                      Navigator.pushNamed(
                        context,
                        '/admin_staff_registration_step1',
                        arguments: {'accountType': 'Admin'},
                      );
                    },
                  ),
                ),
              ),

              Visibility(
                visible: box.read('accountType') != 'Admin',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text('or', style: TextStyle(fontSize: 18)),
                ),
              ),

              // Staff
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: Offset(0, 4), // x, y offset
                      blurRadius: 2,
                      spreadRadius: 0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12), // Match button shape
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.zero,
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.black,
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  child: Text(
                    'Staff',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog first
                    Navigator.pushNamed(
                      context,
                      '/admin_staff_registration_step1',
                      arguments: {'accountType': 'Staff'},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// For BlockLists
void showBlockListDialog(BuildContext context) {
  final FirebaseAuthService _authService = FirebaseAuthService();

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 400,
          width: 300,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Text(
                    'Blocklists',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),

                // Tab Bar
                const TabBar(
                  tabs: [
                    Tab(text: 'Admins'),
                    Tab(text: 'Staffs'),
                  ],
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    children: [
                      // Blocked Admins List
                      FutureBuilder<QuerySnapshot>(
                        future: _getBlockedUsers('admins'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text('No blocked admins'));
                          }

                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot doc = snapshot.data!.docs[index];
                              Map<String, dynamic> data =
                                  doc.data() as Map<String, dynamic>;
                              String name = data['name'] ?? 'Unknown Admin';
                              String uid = doc.id;

                              return ListTile(
                                title: Text(name),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.settings_backup_restore,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    // Show confirmation dialog before unblocking
                                    bool confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Unblock Admin'),
                                            content: const Text(
                                                'Are you sure you want to unblock this admin?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text('Unblock',
                                                    style: TextStyle(
                                                        color: Colors.green)),
                                              ),
                                            ],
                                          ),
                                        ) ??
                                        false;

                                    if (!confirm) return;

                                    // Handle unblock action
                                    String? error =
                                        await _authService.toggleUserStatus(
                                      uid,
                                      'Admin',
                                      true, // Set to active (unblock)
                                    );

                                    if (error != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Error: $error')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Admin unblocked successfully')),
                                      );
                                      Navigator.pop(context); // Close dialog
                                      // Refresh the connected devices screen
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/connectedDevices',
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // Blocked Staffs List
                      FutureBuilder<QuerySnapshot>(
                        future: _getBlockedUsers('staff'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text('No blocked staff'));
                          }

                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot doc = snapshot.data!.docs[index];
                              Map<String, dynamic> data =
                                  doc.data() as Map<String, dynamic>;
                              String name = data['name'] ?? 'Unknown Staff';
                              String uid = doc.id;

                              return ListTile(
                                title: Text(name),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.settings_backup_restore,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    // Show confirmation dialog before unblocking
                                    bool confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Unblock Staff'),
                                            content: const Text(
                                                'Are you sure you want to unblock this staff?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text('Unblock',
                                                    style: TextStyle(
                                                        color: Colors.green)),
                                              ),
                                            ],
                                          ),
                                        ) ??
                                        false;

                                    if (!confirm) return;

                                    // Handle unblock action
                                    String? error =
                                        await _authService.toggleUserStatus(
                                      uid,
                                      'Staff',
                                      true, // Set to active (unblock)
                                    );

                                    if (error != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Error: $error')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Staff unblocked successfully')),
                                      );
                                      Navigator.pop(context); // Close dialog
                                      // Refresh the connected devices screen
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/connectedDevices',
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Close button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Helper function to get blocked users
Future<QuerySnapshot> _getBlockedUsers(String collection) async {
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? currentUser = _authService.currentUser;

  if (currentUser == null) {
    throw Exception('User not authenticated');
  }

  return FirebaseFirestore.instance
      .collection(collection)
      // .where('createdBy', isEqualTo: currentUser.uid)
      .where('isActive', isEqualTo: false)
      .get();
}
