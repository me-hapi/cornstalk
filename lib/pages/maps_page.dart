import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart'; // For getting the current location
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math'; // For calculating distance

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late MapController _mapController;
  LatLng? _currentLocation;
  LatLng _defaultLocation = LatLng(17.1381, 121.8734); // Default to Ilagan City
  bool _locationError = false;
  List<Marker> _markers = []; // List to store markers

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _setInitialLocation(); // Get the initial location
  }

  Future<void> _setInitialLocation() async {
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser != null) {
      String uid = currentUser.id;

      // Fetch user's location from Supabase
      final response = await Supabase.instance.client
          .from('User')
          .select('latitude, longitude')
          .eq('uid', uid)
          .maybeSingle(); // Retrieve the user's location or return null if not found

      if (response != null) {
        // If the user exists and location is found, use it as the default location
        setState(() {
          _currentLocation =
              LatLng(response['latitude'], response['longitude']);
        });
      } else {
        // If the user exists but no location is found, use the provided default
        _currentLocation = _defaultLocation;
      }
    } else {
      // No user, use the provided default location
      _currentLocation = _defaultLocation;
    }

    // After setting the initial location, proceed with getting the device location
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDisabledDialog();
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Try to get the current position and handle any errors
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            point: _currentLocation!,
            width: 80.0,
            height: 80.0,
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40.0,
            ),
          ),
        );
      });

      // Move the map to the current location
      _mapController.move(_currentLocation!, 15.0); // 15.0 is the zoom level

      // Update or insert user's location into Supabase
      if (currentUser != null) {
        await _insertOrUpdateUserLocation(
            currentUser.id, position.latitude, position.longitude);
      }
    } catch (e) {
      // Handle error in getting location
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _locationError = true;
        });
      }
      print('Error getting location: $e');
    }
  }

  // Method to insert or update the user's location in the Supabase table
  Future<void> _insertOrUpdateUserLocation(
      String uid, double latitude, double longitude) async {
    final response = await Supabase.instance.client
        .from('User')
        .select('uid')
        .eq('uid', uid);
    if (response.isNotEmpty) {
      // If the UID already exists, update the latitude and longitude
      await Supabase.instance.client.from('User').update(
          {'latitude': latitude, 'longitude': longitude}).eq('uid', uid);
    } else {
      // If the UID doesn't exist, insert a new row
      await Supabase.instance.client.from('User').insert({
        'uid': uid,
        'latitude': latitude,
        'longitude': longitude,
      });
    }
  }

  // Show dialog when location services are disabled
  void _showLocationDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Services Off"),
          content: const Text(
              "Your location services are disabled. Please enable them to view your current location."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Stream fetching nearby users in real time
  Stream<List<dynamic>> _streamNearbyUsers() {
    return Supabase.instance.client.from('User').stream(primaryKey: ['id']);
  }

  // StreamBuilder to update markers in real-time
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _locationError
          ? Center(
              child: Text(
                "Error detecting your location. Please try again.",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            )
          : StreamBuilder<List<dynamic>>(
              stream: _streamNearbyUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error fetching data: ${snapshot.error}'),
                  );
                }

                if (snapshot.hasData) {
                  _markers.clear(); // Clear previous markers
                  for (var user in snapshot.data!) {
                    // Calculate distance from current location
                    if (_currentLocation != null) {
                      double distance = _calculateDistance(
                        _currentLocation!.latitude,
                        _currentLocation!.longitude,
                        user['latitude'],
                        user['longitude'],
                      );

                      if (distance <= 100) {
                        _markers.add(
                          Marker(
                            point: LatLng(user['latitude'], user['longitude']),
                            width: 80.0,
                            height: 80.0,
                            child: Image.asset(
                              'assets/corn_danger.png', // Your custom marker image
                              width: 40.0,
                              height: 40.0,
                            ),
                          ),
                        );
                      }
                    }
                  }
                }

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation != null
                        ? LatLng(_currentLocation!.latitude,
                            _currentLocation!.longitude)
                        : _defaultLocation, // Use current location or default location
                    initialZoom: 15.0, // Initial zoom level
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: _markers, // Display real-time markers
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () =>
                              _launchURL('https://openstreetmap.org/copyright'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }

  // Helper method for launching URLs
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Haversine formula to calculate distance between two points (in km)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of the Earth in kilometers
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }
}
