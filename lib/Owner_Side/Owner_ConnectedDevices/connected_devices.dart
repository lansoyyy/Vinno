// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ConnectedDevices/admin_list.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ConnectedDevices/dialog_boxes.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ConnectedDevices/staff_list.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';
import 'package:smart_cb_1/util/const.dart';

class ConnectedDevices extends StatefulWidget {
  const ConnectedDevices({super.key});

  @override
  State<ConnectedDevices> createState() => _ConnectedDevicesState();
}

class _ConnectedDevicesState extends State<ConnectedDevices> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = true;

  // Owner data
  Map<String, dynamic>? ownerData;

  // Admin and Staff lists
  List<Map<String, dynamic>> adminList = [];
  List<Map<String, dynamic>> staffList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String adminId = '';
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user (owner)
      User? currentUser = _authService.currentUser;

      if (box.read('accountType') == 'Admin' ||
          box.read('accountType') == 'Staff') {
        DocumentSnapshot? userData =
            await FirebaseAuthService().getUserData(currentUser!.uid);
        if (currentUser != null) {
          adminId = currentUser!.uid;

          // Get the ultimate owner ID - for Staff created by Admin, we need to trace back to the Owner
          String ultimateOwnerId = userData!['createdBy'];
          if (userData['accountType'] == 'Staff' ||
              userData['accountType'] == 'Admin') {
            // For Staff or Admin users, get the creator's data to find the ultimate owner
            DocumentSnapshot? creatorData =
                await _authService.getUserData(userData['createdBy']);
            if (creatorData != null && creatorData.exists) {
              Map<String, dynamic> creatorInfo =
                  creatorData.data() as Map<String, dynamic>;

              // If the creator is an Admin, get their creator (the Owner)
              if (creatorInfo['accountType'] == 'Admin') {
                ultimateOwnerId = creatorInfo['createdBy'];
              }
              // If the creator is already the Owner, use their ID
              else if (creatorInfo['accountType'] == 'Owner') {
                ultimateOwnerId = creatorInfo['uid'];
              }
            }
          }

          // Get owner data
          DocumentSnapshot? ownerDoc =
              await _authService.getUserData(ultimateOwnerId);
          if (ownerDoc != null && ownerDoc.exists) {
            ownerData = ownerDoc.data() as Map<String, dynamic>;
          }

          // Get only active admins created by the same owner
          QuerySnapshot adminSnapshot =
              await _authService.getAdmins(ultimateOwnerId);
          adminList = adminSnapshot.docs
              .map((doc) =>
                  {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .where((admin) => admin['isActive'] == true)
              .toList();

          // Get only active staff created by the same owner
          QuerySnapshot staffSnapshot =
              await _authService.getStaff(ultimateOwnerId);
          staffList = staffSnapshot.docs
              .map((doc) =>
                  {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .where((staff) => staff['isActive'] == true)
              .toList();
        }
      } else {
        if (currentUser != null) {
          // Get owner data
          DocumentSnapshot? ownerDoc =
              await _authService.getUserData(currentUser.uid);
          if (ownerDoc != null && ownerDoc.exists) {
            ownerData = ownerDoc.data() as Map<String, dynamic>;
          }

          // Get only active admins created by this owner
          QuerySnapshot adminSnapshot =
              await _authService.getAdmins(currentUser.uid);
          adminList = adminSnapshot.docs
              .map((doc) =>
                  {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .where((admin) => admin['isActive'] == true)
              .toList();

          // Get only active staff created by this owner
          QuerySnapshot staffSnapshot =
              await _authService.getStaff(currentUser.uid);
          staffList = staffSnapshot.docs
              .map((doc) =>
                  {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .where((staff) => staff['isActive'] == true)
              .toList();
        }
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/cblist');
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black, size: 30),
                  onPressed: () => showNavigateDialog(context),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Blocklists') {
                      showBlockListDialog(context);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'Blocklists',
                      child: Text('Blocklists'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 210),

                    // 🧍 OWNER SECTION ------------------------------------------------
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      child: Container(
                        width: double.infinity,
                        child: const Text(
                          'Owner',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ownerData != null
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 30,
                                  right: 30,
                                  bottom: 8,
                                ),
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.person, size: 40),
                                            const SizedBox(width: 14),
                                            // Owner Name
                                            Text(
                                              ownerData!['name'] ?? 'Owner',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F9F9),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        offset: const Offset(0, 4),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),

                    const SizedBox(height: 20),

                    // 🧑‍💼 ADMIN SECTION ---------------------------------------------
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      child: Container(
                        width: double.infinity,
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: adminList.length,
                            itemBuilder: (context, index) {
                              return AdminLists(
                                adminData: adminList[index],
                                onToggleStatus: () => _toggleAdminStatus(index),
                              );
                            },
                          ),

                    const SizedBox(height: 20),

                    // 👷 STAFF SECTION -----------------------------------------------
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      child: Container(
                        width: double.infinity,
                        child: const Text(
                          'Staffs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: staffList.length,
                            itemBuilder: (context, index) {
                              return StaffList(
                                staffData: staffList[index],
                                onToggleStatus: () => _toggleStaffStatus(index),
                              );
                            },
                          ),

                    SizedBox(height: 60),
                  ],
                ),
              ),

              // HEADER SECTION
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                color: Color(0xFFFFFFFF),
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    const Text(
                      'Welcome,',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : Text(
                            ownerData?['name']?.split(' ').first ?? 'Owner',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                    const Text(
                      'Manage user access levels below',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleAdminStatus(int index) async {
    if (adminList.isEmpty) return;

    Map<String, dynamic> admin = adminList[index];

    // Show confirmation dialog before blocking
    bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Block Admin'),
            content: Text('Are you sure you want to block ${admin['name']}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Block', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    // Block the admin (set isActive to false)
    String? error = await _authService.toggleUserStatus(
      admin['id'],
      'Admin',
      false, // Always blocking (setting to inactive)
    );

    if (error == null) {
      // Remove from the active list since they are now blocked
      setState(() {
        adminList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin has been blocked and moved to Blocklist'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _toggleStaffStatus(int index) async {
    if (staffList.isEmpty) return;

    Map<String, dynamic> staff = staffList[index];

    // Show confirmation dialog before blocking
    bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Block Staff'),
            content: Text('Are you sure you want to block ${staff['name']}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Block', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    // Block the staff (set isActive to false)
    String? error = await _authService.toggleUserStatus(
      staff['id'],
      'Staff',
      false, // Always blocking (setting to inactive)
    );

    if (error == null) {
      // Remove from the active list since they are now blocked
      setState(() {
        staffList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff has been blocked and moved to Blocklist'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
}
