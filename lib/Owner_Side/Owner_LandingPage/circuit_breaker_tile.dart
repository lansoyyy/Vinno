// ignore_for_file: sort_child_properties_last, must_be_immutable, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_CircuitBreakerOption/bracket_option_page.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Settings/wifi_change_dialog.dart';

class CircuitBreakerTile extends StatefulWidget {
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
  State<CircuitBreakerTile> createState() => _CircuitBreakerTileState();
}

class _CircuitBreakerTileState extends State<CircuitBreakerTile> {
  void _showWifiChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WiFiChangeDialog(
          currentWifiName: widget.wifiController?.text ?? '',
          circuitBreakerId: widget.cbData?['scbId'] ?? '',
          circuitBreakerName: widget.bracketName,
          onWifiChanged: (String wifiName, String password) {
            // Update the WiFi controller with the new network name
            if (widget.wifiController != null) {
              widget.wifiController!.text = wifiName;
            }

            // Call the save WiFi callback if provided
            if (widget.onSaveWifi != null) {
              widget.onSaveWifi!();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
      child: GestureDetector(
        onTap: () {
          if (!widget.isEditMode)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BracketOptionPage(cbData: widget.cbData),
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
                        if (widget.isEditMode)
                          Checkbox(
                              value: widget.isSelected,
                              onChanged: widget.onCheckboxChanged),
                        if (widget.isEditMode) SizedBox(width: 10),

                        // Name field or display
                        widget.isEditMode && widget.nameController != null
                            ? SizedBox(
                                width: 150,
                                height: 50,
                                child: TextField(
                                  controller: widget.nameController,
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
                                child: Text(widget.bracketName,
                                    maxLines: 2,
                                    style: TextStyle(fontSize: 18))),

                        // Save button for name (only in edit mode)
                        if (widget.isEditMode &&
                            widget.nameController != null) ...[
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: widget.onSaveName,
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
                    if (!widget.isEditMode)
                      Switch(
                        value: widget.turnOn,
                        onChanged: widget.onChanged,
                        activeColor: Color.fromARGB(255, 0, 205, 86),
                        inactiveTrackColor: Color(0xFEE9E9E9),
                        thumbColor: MaterialStateProperty.all(
                          widget.turnOn
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFFFFFFFF),
                        ),
                      ),
                  ],
                ),

                // WiFi editing section (only in edit mode)
                if (widget.isEditMode && widget.wifiController != null) ...[
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.wifi, size: 20, color: Colors.grey[600]),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'WiFi: ${widget.wifiController!.text.isEmpty ? "Not set" : widget.wifiController!.text}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showWifiChangeDialog(context);
                        },
                        icon: Icon(Icons.edit, size: 16),
                        label: Text('Change WiFi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2ECC71),
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
