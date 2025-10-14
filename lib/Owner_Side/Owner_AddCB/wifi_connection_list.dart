import 'package:flutter/material.dart';

class WifiConnectionList extends StatefulWidget {
  const WifiConnectionList({super.key});

  @override
  State<WifiConnectionList> createState() => _WifiConnectionListState();
}

class _WifiConnectionListState extends State<WifiConnectionList> {
  bool isScanning = false;
  String? selectedNetwork;

  // Mock WiFi networks data - will be replaced with actual WiFi scanning package
  final List<Map<String, dynamic>> wifiNetworks = [
    {'name': 'Home WiFi', 'signal': 4, 'secured': true},
    {'name': 'Office Network', 'signal': 3, 'secured': true},
    {'name': 'Guest WiFi', 'signal': 2, 'secured': false},
    {'name': 'Neighbor WiFi', 'signal': 1, 'secured': true},
    {'name': 'Mobile Hotspot', 'signal': 3, 'secured': true},
    {'name': 'Coffee Shop', 'signal': 2, 'secured': false},
  ];

  void _scanWifi() {
    setState(() {
      isScanning = true;
    });

    // Simulate scanning delay - will be replaced with actual WiFi scan
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WiFi scan completed')),
      );
    });
  }

  void _connectToNetwork(String networkName, bool isSecured) {
    if (isSecured) {
      _showPasswordDialog(networkName);
    } else {
      _connectToOpenNetwork(networkName);
    }
  }

  void _showPasswordDialog(String networkName) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Connect to "$networkName"',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter WiFi Password:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String password = passwordController.text.trim();
                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter password')),
                  );
                  return;
                }
                Navigator.pop(context);
                // TODO: Implement actual WiFi connection with password
                _connectWithPassword(networkName, password);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );
  }

  void _connectWithPassword(String networkName, String password) {
    setState(() {
      selectedNetwork = networkName;
    });

    // Simulate connection - will be replaced with actual WiFi connection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connecting to $networkName...')),
    );

    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to $networkName')),
      );
      // Navigate to next step after successful connection
      Navigator.pushNamed(context, '/search_connection');
    });
  }

  void _connectToOpenNetwork(String networkName) {
    setState(() {
      selectedNetwork = networkName;
    });

    // Simulate connection - will be replaced with actual WiFi connection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connecting to $networkName...')),
    );

    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to $networkName')),
      );
      // Navigate to next step after successful connection
      Navigator.pushNamed(context, '/search_connection');
    });
  }

  IconData _getSignalIcon(int signalStrength) {
    switch (signalStrength) {
      case 4:
        return Icons.signal_wifi_4_bar;
      case 3:
        return Icons.signal_wifi_4_bar;
      case 2:
        return Icons.signal_wifi_4_bar;
      case 1:
        return Icons.signal_wifi_4_bar;
      default:
        return Icons.signal_wifi_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
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
                      "Connect to WiFi",
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

            // Instruction Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Text(
                    'Select a WiFi network to connect your circuit breaker',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Scan Button
                  ElevatedButton.icon(
                    onPressed: isScanning ? null : _scanWifi,
                    icon: Icon(
                      isScanning ? Icons.refresh : Icons.wifi_find,
                      color: isScanning ? Colors.grey : Colors.white,
                    ),
                    label: Text(
                      isScanning ? 'Scanning...' : 'Scan for Networks',
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // WiFi Networks List
            Expanded(
              child: isScanning
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF4CAF50),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Scanning for WiFi networks...',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : wifiNetworks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi_off,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'No WiFi networks found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Tap "Scan for Networks" to search',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: wifiNetworks.length,
                          itemBuilder: (context, index) {
                            final network = wifiNetworks[index];
                            final isSelected =
                                selectedNetwork == network['name'];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Icon(
                                  _getSignalIcon(network['signal']),
                                  color: isSelected
                                      ? const Color(0xFF4CAF50)
                                      : Colors.black87,
                                  size: 28,
                                ),
                                title: Text(
                                  network['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: isSelected
                                        ? const Color(0xFF4CAF50)
                                        : Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  network['secured']
                                      ? 'Secured'
                                      : 'Open Network',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing: network['secured']
                                    ? Icon(
                                        Icons.lock,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      )
                                    : null,
                                onTap: () {
                                  _connectToNetwork(
                                    network['name'],
                                    network['secured'],
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),

            // Bottom Info
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                'Make sure your phone is connected to the same network',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
