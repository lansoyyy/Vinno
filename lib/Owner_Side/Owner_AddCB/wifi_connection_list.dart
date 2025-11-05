import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class WifiConnectionList extends StatefulWidget {
  const WifiConnectionList({super.key});

  @override
  State<WifiConnectionList> createState() => _WifiConnectionListState();
}

class _WifiConnectionListState extends State<WifiConnectionList> {
  bool isScanning = false;
  String? selectedNetwork;
  String? connectedSSID;
  List<WiFiAccessPoint> wifiNetworks = [];
  bool canScan = false;

  // Circuit breaker data from previous screen
  Map<String, dynamic>? cbData;
  double? userLatitude;
  double? userLongitude;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _checkPermissionsAndScan();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get data passed from previous screen
    if (cbData == null) {
      cbData =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    }
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          userLatitude = position.latitude;
          userLongitude = position.longitude;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      // Set default location if error
      setState(() {
        userLatitude = 0.0;
        userLongitude = 0.0;
      });
    }
  }

  Future<void> _checkPermissionsAndScan() async {
    // Check if WiFi scan is supported
    final can = await WiFiScan.instance.canStartScan();
    setState(() {
      canScan = can == CanStartScan.yes;
    });

    if (canScan) {
      await _requestPermissions();
      await _getConnectedNetwork();
      await _scanWifi();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('WiFi scanning not supported on this device')),
      );
    }
  }

  Future<void> _requestPermissions() async {
    // Request location permission (required for WiFi scanning on Android)
    final status = await Permission.location.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permission is required to scan WiFi')),
      );
    }
  }

  Future<void> _getConnectedNetwork() async {
    try {
      final info = NetworkInfo();
      final wifiName = await info.getWifiName();
      setState(() {
        connectedSSID = wifiName?.replaceAll('"', ''); // Remove quotes
      });
    } catch (e) {
      print('Error getting connected network: $e');
    }
  }

  Future<void> _scanWifi() async {
    if (!canScan) return;

    setState(() {
      isScanning = true;
    });

    try {
      // Start WiFi scan
      final canStart = await WiFiScan.instance.canStartScan();
      if (canStart == CanStartScan.yes) {
        final result = await WiFiScan.instance.startScan();
        if (result) {
          // Wait a bit for scan to complete
          await Future.delayed(const Duration(seconds: 2));

          // Get scan results
          final results = await WiFiScan.instance.getScannedResults();

          // Remove duplicates and sort by signal strength
          final uniqueNetworks = <String, WiFiAccessPoint>{};
          for (var network in results) {
            if (network.ssid.isNotEmpty) {
              if (!uniqueNetworks.containsKey(network.ssid) ||
                  network.level > uniqueNetworks[network.ssid]!.level) {
                uniqueNetworks[network.ssid] = network;
              }
            }
          }

          // Sort by signal strength (higher is better)
          final sortedNetworks = uniqueNetworks.values.toList()
            ..sort((a, b) => b.level.compareTo(a.level));

          setState(() {
            wifiNetworks = sortedNetworks;
            isScanning = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Found ${wifiNetworks.length} networks')),
          );
        } else {
          setState(() {
            isScanning = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to start WiFi scan')),
          );
        }
      }
    } catch (e) {
      setState(() {
        isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning WiFi: $e')),
      );
    }
  }

  void _connectToNetwork(String networkName, bool isSecured) {
    // Always show password dialog for all networks
    _showPasswordDialog(networkName);
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
              const SizedBox(height: 5),
              const Text(
                '(Leave empty for open networks)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
                Navigator.pop(context);
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

    // Validate WiFi password
    if (password.isNotEmpty && password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'WiFi password must be at least 8 characters long for secured networks'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare all circuit breaker data
    final Map<String, dynamic> completeData = {
      // Data from add_new_cb screen
      'scbName': cbData?['scbName'] ?? '',
      'scbId': cbData?['scbId'] ?? '',
      'circuitBreakerRating': cbData?['circuitBreakerRating'] ?? 0,

      // WiFi data
      'wifiName': networkName,
      'wifiPassword': password,

      // User location
      'latitude': userLatitude ?? 0.0,
      'longitude': userLongitude ?? 0.0,

      // Initial values for other fields
      'isOn': true,
      'voltage': 0,
      'current': 0,
      'temperature': 0,
      'power': 0,
      'energy': 0,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuring device with WiFi: $networkName'),
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to next step with complete data
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushNamed(
        context,
        '/search_connection',
        arguments: completeData,
      );
    });
  }

  IconData _getSignalIcon(int level) {
    // WiFi signal levels are typically from -100 (weak) to -30 (strong)
    if (level >= -50) {
      return Icons.signal_wifi_4_bar;
    } else if (level >= -60) {
      return Icons.signal_wifi_4_bar;
    } else if (level >= -70) {
      return Icons.signal_wifi_4_bar;
    } else if (level >= -80) {
      return Icons.signal_wifi_4_bar;
    } else {
      return Icons.signal_wifi_statusbar_4_bar;
    }
  }

  String _getSecurityType(WiFiAccessPoint network) {
    if (network.capabilities.contains('WPA3')) return 'WPA3';
    if (network.capabilities.contains('WPA2')) return 'WPA2';
    if (network.capabilities.contains('WPA')) return 'WPA';
    if (network.capabilities.contains('WEP')) return 'WEP';
    return 'Open';
  }

  bool _isSecured(WiFiAccessPoint network) {
    return !network.capabilities.contains('[ESS]') ||
        network.capabilities.contains('WPA') ||
        network.capabilities.contains('WEP');
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
                            final isSelected = selectedNetwork == network.ssid;
                            final isConnected = connectedSSID == network.ssid;
                            final isSecured = _isSecured(network);
                            final securityType = _getSecurityType(network);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected || isConnected
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey.shade300,
                                  width: isSelected || isConnected ? 2 : 1,
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
                                  _getSignalIcon(network.level),
                                  color: isSelected || isConnected
                                      ? const Color(0xFF4CAF50)
                                      : Colors.black87,
                                  size: 28,
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        network.ssid,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: isSelected || isConnected
                                              ? const Color(0xFF4CAF50)
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (isConnected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4CAF50),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Connected',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Text(
                                  securityType,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing: isSecured
                                    ? Icon(
                                        Icons.lock,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      )
                                    : null,
                                onTap: () {
                                  _connectToNetwork(
                                    network.ssid,
                                    isSecured,
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
