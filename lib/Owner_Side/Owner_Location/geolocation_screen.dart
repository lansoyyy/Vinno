import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GeolocationScreen extends StatefulWidget {
  const GeolocationScreen({super.key});

  @override
  State<GeolocationScreen> createState() => _GeolocationScreenState();
}

class _GeolocationScreenState extends State<GeolocationScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(14.6349, 121.0092); // Default: Manila
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  // Selected marker info
  String? _selectedMarkerId;
  bool _showMarkerDetails = false;

  // Mock user data - replace with actual data from Firebase
  final List<Map<String, dynamic>> _users = [
    {
      'id': '10294',
      'name': 'Emma Watson',
      'position': const LatLng(14.6349, 121.0092),
      'phone': '+1234567890',
      'type': 'admin', // admin or staff
    },
    {
      'id': '10295',
      'name': 'John Doe',
      'position': const LatLng(14.6359, 121.0102),
      'phone': '+0987654321',
      'type': 'staff',
    },
    {
      'id': '10296',
      'name': 'Jane Smith',
      'position': const LatLng(14.6339, 121.0082),
      'phone': '+1122334455',
      'type': 'admin',
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _createMarkers();
  }

  Future<void> _getCurrentLocation() async {
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
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentPosition),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _createMarkers() {
    Set<Marker> markers = {};
    Set<Circle> circles = {};

    // Add circuit breaker marker (red)
    markers.add(
      Marker(
        markerId: const MarkerId('circuit_breaker'),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Circuit Breaker'),
      ),
    );

    // Add user markers
    for (var user in _users) {
      final markerId = MarkerId(user['id']);
      markers.add(
        Marker(
          markerId: markerId,
          position: user['position'],
          icon: BitmapDescriptor.defaultMarkerWithHue(
            user['type'] == 'admin'
                ? BitmapDescriptor.hueBlue
                : BitmapDescriptor.hueGreen,
          ),
          onTap: () {
            _onMarkerTapped(user['id']);
          },
        ),
      );

      // Add circle around user
      circles.add(
        Circle(
          circleId: CircleId('circle_${user['id']}'),
          center: user['position'],
          radius: 100, // 100 meters radius
          fillColor: (user['type'] == 'admin' ? Colors.blue : Colors.green)
              .withOpacity(0.2),
          strokeColor: user['type'] == 'admin' ? Colors.blue : Colors.green,
          strokeWidth: 2,
        ),
      );
    }

    setState(() {
      _markers = markers;
      _circles = circles;
    });
  }

  void _onMarkerTapped(String markerId) {
    setState(() {
      _selectedMarkerId = markerId;
      _showMarkerDetails = true;
    });
  }

  Map<String, dynamic>? _getSelectedUser() {
    if (_selectedMarkerId == null) return null;
    return _users.firstWhere(
      (user) => user['id'] == _selectedMarkerId,
      orElse: () => {},
    );
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  void _shareLocation() {
    // TODO: Implement share location functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing live location...')),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_location, color: Colors.green),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/pin_location');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedUser = _getSelectedUser();

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            markers: _markers,
            circles: _circles,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Header
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2ECC71), Color(0xFF1EA557)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Geolocation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _showOptionsMenu,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Share Live Location Button
          if (!_showMarkerDetails)
            Positioned(
              bottom: 30,
              left: 30,
              right: 30,
              child: ElevatedButton.icon(
                onPressed: _shareLocation,
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text(
                  'Share Live Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ),

          // Marker Details Bottom Sheet
          if (_showMarkerDetails && selectedUser != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // User info row
                          Row(
                            children: [
                              // Avatar
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: selectedUser['type'] == 'admin'
                                      ? Colors.blue
                                      : Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Name and ID
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedUser['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '(#${selectedUser['id']})',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Close button
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _showMarkerDetails = false;
                                    _selectedMarkerId = null;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Distance info
                          Row(
                            children: [
                              Icon(
                                Icons.social_distance,
                                color: Colors.red.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Distance from the CB:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_calculateDistance(_currentPosition, selectedUser['position']).toStringAsFixed(0)} meters',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Location info
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.green.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Location:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${selectedUser['position'].latitude.toStringAsFixed(4)}, ${selectedUser['position'].longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // Call button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement call functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Calling ${selectedUser['name']}...',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.call,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Call',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
