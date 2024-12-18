import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/circular_step_progress.dart';
import '../widgets/stats_card.dart';
import '../widgets/pace_indicator.dart';
import '../widgets/bpm_indicator.dart';

class HomeScreen extends StatefulWidget {
  final int currentSteps;

  const HomeScreen({super.key, required this.currentSteps});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bpm = 70;
  Timer? _bpmTimer;

  @override
  void initState() {
    super.initState();
    _startBpmSimulation();
  }

  @override
  void dispose() {
    _bpmTimer?.cancel();
    super.dispose();
  }

  void _startBpmSimulation() {
    // Simulates heart rate changes`
    _bpmTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        // Simulate BPM between 70-80 based on steps
        _bpm = 70 + (widget.currentSteps % 10);
      });
    });
  }

  double _calculatePace() {
    return widget.currentSteps / 30;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step-Up'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Hero(
                  tag: 'stepProgress',
                  child: CircularStepProgress(
                      steps: widget.currentSteps, goal: 10000),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.speed,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Current Pace',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${_calculatePace().toStringAsFixed(1)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'spm',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 80,
                            width: 1,
                            color: Theme.of(context).dividerColor,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Heart Rate',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$_bpm',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'bpm',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Distance',
                        value:
                            '${(widget.currentSteps * 0.0008).toStringAsFixed(2)} km',
                        icon: Icons.straighten,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatsCard(
                        title: 'Calories',
                        value:
                            '${(widget.currentSteps * 0.04).toStringAsFixed(0)} kcal',
                        icon: Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
