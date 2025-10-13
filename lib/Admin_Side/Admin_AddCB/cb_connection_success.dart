import 'package:flutter/material.dart';

class CBConnectionSuccess extends StatefulWidget {
  const CBConnectionSuccess({super.key});

  @override
  State<CBConnectionSuccess> createState() => _CBConnectionSuccessState();
}

class _CBConnectionSuccessState extends State<CBConnectionSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    color: Color(0xFF3FDD82),
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(30),
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Image(
                        image: AssetImage('images/circuit-breaker.png'),
                        height: 380,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(40.0),

                    child: Column(
                      children: [
                        Text(
                          "Connection Successful!",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 20),

                        Text(
                          "Your SCB is now connected. You can manage it from the dashboard",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/addnewcb');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 5,
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: const Text(
                          'Add Another SCB',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/cblist');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 5,
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: const Text(
                          'Done',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
