import 'package:flutter/material.dart';

class AdminStaffRegistrationStep1 extends StatefulWidget {
  final String accountType; // 'Admin' or 'Staff'

  const AdminStaffRegistrationStep1({
    super.key,
    required this.accountType,
  });

  @override
  State<AdminStaffRegistrationStep1> createState() =>
      _AdminStaffRegistrationStep1State();
}

class _AdminStaffRegistrationStep1State
    extends State<AdminStaffRegistrationStep1> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    addressController.dispose();
    mobileController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  void _onNext() {
    String name = nameController.text.trim();
    String age = ageController.text.trim();
    String address = addressController.text.trim();
    String mobile = mobileController.text.trim();
    String birthday = birthdayController.text.trim();

    if (name.isEmpty ||
        age.isEmpty ||
        address.isEmpty ||
        mobile.isEmpty ||
        birthday.isEmpty) {
      _showMessage("Please fill out all fields.");
      return;
    }

    if (int.tryParse(age) == null || int.parse(age) <= 0) {
      _showMessage("Please enter a valid age.");
      return;
    }

    // Navigate to step 2 with data
    Navigator.pushNamed(
      context,
      '/admin_staff_registration_step2',
      arguments: {
        'accountType': widget.accountType,
        'name': name,
        'age': age,
        'address': address,
        'mobile': mobile,
        'birthday': birthday,
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                    "Fill out the Personal Information:",
                    style: TextStyle(fontSize: 14),
                  ),
                ),

                const SizedBox(height: 25),

                // Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Enter your name",
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

                // Age
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter your Age",
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

                // Address
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: "Enter your address",
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

                // Mobile Number
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Enter your Mobile Number",
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

                // Birthday
                TextField(
                  controller: birthdayController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      birthdayController.text =
                          "${picked.month}/${picked.day}/${picked.year}";
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Birthday",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                      size: 20,
                    ),
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

                const SizedBox(height: 80),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDDDDDD),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Next Button
                    ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "NEXT",
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
