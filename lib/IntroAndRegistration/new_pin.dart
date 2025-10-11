import 'package:flutter/material.dart';

class NewPin extends StatefulWidget {
  const NewPin({super.key});

  @override
  State<NewPin> createState() => _SetNewPinPageState();
}

class _SetNewPinPageState extends State<NewPin> {
  final TextEditingController pinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();

  ///pin toggle
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  @override
  void dispose() {
    pinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    String pin = pinController.text;
    String confirmPin = confirmPinController.text;

    if (pin.length < 4) {
      _showMessage("PIN must be at least 4 digits");
      return;
    }

    if (pin != confirmPin) {
      _showMessage("PINs do not match");
      return;
    }

    // Success logic here (e.g., save PIN, navigate)
    _showMessage("PIN set successfully!");
    Navigator.pushReplacementNamed(context, '/pin_success');
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

  ///main code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
                    onPressed: () {
                      Navigator.pushNamed(context, '/registration');
                    },
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    Icon(Icons.pending_outlined, size: 150, color: Colors.grey),

                    const SizedBox(height: 20),

                    const Text(
                      "Set New PIN",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Enter your new PIN to secure your account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    const SizedBox(height: 40),

                    /// PIN field
                    TextField(
                      controller: pinController,
                      obscureText: _obscurePin,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: "New PIN",
                        border: customBorder(noBorder: true), // removes border
                        focusedBorder: customBorder(
                          isFocused: true,
                          color: Colors.grey,
                          width: 2,
                        ),
                        enabledBorder: customBorder(color: Colors.grey),
                        counterText: "",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePin
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePin = !_obscurePin;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Confirm PIN field
                    TextField(
                      controller: confirmPinController,
                      obscureText: _obscureConfirmPin,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: "Confirm PIN",
                        border: customBorder(noBorder: true), // removes border
                        focusedBorder: customBorder(
                          isFocused: true,
                          color: Colors.grey,
                          width: 2,
                        ),
                        enabledBorder: customBorder(color: Colors.grey),
                        counterText: "",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPin
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPin = !_obscureConfirmPin;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 190),

                    ElevatedButton(
                      onPressed: () {
                        _onConfirm();
                        print(pinController); //test parse lng?
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 130,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(fontSize: 18, color: Colors.black),
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
