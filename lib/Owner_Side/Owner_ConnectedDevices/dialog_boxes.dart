import 'package:flutter/material.dart';

// For Adding Accounts
void showNavigateDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
        child: const Text('Add Account', style: TextStyle(fontSize: 30)),
      ),
      content: const Text(
        'For:',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
      actions: [
        Center(
          child: Column(
            children: [
              // Admin
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: Offset(0, 4), // x, y offset
                      blurRadius: 2,
                      spreadRadius: 0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12), // Match button shape
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.zero,
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.black,
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  child: Text(
                    'Admin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    // Navigator.pushNamed(context, '/login');
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('or', style: TextStyle(fontSize: 18)),
              ),

              // Admin
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: Offset(0, 4), // x, y offset
                      blurRadius: 2,
                      spreadRadius: 0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12), // Match button shape
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.zero,
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.black,
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  child: Text(
                    'Staff',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    // Navigator.pushNamed(context, '/login');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// For BlockLists
void showBlockListDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 400,
          width: 300,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Text(
                    'Blocklists',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),

                // Tab Bar
                const TabBar(
                  tabs: [
                    Tab(text: 'Admins'),
                    Tab(text: 'Staffs'),
                  ],
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    children: [
                      // Blocked Users List
                      ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => ListTile(
                          title: Text('Admin ${index + 1}'),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.settings_backup_restore,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              // Handle unblock action
                            },
                          ),
                        ),
                      ),

                      // Staffs List
                      ListView.builder(
                        itemCount: 3,
                        itemBuilder: (context, index) => ListTile(
                          title: Text('Staff ${index + 1}'),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.settings_backup_restore,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              // Handle unmute action
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Close button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
