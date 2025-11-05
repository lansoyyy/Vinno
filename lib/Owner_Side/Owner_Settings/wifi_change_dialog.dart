import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class WiFiChangeDialog extends StatefulWidget {
  final String currentWifiName;
  final String circuitBreakerId;
  final String circuitBreakerName;
  final Function(String wifiName, String password) onWifiChanged;

  const WiFiChangeDialog({
    super.key,
    required this.currentWifiName,
    required this.circuitBreakerId,
    required this.circuitBreakerName,
    required this.onWifiChanged,
  });

  @override
  State<WiFiChangeDialog> createState() => _WiFiChangeDialogState();
}

class _WiFiChangeDialogState extends State<WiFiChangeDialog> {
  bool isScanning = false;
  String? selectedNetwork;
  String? connectedSSID;
  List<WiFiAccessPoint> wifiNetworks = [];
  bool canScan = false;
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndScan();
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

  void _selectNetwork(String networkName, bool isSecured) {
    setState(() {
      selectedNetwork = networkName;
      passwordController.clear();
    });
  }

  void _connectToNetwork() {
    if (selectedNetwork == null || selectedNetwork!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a WiFi network'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    WiFiAccessPoint? selectedNetworkData;
    try {
      selectedNetworkData = wifiNetworks.firstWhere(
        (network) => network.ssid == selectedNetwork,
      );
    } catch (e) {
      // Network not found in list, create a default one
      selectedNetworkData = null;
    }

    final isSecured =
        selectedNetworkData != null ? _isSecured(selectedNetworkData) : true;
    final password = passwordController.text.trim();

    // Validate WiFi password for secured networks
    if (isSecured && password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter password for secured network'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isSecured && password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WiFi password must be at least 8 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call the callback with the new WiFi credentials
    widget.onWifiChanged(selectedNetwork!, password);

    // Close the dialog
    Navigator.of(context).pop();
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Change WiFi Network',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),

            // Current WiFi Info
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Circuit Breaker: ${widget.circuitBreakerName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current WiFi: ${widget.currentWifiName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Scan Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
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
            ),

            const SizedBox(height: 16),

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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: wifiNetworks.length,
                          itemBuilder: (context, index) {
                            final network = wifiNetworks[index];
                            final isSelected = selectedNetwork == network.ssid;
                            final isConnected = connectedSSID == network.ssid;
                            final isSecured = _isSecured(network);
                            final securityType = _getSecurityType(network);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                                    : Colors.white,
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
                                  _getSignalIcon(network.level),
                                  color: isSelected
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
                                          color: isSelected
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
                                  _selectNetwork(
                                    network.ssid,
                                    isSecured,
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),

            // Password Entry and Connect Button
            if (selectedNetwork != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Network: $selectedNetwork',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        WiFiAccessPoint? selectedNetworkData;
                        try {
                          selectedNetworkData = wifiNetworks.firstWhere(
                            (network) => network.ssid == selectedNetwork,
                          );
                        } catch (e) {
                          // Network not found in list
                          selectedNetworkData = null;
                        }

                        if (selectedNetworkData != null &&
                            _isSecured(selectedNetworkData)) {
                          return Column(
                            children: [
                              TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: "Enter WiFi Password",
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF4CAF50)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              const Text(
                                'This is an open network (no password required)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _connectToNetwork,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Connect Circuit Breaker',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
