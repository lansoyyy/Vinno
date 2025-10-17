import 'package:flutter/material.dart';

class AddNewCb extends StatefulWidget {
  const AddNewCb({super.key});

  @override
  State<AddNewCb> createState() => _AddNewCbState();
}

class _AddNewCbState extends State<AddNewCb> {
  final TextEditingController cbName = TextEditingController();
  final TextEditingController cbID = TextEditingController();
  final TextEditingController ampValue = TextEditingController();

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Navigator.pushNamed(context, '/cblist');
                        },
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Add Circuit Breaker",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      // SCB Name
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Enter SCB Name:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextField(
                            controller: cbName,
                            decoration: InputDecoration(
                              hintText: "eg. Kitchen CB",
                              border: customBorder(
                                noBorder: true,
                              ), // removes border
                              focusedBorder: customBorder(
                                isFocused: true,
                                color: Colors.grey,
                                width: 2,
                              ),
                              enabledBorder: customBorder(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),

                      // SCB ID
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Enter SCB ID:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextField(
                            controller: cbID,
                            decoration: InputDecoration(
                              hintText: "eg. AAAA-BBBB-CCCC-DDDD-1234",
                              border: customBorder(
                                noBorder: true,
                              ), // removes border
                              focusedBorder: customBorder(
                                isFocused: true,
                                color: Colors.grey,
                                width: 2,
                              ),
                              enabledBorder: customBorder(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),

                      // SCB Amperage
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Enter the circuit breaker rating (A):',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextField(
                            controller: ampValue,
                            decoration: InputDecoration(
                              hintText: "eg. 100",
                              border: customBorder(
                                noBorder: true,
                              ), // removes border
                              focusedBorder: customBorder(
                                isFocused: true,
                                color: Colors.grey,
                                width: 2,
                              ),
                              enabledBorder: customBorder(color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '*Note: The maximum current it can handle is 200 A.',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Validate inputs
                        if (cbName.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter SCB Name')),
                          );
                          return;
                        }
                        if (cbID.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter SCB ID')),
                          );
                          return;
                        }
                        if (ampValue.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please enter circuit breaker rating')),
                          );
                          return;
                        }

                        // Parse amperage value
                        final rating = double.tryParse(ampValue.text.trim());
                        if (rating == null || rating <= 0 || rating > 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please enter a valid rating (1-200 A)')),
                          );
                          return;
                        }

                        // Navigate with data
                        Navigator.pushNamed(
                          context,
                          '/wifi_connection_list',
                          arguments: {
                            'scbName': cbName.text.trim(),
                            'scbId': cbID.text.trim(),
                            'circuitBreakerRating': rating,
                          },
                        );
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
                        'Add CB',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/cblist');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDDDDDD),
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
                        'Cancel',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
