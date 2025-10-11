import 'package:flutter/material.dart';

class AccountActivity extends StatelessWidget {
  const AccountActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
        children: [
          SizedBox(height: 50),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Stack(
              children: [
                //top spacing
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/otp_page');
                  },
                  icon: Icon(Icons.arrow_back),
                  iconSize: 30,
                ),

                SizedBox(width: 15),

                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Account Activity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What would you like to do with your account today?',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                ),

                SizedBox(height: 15),

                Text(
                  'Choose between the options below:',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16),
                ),

                SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF000000).withOpacity(0.25),
                        offset: Offset(-4, 4), // x, y offset
                        blurRadius: 2,
                        spreadRadius: 0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Match button shape
                  ),

                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/registration');
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Color(0xffC8E5C2),
                            borderRadius: BorderRadius.circular(
                              40,
                            ), // Match button shape
                          ),
                          child: Icon(
                            Icons.person,
                            color: Color(0xff2DCC70),
                            size: 50,
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Container(
                              width: 150,
                              child: Text(
                                'Create a new Vinno account',
                                overflow: TextOverflow.clip,
                                maxLines: 2,
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
