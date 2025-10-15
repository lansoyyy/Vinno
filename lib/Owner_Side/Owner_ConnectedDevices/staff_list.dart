// ignore_for_file: sort_child_properties_last, must_be_immutable

import 'package:flutter/material.dart';

class StaffList extends StatelessWidget {
  final Map<String, dynamic> staffData;
  final VoidCallback onToggleStatus;

  const StaffList({
    super.key,
    required this.staffData,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    bool isActive = staffData['isActive'] ?? true;
    String staffName = staffData['name'] ?? 'Unknown Staff';

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
                      color: isActive ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 14),
                    // Staff Name
                    Text(
                      staffName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Block/Unblock button
                GestureDetector(
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
