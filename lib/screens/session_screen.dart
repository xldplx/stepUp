import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SessionScreen extends StatefulWidget {
  final VoidCallback onStop;
  final Stream<void> stepStream;

  const SessionScreen(
      {super.key, required this.onStop, required this.stepStream});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int _steps = 0;
  int _seconds = 0;
  double _distance = 0;
  double _calories = 0;
  double _pace = 0;
  Position? _currentPosition;
  GoogleMapController? _mapController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _listenToSteps();
    _getCurrentLocation();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        _updatePace();
      });
    });
  }

  void _listenToSteps() {
    widget.stepStream.listen((_) {
      setState(() {
        _steps++;
        _updateDistance();
        _updateCalories();
        _updatePace();
      });
    });
  }

  void _updateDistance() {
    // Assuming an average step length of 0.762 meters (30 inches)
    _distance = _steps * 0.762 / 1000; // Convert to kilometers
  }

  void _updateCalories() {
    // A very simple calculation, assuming 0.04 calories burned per step
    _calories = _steps * 0.04;
  }

  void _updatePace() {
    if (_seconds > 0) {
      // Calculate pace in minutes per kilometer
      _pace = (_seconds / 60) / _distance;
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

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

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () {
              widget.onStop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(
                        _currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(0, 0),
                zoom: 15,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  _formatDuration(_seconds),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Steps', _steps.toString()),
                    _buildStatCard(
                        'Distance', '${_distance.toStringAsFixed(2)} km'),
                    _buildStatCard(
                        'Calories', '${_calories.toStringAsFixed(0)} kcal'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatCard('Pace',
                    '${_pace.isFinite ? _pace.toStringAsFixed(2) : '0.00'} min/km'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
