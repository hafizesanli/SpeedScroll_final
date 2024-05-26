import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:speed_scroll/providers/congestionLevelAPISimulation.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  static const LatLng _pApplePark = LatLng(37.3346, -122.0090);

  LatLng? _currentP;
  LatLng? _startMarker;
  LatLng? _endMarker;

  Set<Polyline> _polylines = {};
  String? _distance;
  String? _duration;
  List<double> _congestionLevels = [];
  List<double> distances = [];
  List<String> durations = [];
  int _minDistanceIndex = -1;

  @override
  void initState() {
    super.initState();
    _getLocationUpdates();
    _fetchCongestionData();
  }

  Future<void> _fetchCongestionData() async {
    List<double> congestionLevels = await fetchCongestionLevels();
    setState(() {
      _congestionLevels = congestionLevels;
    });
    print(
        "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++Congestion Levels: $_congestionLevels");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGoogleMap(),
          _buildRouteInfo(),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentP ?? _pGooglePlex,
            zoom: 13,
          ),
          markers: {
            if (_currentP != null)
              Marker(
                  markerId: const MarkerId("_currentLocation"),
                  position: _currentP!),
            if (_startMarker != null)
              Marker(
                  markerId: const MarkerId("_startMarker"),
                  position: _startMarker!),
            if (_endMarker != null)
              Marker(
                  markerId: const MarkerId("_endMarker"),
                  position: _endMarker!),
          },
          polylines: _polylines,
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          onLongPress: _handleMapLongPress,
          onTap: _handleMapTap,
          zoomControlsEnabled: true,
        ),
        Positioned(
          bottom: 16.0,
          left: 16.0,
          child: FloatingActionButton(
            mini: true,
            onPressed: _goToCurrentLocation,
            backgroundColor: Colors.white.withOpacity(0.7),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.my_location, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  void _handleMapTap(LatLng latLng) {
    setState(() {
      _startMarker = null;
      _endMarker = null;
      _startMarker = latLng;
    });
  }

  void _handleMapLongPress(LatLng latLng) {
    setState(() {
      if (_startMarker == null) {
        _startMarker = latLng;
      } else if (_endMarker == null) {
        _endMarker = latLng;
        _polylines.clear(); // Polylines listesini temizle
        distances.clear(); // distances listesini temizle
        durations.clear(); // durations listesini temizle
        _getDirections();
      }
    });
  }

  void _goToCurrentLocation() {
    if (_currentP != null && mapController != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(_currentP!));
    }
  }

  Future<void> _getLocationUpdates() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentP = LatLng(position.latitude, position.longitude);
    });

    mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentP!, 13));

    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentP = LatLng(position.latitude, position.longitude);
      });
    });
  }

  Future<void> _getDirections() async {
    String apiKey =
        "AIzaSyDGChhWJmu_zGgxPMVhJS6SHqw95I_lW_o"; // Google Directions API key
    String baseUrl = "https://maps.googleapis.com/maps/api/directions/json";

    String origin = "${_startMarker!.latitude},${_startMarker!.longitude}";
    String destination = "${_endMarker!.latitude},${_endMarker!.longitude}";

    String url =
        "$baseUrl?origin=$origin&destination=$destination&key=$apiKey&alternatives=true";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      // Check if response status is OK
      if (data["status"] == "OK") {
        setState(() {
          _polylines.clear();
        });

        // Define a list of colors to be used for different routes
        List<Color> colors = [Colors.red, Colors.green, Colors.blue];
        int colorIndex = 0;

        // Create lists to store the distances and durations
        List<double> routeDistances = [];
        List<String> routeDurations = [];

        // Define the scaling factors array (example)
        List<double> scalingFactors = _congestionLevels;

        // Iterate through the routes and draw each polyline with a different color
        for (var route in data["routes"]) {
          // Get distance and duration from the first leg of each route
          String distanceStr = route["legs"][0]["distance"]["text"];
          String durationStr = route["legs"][0]["duration"]["text"];
          routeDurations.add(durationStr);

          // Convert distance to double (assuming the distance is in kilometers)
          double distance = double.parse(distanceStr.split(" ")[0]);
          routeDistances.add(distance);

          // Print distance and duration
          print("Distance: $distance km, Duration: $durationStr");

          // Decode polyline and draw on map
          String polylinePoints = route["overview_polyline"]["points"];
          List<LatLng> decodedPolylinePoints = _decodePolyline(polylinePoints);

          // Assign a color to the polyline
          Color polylineColor = colors[colorIndex % colors.length];
          colorIndex++;

          // Draw polyline on the map
          setState(() {
            _polylines.add(Polyline(
              polylineId: PolylineId("route_${_polylines.length}"),
              points: decodedPolylinePoints,
              color: polylineColor,
              width: 5,
            ));
          });
        }

        // Print out all the distances before scaling
        print("Original Distances: $routeDistances");
        print("Original Durations: $routeDurations");

        // Multiply distances by scaling factors
        List<double> scaledDistances = [];
        for (int i = 0; i < routeDistances.length; i++) {
          double scaledDistance = routeDistances[i] * scalingFactors[i % scalingFactors.length];
          scaledDistances.add(scaledDistance);
          print("Original Distance: ${routeDistances[i]} km, Scaled Distance: $scaledDistance km");
        }

        // Print the arrays
        print("-------------------------------------------------------------------------------------------------------------------------------");
        print("Scaling Factors: $scalingFactors");
        print("Scaled Distances: $scaledDistances");

        // Find the minimum distance and its index
        double minDistance = scaledDistances.reduce((min, current) => min <= current ? min : current);
        int minDistanceIndex = scaledDistances.indexOf(minDistance);

        // Get the polyline for the route with the minimum distance
        String minDistancePolylinePoints = data["routes"][minDistanceIndex]["overview_polyline"]["points"];
        List<LatLng> minDistanceDecodedPolylinePoints = _decodePolyline(minDistancePolylinePoints);

        // Add the polyline for the route with the minimum distance to the map
        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId("min_distance_route"),
            points: minDistanceDecodedPolylinePoints,
            color: Colors.blue, // Example: display the route in blue color
            width: 5,
          ));
          _minDistanceIndex = minDistanceIndex;
          _distance = "${routeDistances[minDistanceIndex]} km";
          _duration = routeDurations[minDistanceIndex];
        });

      } else {
        print("Error: ${data["status"]}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Widget _buildRouteInfo() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 500),
      top: _distance != null ? 16.0 : -100.0,
      left: 16.0,
      right: 16.0,
      child: Card(
        color: Colors.white,
        elevation: 4.0,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _distance != null
                    ? 'Distance: $_distance'
                    : 'Distance: N/A',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Duration: ${_duration ?? 'N/A'}',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latDouble = lat / 1E5;
      double lngDouble = lng / 1E5;
      LatLng position = LatLng(latDouble, lngDouble);
      points.add(position);
    }
    return points;
  }
}
