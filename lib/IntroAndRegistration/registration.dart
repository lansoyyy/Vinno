import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  // The currently selected value
  String? selectedValue;

  // Options for the dropdown
  final List<String> items = ['Owner', 'Admin', 'Staff'];

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailAddressController.dispose();
    addressController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  void _onNext() {
    String name = nameController.text.trim();
    String age = ageController.text.trim();
    String emailAddress = emailAddressController.text.trim();
    String address = addressController.text.trim();
    String birthday = birthdayController.text.trim();

    if (name.isEmpty ||
        age.isEmpty ||
        emailAddress.isEmpty ||
        address.isEmpty ||
        birthday.isEmpty) {
      _showMessage("Please fill out all fields.");
      return;
    }

    if (int.tryParse(age) == null || int.parse(age) <= 0) {
      _showMessage("Please enter a valid age.");
      return;
    }

    _showMessage("Registration successful!");
    Navigator.pushNamed(context, '/new_pin');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // A helper function to build custom input borders
  OutlineInputBorder customBorder({
    double radius = 16.0,
    Color color = Colors.black,
    double width = 1.0,
    bool isFocused = false,
    bool noBorder = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: noBorder
          ? BorderSide.none
          : BorderSide(color: color, width: isFocused ? width : 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/accountactivity');
                      },
                    ),

                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Registration",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Fill out the Personal Information:"),
                    ),

                    SizedBox(height: 30),

                    // Name
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Enter your name",
                        border: customBorder(noBorder: true), // removes border
                        focusedBorder: customBorder(
                          isFocused: true,
                          color: Colors.grey,
                          width: 2,
                        ),
                        enabledBorder: customBorder(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Age
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Enter your Age",
                        border: customBorder(noBorder: true), // removes border
                        focusedBorder: customBorder(
                          isFocused: true,
                          color: Colors.grey,
                          width: 2,
                        ),
                        enabledBorder: customBorder(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Email Address
                    TextField(
                      controller: emailAddressController,
                      decoration: InputDecoration(
                        labelText: "Enter your Email Address",
                        border: customBorder(noBorder: true), // removes border
                        focusedBorder: customBorder(
                          isFocused: true,
                          color: Colors.grey,
                          width: 2,
                        ),
                        enabledBorder: customBorder(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Address
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: "Enter your Address",
                        border: customBorder(noBorder: true), // removes border
                        focusedBorder: customBorder(
                          isFocused: true,
                          color: Colors.grey,
                          width: 2,
                        ),
                        enabledBorder: customBorder(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 20),

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
                        labelText: "Birthday",
                        prefixIcon: Icon(Icons.calendar_today),
                        border: customBorder(noBorder: true), // removes border
                        focusedBorder: customBorder(
                          isFocused: true,
                          color: Colors.grey,
                          width: 2,
                        ),
                        enabledBorder: customBorder(color: Colors.grey),
                      ),
                    ),

                    SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: selectedValue,

                      items: items.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText:
                            "Select an option", // 👈 styled like your TextField
                        border: customBorder(noBorder: true),
                        focusedBorder: customBorder(
                          isFocused: true,
                          color: Colors.grey,
                          width: 2,
                        ),
                        enabledBorder: customBorder(color: Colors.grey),
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor: Colors.white,
                    ),

                    SizedBox(height: 200),

                    Center(
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade300,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text("NEXT", style: TextStyle(fontSize: 18)),
                      ),
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
}
