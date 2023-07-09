import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_buddy/constant/fonts.dart';

import '../layout.dart';

class MapPicker extends StatefulWidget {
  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  TextEditingController search = TextEditingController();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getMarkersFromFirestore();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Location Permission Denied',
                style: appbar,
              ),
              content: Text(
                'Please grant permission to access the device\'s location to use this feature.',
                style: title,
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: buttonText,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Location Permission Denied',
              style: appbar,
            ),
            content: Text(
              'Location permissions are permanently denied. Please enable them in the device settings to use this feature.',
              style: title,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: buttonText,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (isLocationServiceEnabled) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Location Services Disabled',
              style: appbar,
            ),
            content: Text(
              'Please enable location services to use this feature.',
              style: title,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: buttonText,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: search,
          decoration: InputDecoration(
            hintText: 'Search...',
          ),
          onChanged: (value) {
            _searchMarkers(value);
          },
        ),
      ),
      body: Stack(
        children: [
          _currentPosition == null
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                )
              : GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 10,
                  ),
                  markers: _markers,
                  myLocationEnabled: true, // Added line
                  myLocationButtonEnabled: true, // Added line
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                ),
        ],
      ),
    );
  }

  void _getMarkersFromFirestore() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<QueryDocumentSnapshot> docs = querySnapshot.docs;

    for (QueryDocumentSnapshot doc in docs) {
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

        double? lat = data['latitude'];
        double? lng = data['longitude'];
        if (lat != null && lng != null) {
          LatLng latLng = LatLng(lat, lng);
          final imageConfiguration = ImageConfiguration(size: Size(30, 30));
          try {
            BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
              imageConfiguration,
              'images/Vector.png',
            );

            // Perform null checks before accessing the string fields
            String name = data['name'] ?? '';
            String profile = data['profile'] ?? '';
            String email = data['email']?.toString() ?? '';

            Marker marker = Marker(
              markerId: MarkerId(doc.id),
              position: latLng,
              icon: markerIcon,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 200,
                      child: LayoutBottomSheet(
                        name: name,
                        profile: profile,
                        email: email,
                      ),
                    );
                  },
                );
              },
              infoWindow: InfoWindow(
                title: data["name"] ?? '',
                snippet: '', // empty snippet for now
              ),
            );
            setState(() {
              _markers.add(marker);
            });
          } catch (e) {
            print('Error loading marker icon: $e');
          }
        }
      }
    }
  }

  void _searchMarkers(String query) {
    Set<Marker> filteredMarkers = {};

    if (query.isEmpty) {
      filteredMarkers = _markers;
    } else {
      for (Marker marker in _markers) {
        if (marker.infoWindow.title!
            .toLowerCase()
            .contains(query.toLowerCase())) {
          filteredMarkers.add(marker);
        }
      }
    }

    setState(() {
      _markers = filteredMarkers;
    });
  }
}
