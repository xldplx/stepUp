import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class StepDetector {
  final _stepController = StreamController<void>.broadcast();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  Stream<void> get stepStream => _stepController.stream;

  bool _isListening = false;
  DateTime? _lastStepTime;
  double _lastMagnitude = 0;
  static const double _threshold = 18.0;
  static const Duration _minStepInterval = Duration(milliseconds: 300);

  void startListening() {
    if (_isListening) return;
    _isListening = true;

    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      final magnitude = _calculateMagnitude(event);
      final now = DateTime.now();

      if (_lastStepTime == null ||
          now.difference(_lastStepTime!) > _minStepInterval) {
        if (magnitude > _threshold && _lastMagnitude <= _threshold) {
          _stepController.add(null);
          _lastStepTime = now;
        }
      }

      _lastMagnitude = magnitude;
    });
  }

  void stopListening() {
    if (!_isListening) return;
    _isListening = false;
    _accelerometerSubscription?.cancel();
  }

  double _calculateMagnitude(AccelerometerEvent event) {
    return sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
  }

  void dispose() {
    stopListening();
    _stepController.close();
  }
}
