// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ConnectedDevices/admin_list.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ConnectedDevices/dialog_boxes.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ConnectedDevices/staff_list.dart';

class ConnectedDevices extends StatefulWidget {
  const ConnectedDevices({super.key});

  @override
  State<ConnectedDevices> createState() => _ConnectedDevicesState();
}

class _ConnectedDevicesState extends State<ConnectedDevices> {
  // 👤 Owner List
  List ownerList = [
    ["Joseph Dela Cruz"],
  ];

  // 🧑‍💼 Admin List
  List adminList = [
    ["Andrea Villanueva"],
    ["Miguel Santos"],
  ];

  // 👷 Staff List
  List staffList = [
    ["Karla Reyes"],
    ["Liam Fernandez"],
    ["Nicole Marasigan"],
    ["John Arcilla"],
    ["Bianca Gomez"],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/cblist');
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black, size: 30),
                  onPressed: () => showNavigateDialog(context),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Blocklists') {
                      showBlockListDialog(context);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'Blocklists',
                      child: Text('Blocklists'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 210),

                    // 🧍 OWNER SECTION ------------------------------------------------
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      child: Container(
                        width: double.infinity,
                        child: const Text(
                          'Owner',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: ownerList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 30,
                            right: 30,
                            bottom: 8,
                          ),
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.person, size: 40),
                                      SizedBox(width: 14),
                                      //Task Name
                                      Text(
                                        ownerList[index][0],
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    0.25,
                                  ), // Shadow color
                                  offset: Offset(0, 4), // Shadow position
                                  blurRadius: 4, // Blur effect
                                  spreadRadius: 0, // Spread effect
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // 🧑‍💼 ADMIN SECTION ---------------------------------------------
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      child: Container(
                        width: double.infinity,
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: adminList.length,
                      itemBuilder: (context, index) {
                        return AdminLists(adminName: adminList[index][0]);
                      },
                    ),

                    const SizedBox(height: 20),

                    // 👷 STAFF SECTION -----------------------------------------------
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      child: Container(
                        width: double.infinity,
                        child: const Text(
                          'Staffs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: staffList.length,
                      itemBuilder: (context, index) {
                        return StaffList(staffName: staffList[index][0]);
                      },
                    ),

                    SizedBox(height: 60),
                  ],
                ),
              ),

              // HEADER SECTION
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                color: Color(0xFFFFFFFF),
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  children: const [
                    SizedBox(height: 25),
                    Text(
                      'Welcome,',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Owner Name',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Manage user access levels below',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17),
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
