// ignore_for_file: sort_child_properties_last, must_be_immutable

import 'package:flutter/material.dart';
import 'package:smart_cb_1/util/const.dart';

class AdminLists extends StatelessWidget {
  final Map<String, dynamic> adminData;
  final VoidCallback onToggleStatus;

  const AdminLists({
    super.key,
    required this.adminData,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    bool isActive = adminData['isActive'] ?? true;
    String adminName = adminData['name'] ?? 'Unknown Admin';

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 30, right: 30, bottom: 8),
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => BracketOptionPage()),
          // );
        },
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 40,
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 14),
                    // Admin Name
                    Text(
                      adminName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Block/Unblock button
                box.read('accountType') == 'Admin'
                    ? SizedBox()
                    : GestureDetector(
                        onTap: onToggleStatus,
                        child: Icon(
                          isActive ? Icons.block : Icons.check_circle,
                          color: isActive ? Colors.red : Colors.green,
                        ),
                      ),
              ],
            ),
          ),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF9F9F9) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25), // Shadow color
                offset: const Offset(0, 4), // Shadow position
                blurRadius: 4, // Blur effect
                spreadRadius: 0, // Spread effect
              ),
            ],
          ),
        ),
      ),
    );
  }
}
