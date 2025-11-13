import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Location/pin_location_screen.dart';
import 'package:smart_cb_1/util/const.dart';
import 'package:url_launcher/url_launcher.dart';

class GeolocationScreen extends StatefulWidget {
  List? circuitBreakers;

  GeolocationScreen({super.key, this.circuitBreakers});

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

  // Real user data from Firebase
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _circuitBreakers = [];
  bool _isLoadingUsers = true;
  String? _currentUserId;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Timer for periodic updates
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    await _getCurrentLocation();
    await _fetchUsersFromFirebase();
    await _fetchCircuitBreakersFromDatabase();
    await _getCurrentUserSharingStatus(); // Get current user's sharing status
    _createMarkers();

    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      print('update');
      await _fetchUsersFromFirebase();
      await _getCurrentUserSharingStatus(); // Update current user's sharing status
      _createMarkers();
    });
  }

  // Get current user's location sharing status from Firebase
  Future<void> _getCurrentUserSharingStatus() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String userType = box.read('accountType') == 'Staff'
            ? 'staff'
            : box.read('accountType') == 'Owner'
                ? 'owners'
                : 'admins';

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection(userType)
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          setState(() {
            shareLoc = userData['isSharingLocation'] ?? false;
          });
        }
      }
    } catch (e) {
      print('Error getting user sharing status: $e');
    }
  }

  Future<void> _fetchUsersFromFirebase() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      List<Map<String, dynamic>> allUsers = [];

      // Fetch owners
      QuerySnapshot ownersSnapshot =
          await FirebaseFirestore.instance.collection('owners').get();
      for (var doc in ownersSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (doc.id != _currentUserId &&
            data['latitude'] != null &&
            data['longitude'] != null &&
            data['latitude'] != 0 &&
            data['longitude'] != 0) {
          allUsers.add({
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'position': LatLng(data['latitude'], data['longitude']),
            'type': 'owner',
            'latitude': data['latitude'],
            'longitude': data['longitude'],
            'isSharingLocation': data['isSharingLocation'] ?? false,
            'mobile': data['mobile'] ?? '',
          });
        }
      }

      // Fetch admins
      QuerySnapshot adminsSnapshot =
          await FirebaseFirestore.instance.collection('admins').get();
      for (var doc in adminsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (doc.id != _currentUserId &&
            data['latitude'] != null &&
            data['longitude'] != null &&
            data['latitude'] != 0 &&
            data['longitude'] != 0) {
          allUsers.add({
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'position': LatLng(data['latitude'], data['longitude']),
            'type': 'admin',
            'latitude': data['latitude'],
            'longitude': data['longitude'],
            'isSharingLocation': data['isSharingLocation'] ?? false,
            'mobile': data['mobile'] ?? '',
          });
        }
      }

      // Fetch staff
      QuerySnapshot staffSnapshot =
          await FirebaseFirestore.instance.collection('staff').get();
      for (var doc in staffSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (doc.id != _currentUserId &&
            data['latitude'] != null &&
            data['longitude'] != null &&
            data['latitude'] != 0 &&
            data['longitude'] != 0) {
          allUsers.add({
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'position': LatLng(data['latitude'], data['longitude']),
            'type': 'staff',
            'latitude': data['latitude'],
            'longitude': data['longitude'],
            'isSharingLocation': data['isSharingLocation'] ?? false,
            'mobile': data['mobile'] ?? '',
          });
        }
      }

      setState(() {
        _users = allUsers;
        _isLoadingUsers = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _fetchCircuitBreakersFromDatabase() async {
    try {
      final snapshot = await _dbRef.child('circuitBreakers').get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> cbList = [];
        final data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          final cbData = Map<String, dynamic>.from(value as Map);

          // Only add circuit breakers with valid location
          if (cbData['latitude'] != null &&
              cbData['longitude'] != null &&
              cbData['latitude'] != 0 &&
              cbData['longitude'] != 0) {
            cbList.add({
              'loc': cbData['loc'] ?? '',
              'id': key,
              'scbName': cbData['scbName'] ?? 'Unknown CB',
              'scbId': cbData['scbId'] ?? key,
              'position': LatLng(
                (cbData['latitude'] as num).toDouble(),
                (cbData['longitude'] as num).toDouble(),
              ),
              'latitude': (cbData['latitude'] as num).toDouble(),
              'longitude': (cbData['longitude'] as num).toDouble(),
              'isOn': cbData['isOn'] ?? false,
              'ownerId': cbData['ownerId'] ?? '',
            });
          }
        });

        setState(() {
          _circuitBreakers = cbList;
        });

        print('Fetched ${cbList.length} circuit breakers');
      }
    } catch (e) {
      print('Error fetching circuit breakers: $e');
    }
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

  bool shareLoc = false;
  void _createMarkers() {
    Set<Marker> markers = {};
    Set<Circle> circles = {};

    // Add circuit breaker markers (red) from Realtime Database
    for (var cb in _circuitBreakers) {
      final markerId = MarkerId('cb_${cb['id']}');

      markers.add(
        Marker(
          markerId: markerId,
          position: cb['position'],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: cb['loc'],
            snippet: 'Circuit Breaker',
          ),
        ),
      );

      // Add circle around circuit breaker
      circles.add(
        Circle(
          circleId: CircleId('circle_cb_${cb['id']}'),
          center: cb['position'],
          radius: 100,
          fillColor: Colors.red.withOpacity(0.2),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ),
      );
    }

    // Add user markers - only show users who are actually sharing their location
    for (var user in _users) {
      // Only show users who are actually sharing their location
      if (user['isSharingLocation'] == true) {
        final markerId = MarkerId(user['id']);

        // Determine marker color based on user type
        double markerHue;
        Color circleColor;

        switch (user['type']) {
          case 'admin':
            markerHue = BitmapDescriptor.hueBlue;
            circleColor = Colors.blue;
            break;
          case 'staff':
            markerHue = BitmapDescriptor.hueGreen;
            circleColor = Colors.green;
            break;
          case 'owner':
          default:
            markerHue = BitmapDescriptor.hueOrange;
            circleColor = Colors.orange;
            break;
        }

        markers.add(
          Marker(
            markerId: markerId,
            position: user['position'],
            icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
            infoWindow: InfoWindow(
              title: user['name'],
              snippet: user['type'].toString().toUpperCase(),
            ),
            onTap: () {
              setState(() {
                selectedMobile = user['mobile'];
                _showMarkerDetails = true;
                _selectedMarkerId = user['id'];
              });
            },
          ),
        );

        // Add circle around user
        circles.add(
          Circle(
            circleId: CircleId('circle_${user['id']}'),
            center: user['position'],
            radius: 100, // 100 meters radius
            fillColor: circleColor.withOpacity(0.2),
            strokeColor: circleColor,
            strokeWidth: 2,
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
      _circles = circles;
    });
  }

  String selectedMobile = '';
  Map<String, dynamic>? _getSelectedUser() {
    if (_selectedMarkerId == null) return null;
    return _users.firstWhere(
      (user) => user['id'] == _selectedMarkerId,
      orElse: () => {},
    );
  }

  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? timer;
  Future<void> _shareLocation() async {
    // Cancel any existing timer
    timer?.cancel();

    setState(() {
      shareLoc = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing live location...')),
    );

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Update sharing status immediately
    try {
      String userType = box.read('accountType') == 'Staff'
          ? 'staff'
          : box.read('accountType') == 'Owner'
              ? 'owners'
              : 'admins';
      await _firestore.collection(userType).doc(user?.uid).update({
        'isSharingLocation': true,
      });
    } catch (e) {
      print('Error updating sharing status: $e');
    }

    // Start periodic location updates
    timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
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

          String userType = box.read('accountType') == 'Staff'
              ? 'staff'
              : box.read('accountType') == 'Owner'
                  ? 'owners'
                  : 'admins';
          await _firestore.collection(userType).doc(user?.uid).update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'lastLocationUpdate': FieldValue.serverTimestamp(),
            'isSharingLocation': true,
          });
        }
      } catch (e) {
        print('Error getting location: $e');
      }
    });
  }

  Future<void> _stopSharingLocation() async {
    // Cancel the timer first to stop location updates
    timer?.cancel();
    timer = null; // Clear the timer reference

    setState(() {
      shareLoc = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stopped sharing location')),
    );

    // Update user's location sharing status in Firestore
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String userType = box.read('accountType') == 'Staff'
            ? 'staff'
            : box.read('accountType') == 'Owner'
                ? 'owners'
                : 'admins';

        await FirebaseFirestore.instance
            .collection(userType)
            .doc(currentUser.uid)
            .update({'isSharingLocation': false});
      }
    } catch (e) {
      print('Error stopping location sharing: $e');
    }
  }

  void _showOptionsMenu() {
    // Check if current user's location is pinned
    bool isCurrentUserLocationPinned = false;
    if (_currentUserId != null) {
      for (var user in _users) {
        if (user['id'] == _currentUserId) {
          isCurrentUserLocationPinned = box.read('isPinnedLocation') ?? false;
          break;
        }
      }
    }

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
                title: const Text('Edit Location'),
                enabled:
                    !isCurrentUserLocationPinned, // Disable if location is pinned
                onTap: () {
                  if (!isCurrentUserLocationPinned) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PinLocationScreen(
                                circuitBreakers: widget.circuitBreakers,
                              )),
                    );
                  }
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
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
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
                    Visibility(
                      visible: box.read('accountType') != 'Staff',
                      child: IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: _showOptionsMenu,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Share Live Location Button

          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: ElevatedButton.icon(
              onPressed: shareLoc ? _stopSharingLocation : _shareLocation,
              icon: const Icon(Icons.location_on, color: Colors.white),
              label: Text(
                shareLoc ? 'Stop Sharing Location' : 'Share Live Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    shareLoc ? Colors.red : const Color(0xFF4CAF50),
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
                                      : selectedUser['type'] == 'staff'
                                          ? Colors.green
                                          : Colors.orange,
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

                          const SizedBox(height: 25),

                          // Call button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await launchUrl(
                                    Uri.parse('tel:${selectedMobile}'));
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
    // Cancel the timers to prevent memory leaks
    timer?.cancel();
    timer = null;
    _updateTimer?.cancel();
    _updateTimer = null;

    // Dispose the map controller
    _mapController?.dispose();

    super.dispose();
  }
}
