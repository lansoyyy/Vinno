import 'package:flutter/material.dart';

class SearchConnection extends StatefulWidget {
  const SearchConnection({super.key});

  @override
  State<SearchConnection> createState() => _SearchConnectionState();
}

class _SearchConnectionState extends State<SearchConnection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF3FDD82),
            height: 500,
            width: 500,
            child: Icon(
              Icons.wifi_rounded,
              size: 204,
              color: Color(0xFF287740),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(40.0),

            child: Column(
              children: [
                Text(
                  "Searching for a Wifi connection...",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                  softWrap: true,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                Text(
                  "Ensure your SCB is powered on and within range of your Wi-Fi network",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),

                SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• ", style: TextStyle(fontSize: 30)),
                    Expanded(
                      child: Text(
                        "If no connection is found, check your Wi-Fi and try again ",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
