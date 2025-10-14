import 'package:flutter/material.dart';

class OwnerRegistrationStep1 extends StatefulWidget {
  const OwnerRegistrationStep1({super.key});

  @override
  State<OwnerRegistrationStep1> createState() => _OwnerRegistrationStep1State();
}

class _OwnerRegistrationStep1State extends State<OwnerRegistrationStep1> {
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
      '/owner_registration_step2',
      arguments: {
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
    double radius = 16.0,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Registration",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Form
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Fill out the Personal Information:",
                      style: TextStyle(fontSize: 14),
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
                        border: customBorder(color: Colors.black),
                        focusedBorder: customBorder(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        enabledBorder: customBorder(color: Colors.black),
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
                        border: customBorder(color: Colors.black),
                        focusedBorder: customBorder(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        enabledBorder: customBorder(color: Colors.black),
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
                        border: customBorder(color: Colors.black),
                        focusedBorder: customBorder(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        enabledBorder: customBorder(color: Colors.black),
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
                        border: customBorder(color: Colors.black),
                        focusedBorder: customBorder(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        enabledBorder: customBorder(color: Colors.black),
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
                        border: customBorder(color: Colors.black),
                        focusedBorder: customBorder(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        enabledBorder: customBorder(color: Colors.black),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Next Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 80,
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
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
