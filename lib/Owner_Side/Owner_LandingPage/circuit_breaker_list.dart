// ignore_for_file: sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_LandingPage/circuit_breaker_tile.dart';
import 'package:smart_cb_1/Owner_Side/Owner_LandingPage/nav_home.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/statistics_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';
import 'package:smart_cb_1/services/threshold_monitor_service.dart';
import 'package:smart_cb_1/util/const.dart';

class CircuitBreakerList extends StatefulWidget {
  const CircuitBreakerList({super.key});

  @override
  State<CircuitBreakerList> createState() => _CircuitBreakerListState();
}

class _CircuitBreakerListState extends State<CircuitBreakerList> {
  bool isEditMode = false; // tracks if user is editing
  Set<String> selectedBracketNames = {}; // stores indexes of selected tiles
  late List<List<dynamic>> originalBracketList;

  List<Map<String, dynamic>> undoStack = [];
  List<Map<String, dynamic>> redoStack = [];

  // Changed from hardcoded list to dynamic list from Firebase
  List<Map<String, dynamic>> bracketList = [];
  bool isLoading = true;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? currentUserId;
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Controllers for editing
  Map<String, TextEditingController> _nameControllers = {};
  Map<String, TextEditingController> _wifiControllers = {};

  // Track unsaved changes for undo/redo functionality
  Map<String, String> _originalNames = {};
  Map<String, String> _originalWifiNames = {};
  @override
  void initState() {
    super.initState();
    _fetchCircuitBreakers();
  }

  Future<void> _fetchCircuitBreakers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      currentUserId = user.uid;

      // Listen to circuit breakers in real-time
      _dbRef.child('circuitBreakers').onValue.listen((event) async {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data == null) {
          if (mounted) {
            setState(() {
              bracketList = [];
              isLoading = false;
            });
          }
          return;
        }

        List<Map<String, dynamic>> loadedCBs = [];

        // Convert to list to await all trip counts
        final entries = data.entries.toList();

        for (var entry in entries) {
          final key = entry.key as String;
          final cbData = Map<String, dynamic>.from(entry.value as Map);

          // Only load circuit breakers owned by current user
          if (box.read('accountType') == 'Admin' ||
              box.read('accountType') == 'Staff') {
            DocumentSnapshot? userData =
                await _authService.getUserData(currentUserId ?? '');
            if (userData != null && userData.exists) {
              Map<String, dynamic> data =
                  userData.data() as Map<String, dynamic>;

              if (cbData['ownerId'] == data['createdBy']) {
                // Check if this CB already exists in our list and update if needed
                final existingIndex =
                    loadedCBs.indexWhere((cb) => cb['scbId'] == key);
                if (existingIndex == -1) {
                  // Only add if not already in the list
                  // Compute power using formula: Power = Voltage × Current
                  final voltage = (cbData['voltage'] ?? 0).toDouble();
                  final current = (cbData['current'] ?? 0).toDouble();
                  final computedPower = voltage * current;

                  // Get trip count for this circuit breaker
                  final tripCount = await _getTripCount(key);

                  loadedCBs.add({
                    'scbId': key,
                    'scbName': cbData['scbName'] ?? 'Unknown',
                    'isOn': cbData['isOn'] ?? false,
                    'circuitBreakerRating': cbData['circuitBreakerRating'] ?? 0,
                    'voltage': voltage,
                    'current': current,
                    'temperature': cbData['temperature'] ?? 0,
                    'power':
                        computedPower, // Use computed power instead of stored value
                    'energy': cbData['energy'] ?? 0,
                    'latitude': cbData['latitude'] ?? 0.0,
                    'longitude': cbData['longitude'] ?? 0.0,
                    'wifiName': cbData['wifiName'] ?? '',
                    'tripCount': tripCount, // Add trip count
                  });
                } else {
                  // Update existing CB data instead of replacing the whole list
                  loadedCBs[existingIndex] = {
                    ...loadedCBs[existingIndex],
                    'scbName': cbData['scbName'] ??
                        loadedCBs[existingIndex]['scbName'],
                    'isOn': cbData['isOn'] ?? loadedCBs[existingIndex]['isOn'],
                    'voltage': (cbData['voltage'] ?? 0).toDouble(),
                    'current': (cbData['current'] ?? 0).toDouble(),
                    'temperature': cbData['temperature'] ??
                        loadedCBs[existingIndex]['temperature'],
                    'power': (cbData['voltage'] ?? 0).toDouble() *
                        (cbData['current'] ?? 0).toDouble(),
                    'energy':
                        cbData['energy'] ?? loadedCBs[existingIndex]['energy'],
                    'wifiName': cbData['wifiName'] ??
                        loadedCBs[existingIndex]['wifiName'],
                  };
                }
              }
            }
          } else {
            if (cbData['ownerId'] == currentUserId) {
              // Check if this CB already exists in our list and update if needed
              final existingIndex =
                  loadedCBs.indexWhere((cb) => cb['scbId'] == key);
              if (existingIndex == -1) {
                // Only add if not already in the list
                // Compute power using formula: Power = Voltage × Current
                final voltage = (cbData['voltage'] ?? 0).toDouble();
                final current = (cbData['current'] ?? 0).toDouble();
                final computedPower = voltage * current;

                // Get trip count for this circuit breaker
                final tripCount = await _getTripCount(key);

                loadedCBs.add({
                  'scbId': key,
                  'scbName': cbData['scbName'] ?? 'Unknown',
                  'isOn': cbData['isOn'] ?? false,
                  'circuitBreakerRating': cbData['circuitBreakerRating'] ?? 0,
                  'voltage': voltage,
                  'current': current,
                  'temperature': cbData['temperature'] ?? 0,
                  'power':
                      computedPower, // Use computed power instead of stored value
                  'energy': cbData['energy'] ?? 0,
                  'latitude': cbData['latitude'] ?? 0.0,
                  'longitude': cbData['longitude'] ?? 0.0,
                  'wifiName': cbData['wifiName'] ?? '',
                  'tripCount': tripCount, // Add trip count
                });
              } else {
                // Update existing CB data instead of replacing the whole list
                loadedCBs[existingIndex] = {
                  ...loadedCBs[existingIndex],
                  'scbName':
                      cbData['scbName'] ?? loadedCBs[existingIndex]['scbName'],
                  'isOn': cbData['isOn'] ?? loadedCBs[existingIndex]['isOn'],
                  'voltage': (cbData['voltage'] ?? 0).toDouble(),
                  'current': (cbData['current'] ?? 0).toDouble(),
                  'temperature': cbData['temperature'] ??
                      loadedCBs[existingIndex]['temperature'],
                  'power': (cbData['voltage'] ?? 0).toDouble() *
                      (cbData['current'] ?? 0).toDouble(),
                  'energy':
                      cbData['energy'] ?? loadedCBs[existingIndex]['energy'],
                  'wifiName': cbData['wifiName'] ??
                      loadedCBs[existingIndex]['wifiName'],
                };
              }
            }
          }
        }

        // Only update state if the widget is still mounted and the list has changed
        if (mounted) {
          setState(() {
            bracketList = loadedCBs;
            isLoading = false;
          });
        }
      });
    } catch (e) {
      print('Error fetching circuit breakers: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Switch Changed - Update Firebase
  Future<void> switchChanged(bool? value, int index) async {
    final cb = bracketList[index];
    final currentState = cb['isOn'] ?? false;
    final newState = !currentState;
    final action = newState ? 'turn ON' : 'turn OFF';

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Circuit Breaker Action'),
          content: Text('Are you sure you want to $action ${cb['scbName']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: newState ? Colors.red : Color(0xFF2ECC71),
              ),
              child: Text(action.toUpperCase()),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Optimistically update UI
    setState(() {
      bracketList[index]['isOn'] = newState;
    });

    try {
      // Update in Firebase
      await _dbRef
          .child('circuitBreakers')
          .child(cb['scbId'])
          .update({'isOn': newState});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cb['scbName']} turned ${newState ? 'ON' : 'OFF'}'),
          duration: Duration(seconds: 2),
        ),
      );

      // Log the circuit breaker action to activity logs
      await ThresholdMonitorService.logCircuitBreakerAction(
        scbId: cb['scbId'],
        scbName: cb['scbName'],
        action: newState ? 'on' : 'off',
      );
    } catch (e) {
      // Revert on error
      setState(() {
        bracketList[index]['isOn'] = currentState;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating circuit breaker: $e')),
      );
    }
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteConfirmation() async {
    final count = selectedBracketNames.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Circuit Breakers'),
          content: Text(
            count == 1
                ? 'Are you sure you want to delete this circuit breaker?'
                : 'Are you sure you want to delete $count circuit breakers?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteSelectedCircuitBreakers();
    }
  }

  // Delete selected circuit breakers from Firebase
  Future<void> _deleteSelectedCircuitBreakers() async {
    final selectedIds = bracketList
        .where((cb) => selectedBracketNames.contains(cb['scbName']))
        .map((cb) => cb['scbId'])
        .toList();

    if (selectedIds.isEmpty) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2ECC71),
        ),
      ),
    );

    try {
      // Delete each circuit breaker from Firebase
      for (String scbId in selectedIds) {
        await _dbRef.child('circuitBreakers').child(scbId).remove();
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedIds.length == 1
                ? 'Circuit breaker deleted successfully'
                : '${selectedIds.length} circuit breakers deleted successfully',
          ),
          backgroundColor: Color(0xFF2ECC71),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear selection and exit edit mode
      setState(() {
        selectedBracketNames.clear();
        isEditMode = false;
      });
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting circuit breakers: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Save circuit breaker name
  Future<void> _saveCircuitBreakerName(String scbId, int index) async {
    final controller = _nameControllers[scbId];
    if (controller == null) return;

    final newName = controller.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Circuit breaker name cannot be empty')),
      );
      return;
    }

    if (newName == bracketList[index]['scbName']) {
      return; // No change needed
    }

    try {
      // Update in Firebase
      await _dbRef
          .child('circuitBreakers')
          .child(scbId)
          .update({'scbName': newName});

      // Update local state
      setState(() {
        bracketList[index]['scbName'] = newName;

        // Update selectedBracketNames if this item was selected
        if (selectedBracketNames.contains(bracketList[index]['scbName'])) {
          selectedBracketNames.remove(bracketList[index]['scbName']);
          selectedBracketNames.add(newName);
        }

        // Clear original name since it's now saved
        _originalNames.remove(scbId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Circuit breaker name updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating circuit breaker name: $e')),
      );
    }
  }

  // Save circuit breaker WiFi
  Future<void> _saveCircuitBreakerWifi(String scbId, int index) async {
    final controller = _wifiControllers[scbId];
    if (controller == null) return;

    final newWifiName = controller.text.trim();
    if (newWifiName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('WiFi name cannot be empty')),
      );
      return;
    }

    if (newWifiName == bracketList[index]['wifiName']) {
      return; // No change needed
    }

    try {
      // Update in Firebase - now we only store the WiFi name
      // The password is handled by the WiFi change dialog and not stored in Firebase
      // for security reasons
      await _dbRef
          .child('circuitBreakers')
          .child(scbId)
          .update({'wifiName': newWifiName});

      // Update local state
      setState(() {
        bracketList[index]['wifiName'] = newWifiName;

        // Clear original WiFi name since it's now saved
        _originalWifiNames.remove(scbId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WiFi connection updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating WiFi connection: $e')),
      );
    }
  }

  // Check if undo is available
  bool get _canUndo => undoStack.isNotEmpty;

  // Check if redo is available
  bool get _canRedo => redoStack.isNotEmpty;

  // Cancel edit mode and discard changes
  void _cancelEditMode() {
    setState(() {
      isEditMode = false;
      selectedBracketNames.clear();

      // Revert all unsaved changes
      for (String scbId in _originalNames.keys.toList()) {
        if (_nameControllers.containsKey(scbId)) {
          _nameControllers[scbId]!.text = _originalNames[scbId] ?? '';
        }
        if (_wifiControllers.containsKey(scbId)) {
          _wifiControllers[scbId]!.text = _originalWifiNames[scbId] ?? '';
        }
      }

      // Clear tracking
      _originalNames.clear();
      _originalWifiNames.clear();
      undoStack.clear();
      redoStack.clear();
    });
  }

  // Undo changes
  void _undoChanges() {
    if (!_canUndo) return;

    // Save current state to redo stack
    redoStack.add(_createSnapshot());

    // Restore previous state from undo stack
    final previousState = undoStack.removeLast();
    _restoreFromSnapshot(previousState);

    setState(() {});
  }

  // Redo changes
  void _redoChanges() {
    if (!_canRedo) return;

    // Save current state to undo stack
    undoStack.add(_createSnapshot());

    // Restore next state from redo stack
    final nextState = redoStack.removeLast();
    _restoreFromSnapshot(nextState);

    setState(() {});
  }

  // Save all changes
  void _saveAllChanges() async {
    // Save all current changes to Firebase
    for (String scbId in _nameControllers.keys) {
      if (_nameControllers.containsKey(scbId)) {
        await _saveCircuitBreakerName(
            scbId, bracketList.indexWhere((cb) => cb['scbId'] == scbId));
      }
    }

    for (String scbId in _wifiControllers.keys) {
      if (_wifiControllers.containsKey(scbId)) {
        await _saveCircuitBreakerWifi(
            scbId, bracketList.indexWhere((cb) => cb['scbId'] == scbId));
      }
    }

    // Clear tracking and exit edit mode
    setState(() {
      isEditMode = false;
      selectedBracketNames.clear();
      _originalNames.clear();
      _originalWifiNames.clear();
      undoStack.clear();
      redoStack.clear();
    });
  }

  // Create a snapshot of current state
  Map<String, dynamic> _createSnapshot() {
    final Map<String, dynamic> snapshot = {};

    for (String scbId in _nameControllers.keys) {
      if (_nameControllers.containsKey(scbId)) {
        snapshot[scbId] = _nameControllers[scbId]!.text;
      }
    }

    for (String scbId in _wifiControllers.keys) {
      if (_wifiControllers.containsKey(scbId)) {
        snapshot['${scbId}_wifi'] = _wifiControllers[scbId]!.text;
      }
    }

    return snapshot;
  }

  // Restore state from snapshot
  void _restoreFromSnapshot(Map<String, dynamic> snapshot) {
    for (String key in snapshot.keys) {
      if (key.endsWith('_wifi')) {
        final scbId = key.replaceAll('_wifi', '');
        if (_wifiControllers.containsKey(scbId)) {
          _wifiControllers[scbId]!.text = snapshot[key];
        }
      } else {
        if (_nameControllers.containsKey(key)) {
          _nameControllers[key]!.text = snapshot[key];
        }
      }
    }

    setState(() {});
  }

  // Get trip count for a specific circuit breaker
  Future<int> _getTripCount(String scbId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 0;

      final snapshot = await _firestore
          .collection('tripHistory')
          .where('userId', isEqualTo: user.uid)
          .where('scbId', isEqualTo: scbId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting trip count: $e');
      return 0;
    }
  }

  // Show edit mode confirmation dialog
  Future<void> _showEditConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Edit Mode'),
          content: Text(
              'Are you sure you want to enter edit mode? You can select and delete circuit breakers in this mode.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Enter Edit Mode'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        isEditMode = true;
        selectedBracketNames.clear();
      });
    }
  }

  // add new Bracket
  @override
  Widget build(BuildContext context) {
    print(box.read('accountType'));
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Main content with proper constraints
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  top: 50,
                  right: 30,
                  bottom: 30,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Settings
                    if (!isEditMode)
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/settingspage');
                        },
                        child: Icon(
                          Icons.settings,
                          size: 30,
                          color: Color(0xFF2ECC71),
                        ),
                      ),

                    if (isEditMode)
                      Row(
                        children: [
                          Text(
                            "Edit Mode  |  ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                    Text(
                      isEditMode ? "Edit Breakers" : "Circuit Breakers",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    // Edit Bracket Button
                    if (!isEditMode)
                      Visibility(
                        visible: box.read('accountType') != 'Staff',
                        child: GestureDetector(
                          onTap: () => _showEditConfirmationDialog(),
                          child: Icon(Icons.edit, size: 30),
                        ),
                      ),

                    // Delete Bracket/s Button
                    if (isEditMode)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Select All
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selectedBracketNames.length <
                                    bracketList.length) {
                                  // Select all
                                  selectedBracketNames = bracketList
                                      .map<String>(
                                        (item) => item['scbName'] as String,
                                      )
                                      .toSet();
                                } else {
                                  // Deselect all
                                  selectedBracketNames.clear();
                                }
                              });
                            },
                            child: Column(
                              children: [
                                Icon(
                                  selectedBracketNames.length ==
                                          bracketList.length
                                      ? Icons.check_box_rounded
                                      : Icons.check_box_outline_blank_rounded,
                                  size: 30,
                                  color: selectedBracketNames.length ==
                                          bracketList.length
                                      ? Colors.black.withOpacity(0.7)
                                      : Colors.black.withOpacity(0.5),
                                ),
                                Text(
                                  'All',
                                  style: TextStyle(
                                    color: selectedBracketNames.length ==
                                            bracketList.length
                                        ? Colors.black
                                        : Colors.black.withOpacity(0.5),
                                    fontWeight: selectedBracketNames.length ==
                                            bracketList.length
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 10),

                          // Delete Button
                          GestureDetector(
                            onTap: selectedBracketNames.isEmpty
                                ? null
                                : () => _showDeleteConfirmation(),
                            child: Icon(
                              Icons.delete_rounded,
                              size: 30,
                              color: selectedBracketNames.isEmpty
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Statistics
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatisticsMenu(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 30,
                    right: 30,
                    bottom: 10,
                  ),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Icon(
                            Icons.data_thresholding_outlined,
                            color: Colors.white,
                            size: 45,
                          ),

                          SizedBox(width: 10),

                          //Task Name
                          Text(
                            "Statistics",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF2ECC71),
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
                ),
              ),

              // Lists of Brackets
              bracketList.isEmpty
                  // No Brackets
                  ? isEditMode
                      ? Text('')
                      : Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'No brackets available.',
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                  ),
                                  child: Text(
                                    'Tap the plus ‘ + ‘ icon to start adding a new Smart Bracket ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                  // There are Brackets
                  : isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2ECC71),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            // Use AutomaticKeepAliveClientMixin to maintain state
                            addAutomaticKeepAlives: true,
                            addRepaintBoundaries: true,
                            addSemanticIndexes: true,
                            cacheExtent:
                                500, // Increase cache extent for better performance
                            padding: EdgeInsets.only(top: 0, bottom: 120),
                            itemCount: bracketList.length,
                            itemBuilder: (context, index) {
                              final cb = bracketList[index];
                              final scbId = cb['scbId'];

                              // Initialize controllers if not already done
                              if (!_nameControllers.containsKey(scbId)) {
                                _nameControllers[scbId] =
                                    TextEditingController(text: cb['scbName']);
                              }
                              if (!_wifiControllers.containsKey(scbId)) {
                                _wifiControllers[scbId] = TextEditingController(
                                    text: cb['wifiName'] ?? '');
                              }

                              return CircuitBreakerTile(
                                key: ValueKey(
                                    'cb_${cb['scbId']}'), // Add key for proper widget identification
                                bracketName: cb['scbName'],
                                turnOn: cb['isOn'],
                                onChanged: (value) =>
                                    switchChanged(value, index),
                                isEditMode: isEditMode,
                                isSelected: selectedBracketNames.contains(
                                  cb['scbName'],
                                ),
                                onCheckboxChanged: (checked) {
                                  setState(() {
                                    final name = cb['scbName'];
                                    if (checked == true) {
                                      selectedBracketNames.add(name);
                                    } else {
                                      selectedBracketNames.remove(name);
                                    }
                                  });
                                },
                                cbData: cb, // Pass complete CB data
                                nameController:
                                    isEditMode ? _nameControllers[scbId] : null,
                                wifiController:
                                    isEditMode ? _wifiControllers[scbId] : null,
                                onSaveName: isEditMode
                                    ? () =>
                                        _saveCircuitBreakerName(scbId, index)
                                    : null,
                                onSaveWifi: isEditMode
                                    ? () =>
                                        _saveCircuitBreakerWifi(scbId, index)
                                    : null,
                              );
                            },
                          ),
                        ),
            ],
          ),
          if (isEditMode)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.white.withOpacity(0.5),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    Container(
                      width: 151,
                      height: 46,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: Offset(0, 4), // x, y offset
                            blurRadius: 2,
                            spreadRadius: 0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(50),
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
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        child: Text('Cancel', textAlign: TextAlign.center),
                        onPressed: () {
                          _cancelEditMode();
                        },
                      ),
                    ),

                    // Undo Button
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: Offset(0, 4), // x, y offset
                            blurRadius: 2,
                            spreadRadius: 0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(50),
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
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        child: Icon(Icons.undo, size: 20),
                        onPressed: _canUndo ? _undoChanges : null,
                      ),
                    ),

                    // Redo Button
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: Offset(0, 4), // x, y offset
                            blurRadius: 2,
                            spreadRadius: 0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(50),
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
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        child: Icon(Icons.redo, size: 20),
                        onPressed: _canRedo ? _redoChanges : null,
                      ),
                    ),

                    // Save Button
                    Container(
                      width: 151,
                      height: 46,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: Offset(0, 4), // x, y offset
                            blurRadius: 2,
                            spreadRadius: 0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(50),
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
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        child: Text('Done', textAlign: TextAlign.center),
                        onPressed: () {
                          _saveAllChanges();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!isEditMode)
            // NAVIGATION ---------------------------------------------------------------------------------------------
            NavHome(circuitBreakers: bracketList),
        ],
      ),
    );
  }
}
