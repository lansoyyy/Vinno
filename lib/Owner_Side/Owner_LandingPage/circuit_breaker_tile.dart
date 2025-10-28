// ignore_for_file: sort_child_properties_last, must_be_immutable, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_CircuitBreakerOption/bracket_option_page.dart';

class CircuitBreakerTile extends StatelessWidget {
  final String bracketName;
  final bool turnOn;
  Function(bool?)? onChanged;
  final bool isEditMode;
  final bool isSelected;
  final Function(bool?)? onCheckboxChanged;
  final Map<String, dynamic>? cbData; // Added circuit breaker data
  final TextEditingController? nameController; // For editing name
  final TextEditingController? wifiController; // For editing WiFi
  final VoidCallback? onSaveName; // Callback to save name
  final VoidCallback? onSaveWifi; // Callback to save WiFi

  CircuitBreakerTile({
    super.key,
    required this.bracketName,
    required this.turnOn,
    required this.onChanged,
    required this.isEditMode,
    required this.isSelected,
    required this.onCheckboxChanged,
    this.cbData, // Optional CB data
    this.nameController, // Optional name controller
    this.wifiController, // Optional WiFi controller
    this.onSaveName, // Optional save name callback
    this.onSaveWifi, // Optional save WiFi callback
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
      child: GestureDetector(
        onTap: () {
          if (!isEditMode)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BracketOptionPage(cbData: cbData),
              ),
            );
        },
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main row with checkbox, name, and switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        //Checkbox
                        if (isEditMode)
                          Checkbox(
                              value: isSelected, onChanged: onCheckboxChanged),
                        if (isEditMode) SizedBox(width: 10),

                        // Name field or display
                        isEditMode && nameController != null
                            ? SizedBox(
                                width: 150,
                                height: 50,
                                child: TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    hintText: "Circuit Breaker Name",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Color(0xFF2ECC71)),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : SizedBox(
                                width: 225,
                                child: Text(bracketName,
                                    maxLines: 2,
                                    style: TextStyle(fontSize: 18))),

                        // Save button for name (only in edit mode)
                        if (isEditMode && nameController != null) ...[
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: onSaveName,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2ECC71),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Save'),
                          ),
                        ],
                      ],
                    ),

                    // Switch (only in normal mode)
                    if (!isEditMode)
                      Switch(
                        value: turnOn,
                        onChanged: onChanged,
                        activeColor: Color.fromARGB(255, 0, 205, 86),
                        inactiveTrackColor: Color(0xFEE9E9E9),
                        thumbColor: MaterialStateProperty.all(
                          turnOn
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFFFFFFFF),
                        ),
                      ),
                  ],
                ),

                // WiFi editing section (only in edit mode)
                if (isEditMode && wifiController != null) ...[
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.wifi, size: 20, color: Colors.grey[600]),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: wifiController,
                          decoration: InputDecoration(
                            hintText: "WiFi Network Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF2ECC71)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: onSaveWifi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2ECC71),
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Save WiFi'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          decoration: BoxDecoration(
            color: Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25), // Shadow color
                offset: Offset(0, 4), // Shadow position
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
