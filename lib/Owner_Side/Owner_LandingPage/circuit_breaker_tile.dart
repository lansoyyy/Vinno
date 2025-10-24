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

  CircuitBreakerTile({
    super.key,
    required this.bracketName,
    required this.turnOn,
    required this.onChanged,
    required this.isEditMode,
    required this.isSelected,
    required this.onCheckboxChanged,
    this.cbData, // Optional CB data
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //Checkbox
                    if (isEditMode)
                      Checkbox(value: isSelected, onChanged: onCheckboxChanged),
                    if (isEditMode) SizedBox(width: 10),

                    Column(
                      children: [
                        //Task Name
                        Text(bracketName, style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
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
