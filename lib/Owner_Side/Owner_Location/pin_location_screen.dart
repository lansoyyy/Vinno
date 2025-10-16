import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:smart_cb_1/util/const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PinLocationScreen extends StatefulWidget {
  const PinLocationScreen({super.key});

  @override
  State<PinLocationScreen> createState() => _PinLocationScreenState();
}

class _PinLocationScreenState extends State<PinLocationScreen> {
  GoogleMapController? _mapController;
  LatLng _selectedPosition = const LatLng(14.6349, 121.0092); // Default: Manila
  final TextEditingController _locationNameController = TextEditingController();
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  // Places Autocomplete
  List<dynamic> _placesList = [];
  final _sessionToken = const Uuid().v4();
  bool _showPredictions = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _mapController?.dispose();
    super.dispose();
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
          _selectedPosition = LatLng(position.latitude, position.longitude);
        });
        _updateMarker(_selectedPosition);
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_selectedPosition),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          draggable: true,
          onDragEnd: (newPosition) {
            _updateMarker(newPosition);
          },
        ),
      };
      _circles = {
        Circle(
          circleId: const CircleId('selected_circle'),
          center: position,
          radius: 100,
          fillColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      };
    });
  }

  void _onMapTapped(LatLng position) {
    _updateMarker(position);
  }

  Future<void> _saveLocation() async {
    String locationName = _locationNameController.text.trim();

    if (locationName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location name')),
      );
      return;
    }

    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Get user document to determine account type
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('owners')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found')),
        );
        return;
      }

      String accountType = userDoc.get('accountType') ?? 'Owner';
      String collectionName;

      // Determine which collection to update based on account type
      switch (accountType.toLowerCase()) {
        case 'admin':
          collectionName = 'admins';
          break;
        case 'staff':
          collectionName = 'staff';
          break;
        case 'owner':
        default:
          collectionName = 'owners';
          break;
      }

      // Update latitude and longitude in the appropriate collection
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(currentUser.uid)
          .update({
        'latitude': _selectedPosition.latitude,
        'longitude': _selectedPosition.longitude,
        'locationName': locationName,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location "$locationName" saved successfully')),
      );

      // Navigate to geolocation screen
      Navigator.pushReplacementNamed(context, '/geolocation');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving location: $e')),
      );
    }
  }

  // Google Places Autocomplete
  Future<void> _searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() {
        _placesList = [];
        _showPredictions = false;
      });
      return;
    }

    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$apiKey&sessiontoken=$_sessionToken';

    try {
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        setState(() {
          _placesList = json.decode(response.body)['predictions'];
          _showPredictions = _placesList.isNotEmpty;
        });
      }
    } catch (e) {
      print('Error fetching places: $e');
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request =
        '$baseURL?place_id=$placeId&key=$apiKey&sessiontoken=$_sessionToken';

    try {
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        var result = json.decode(response.body)['result'];
        var location = result['geometry']['location'];
        LatLng newPosition = LatLng(location['lat'], location['lng']);

        setState(() {
          _showPredictions = false;
          _placesList = [];
        });

        _updateMarker(newPosition);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 16),
        );
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: Column(
        children: [
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
                      'Pin Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Name Input with Autocomplete
                    Column(
                      children: [
                        TextField(
                          controller: _locationNameController,
                          onChanged: (value) {
                            _searchPlaces(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Location',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF4CAF50),
                            ),
                            suffixIcon: _locationNameController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _locationNameController.clear();
                                        _placesList = [];
                                        _showPredictions = false;
                                      });
                                    },
                                  )
                                : null,
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
                                color: Color(0xFF4CAF50),
                                width: 2,
                              ),
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

                        // Predictions List
                        if (_showPredictions && _placesList.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _placesList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  title: Text(
                                    _placesList[index]['description'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _locationNameController.text =
                                          _placesList[index]['description'];
                                    });
                                    _getPlaceDetails(
                                        _placesList[index]['place_id']);
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Coordinates Label
                    const Text(
                      'Coordinates (Drag Pin or Tap Map to Set):',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Coordinates Display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        '${_selectedPosition.latitude.toStringAsFixed(8)}, ${_selectedPosition.longitude.toStringAsFixed(8)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Map Container
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _selectedPosition,
                            zoom: 16,
                          ),
                          markers: _markers,
                          circles: _circles,
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                          onTap: _onMapTapped,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
