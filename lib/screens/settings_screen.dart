import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const SettingsScreen({super.key, required this.toggleTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedUnit = 'Metric';
  String _selectedLanguage = 'English';
  bool _showCalories = true;
  bool _showHeartRate = true;
  double _stepLength = 0.762; // meters
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _selectedUnit = prefs.getString('unit') ?? 'Metric';
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _showCalories = prefs.getBool('showCalories') ?? true;
      _showHeartRate = prefs.getBool('showHeartRate') ?? true;
      _stepLength = prefs.getDouble('stepLength') ?? 0.762;
      final reminderHour = prefs.getInt('reminderHour') ?? 20;
      final reminderMinute = prefs.getInt('reminderMinute') ?? 0;
      _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setString('unit', _selectedUnit);
    await prefs.setString('language', _selectedLanguage);
    await prefs.setBool('showCalories', _showCalories);
    await prefs.setBool('showHeartRate', _showHeartRate);
    await prefs.setDouble('stepLength', _stepLength);
    await prefs.setInt('reminderHour', _reminderTime.hour);
    await prefs.setInt('reminderMinute', _reminderTime.minute);
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Future<void> _showReminderTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
        _saveSettings();
      });
    }
  }

  Future<void> _showStepLengthDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        double tempStepLength = _stepLength;
        return AlertDialog(
          title: const Text('Step Length'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(tempStepLength * 100).toStringAsFixed(1)} cm',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: tempStepLength,
                min: 0.5,
                max: 1.0,
                divisions: 50,
                onChanged: (value) {
                  tempStepLength = value;
                  (context as Element).markNeedsBuild();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _stepLength = tempStepLength;
                  _saveSettings();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSettingSection(
            'Display',
            [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (bool value) {
                  widget.toggleTheme();
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Show Calories'),
                subtitle: const Text('Display calorie count'),
                value: _showCalories,
                onChanged: (value) {
                  setState(() {
                    _showCalories = value;
                    _saveSettings();
                  });
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Show Heart Rate'),
                subtitle: const Text('Display BPM'),
                value: _showHeartRate,
                onChanged: (value) {
                  setState(() {
                    _showHeartRate = value;
                    _saveSettings();
                  });
                },
              ),
            ],
          ),
          _buildSettingSection(
            'Preferences',
            [
              ListTile(
                title: const Text('Units'),
                subtitle: Text(_selectedUnit),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Select Unit'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile(
                              title: const Text('Metric (km)'),
                              value: 'Metric',
                              groupValue: _selectedUnit,
                              onChanged: (value) {
                                setState(() {
                                  _selectedUnit = value.toString();
                                  _saveSettings();
                                });
                                Navigator.pop(context);
                              },
                            ),
                            RadioListTile(
                              title: const Text('Imperial (miles)'),
                              value: 'Imperial',
                              groupValue: _selectedUnit,
                              onChanged: (value) {
                                setState(() {
                                  _selectedUnit = value.toString();
                                  _saveSettings();
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Language'),
                subtitle: Text(_selectedLanguage),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Add language selection dialog
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Step Length'),
                subtitle: Text('${(_stepLength * 100).toStringAsFixed(1)} cm'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showStepLengthDialog,
              ),
            ],
          ),
          _buildSettingSection(
            'Notifications',
            [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Get daily reminders'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                    _saveSettings();
                  });
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Reminder Time'),
                subtitle: Text('${_reminderTime.format(context)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showReminderTimePicker,
              ),
            ],
          ),
          _buildSettingSection(
            'About',
            [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              const Divider(),
              ListTile(
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Add terms of service page
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Add privacy policy page
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Licenses'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Step Up',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
