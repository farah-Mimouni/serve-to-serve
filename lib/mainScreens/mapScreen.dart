import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added FirebaseAuth import
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart'; // Added geocoding import
import '../global/global.dart'; // For sharedPreferences

class MapScreen extends StatefulWidget {
  final double? totalAmmount;
  final String? sellerUID;

  const MapScreen({super.key, this.totalAmmount, this.sellerUID});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  LatLng _initialPosition =
      const LatLng(37.7749, -122.4194); // Fallback: San Francisco
  LatLng? _selectedPosition;
  bool _isLoading = true;
  final loc.Location _location = loc.Location();

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndServices();
    _loadAddressMarkers();
  }

  Future<void> _checkPermissionsAndServices() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services.')),
          );
        }
        return;
      }
    }

    // Check and request location permissions
    permissionGranted = await Permission.location.status;
    if (permissionGranted.isDenied || permissionGranted.isPermanentlyDenied) {
      permissionGranted = await Permission.location.request();
      if (permissionGranted.isDenied || permissionGranted.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is required.')),
          );
        }
        return;
      }
    }

    // Get current location
    if (permissionGranted.isGranted) {
      try {
        final loc.LocationData locationData = await _location.getLocation();
        if (locationData.latitude != null && locationData.longitude != null) {
          setState(() {
            _initialPosition =
                LatLng(locationData.latitude!, locationData.longitude!);
            _selectedPosition = _initialPosition; // Default to current location
          });
          if (_controller != null) {
            _controller!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: _initialPosition, zoom: 15),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error getting location: $e')),
          );
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadAddressMarkers() async {
    try {
      final userId = sharedPreferences!.getString("uid");
      if (userId == null) return;

      // Load user addresses from Firestore
      final userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("userAddress")
          .get();

      // Load all sellers from Firestore
      final sellersSnapshot =
          await FirebaseFirestore.instance.collection("sellers").get();

      if (mounted) {
        setState(() async {
          _markers.clear();
          // Add user address markers
          for (var doc in userSnapshot.docs) {
            final data = doc.data();
            if (data['latitude'] != null &&
                data['longitude'] != null &&
                data['latitude'] != 0 &&
                data['longitude'] != 0) {
              _markers.add(
                Marker(
                  markerId: MarkerId(doc.id),
                  position: LatLng(data['latitude'], data['longitude']),
                  infoWindow: InfoWindow(
                    title: data['street'] ?? 'Address',
                    snippet: data['city'],
                    onTap: () {
                      setState(() {
                        _selectedPosition =
                            LatLng(data['latitude'], data['longitude']);
                      });
                    },
                  ),
                ),
              );
            }
          }

          // Add all sellers' location markers by geocoding their addresses
          LatLng? firstValidSellerPosition;
          for (var doc in sellersSnapshot.docs) {
            final data = doc.data();
            final address =
                data['address']?.toString() ?? 'No address provided';
            final sellerName = data['sellerName'] ?? 'Seller';
            if (address != 'Address not provided' && address.isNotEmpty) {
              try {
                List<Location> locations = [];
                try {
                  // Geocode the address to get coordinates
                  locations = await locationFromAddress(address);
                } catch (e) {
                  print('Geocoding failed for address $address: $e');
                  continue; // Skip if geocoding fails
                }
                if (locations.isNotEmpty) {
                  final location = locations.first;
                  final position =
                      LatLng(location.latitude, location.longitude);
                  // Set the first valid seller position as initial map position
                  firstValidSellerPosition ??= position;
                  _markers.add(
                    Marker(
                      markerId: MarkerId(data['sellerUID'] ?? doc.id),
                      position: position,
                      infoWindow: InfoWindow(
                        title: sellerName,
                        snippet: address,
                        onTap: () {
                          setState(() {
                            _selectedPosition = position;
                          });
                        },
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor
                              .hueGreen), // Distinct color for sellers
                    ),
                  );
                }
              } catch (e) {
                print('Error processing seller $sellerName: $e');
              }
            }
          }

          // Update initial position to the first valid seller location, if available
          if (firstValidSellerPosition != null) {
            _initialPosition = firstValidSellerPosition;
            if (_controller != null) {
              _controller!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _initialPosition, zoom: 12),
                ),
              );
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //  SnackBar(content: Text('Error loading addresses: $e')),
        //);
      }
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          infoWindow: const InfoWindow(title: 'Selected Location'),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner Localisation'),
        actions: [
          if (_selectedPosition != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, _selectedPosition);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onTap: _onMapTapped,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                if (_initialPosition != const LatLng(37.7749, -122.4194)) {
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: _initialPosition, zoom: 15),
                    ),
                  );
                }
              },
            ),
    );
  }
}
