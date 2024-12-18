import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../services/step_detector.dart';
import '../models/session.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const MainScreen({super.key, required this.toggleTheme});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isTracking = false;
  int _currentSteps = 0;
  final StepDetector _stepDetector = StepDetector();
  List<Session> _sessions = [];
  String _userName = 'User';
  static const String _sessionsKey = 'sessions';
  static const String _userNameKey = 'userName';

  @override
  void initState() {
    super.initState();
    _loadData();
    _stepDetector.stepStream.listen((_) {
      setState(() {
        _currentSteps++;
      });
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load user name
    setState(() {
      _userName = prefs.getString(_userNameKey) ?? 'User';
    });

    // Load sessions
    final sessionsJson = prefs.getStringList(_sessionsKey);
    if (sessionsJson != null) {
      setState(() {
        _sessions = sessionsJson
            .map((json) => Session.fromJson(jsonDecode(json)))
            .toList();
      });
    }
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = _sessions
        .map((session) => jsonEncode(session.toJson()))
        .toList();
    await prefs.setStringList(_sessionsKey, sessionsJson);
  }

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    setState(() {
      _userName = name;
    });
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
      if (_isTracking) {
        _stepDetector.startListening();
      } else {
        _stepDetector.stopListening();
        _saveSession();
      }
    });
  }

  void _saveSession() {
    if (_currentSteps > 0) {
      final session = Session(
        steps: _currentSteps,
        date: DateTime.now(),
        duration: const Duration(minutes: 30),
      );
      setState(() {
        _sessions.add(session);
        _currentSteps = 0;
      });
      _saveSessions();
    }
  }

  void _updateUserName(String newName) {
    _saveUserName(newName);
  }

  @override
  void dispose() {
    _stepDetector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(currentSteps: _currentSteps),
      HistoryScreen(sessions: _sessions),
      ProfileScreen(userName: _userName, onNameChanged: _updateUserName),
      SettingsScreen(toggleTheme: widget.toggleTheme),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: _toggleTracking,
          child: Icon(_isTracking ? Icons.stop : Icons.play_arrow, size: 40),
          backgroundColor: _isTracking
              ? Colors.red
              : Theme.of(context).colorScheme.secondary,
          shape: const CircleBorder(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home,
                  color: _selectedIndex == 0
                      ? Theme.of(context).colorScheme.secondary
                      : null),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            IconButton(
              icon: Icon(Icons.history,
                  color: _selectedIndex == 1
                      ? Theme.of(context).colorScheme.secondary
                      : null),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
            const SizedBox(width: 80), // Space for the FAB
            IconButton(
              icon: Icon(Icons.person,
                  color: _selectedIndex == 2
                      ? Theme.of(context).colorScheme.secondary
                      : null),
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
            IconButton(
              icon: Icon(Icons.settings,
                  color: _selectedIndex == 3
                      ? Theme.of(context).colorScheme.secondary
                      : null),
              onPressed: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}
