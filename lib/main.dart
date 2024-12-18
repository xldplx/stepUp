import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  bool _isDarkMode = true;
  late final AnimationController _themeController;
  late final Animation<double> _themeAnimation;

  @override
  void initState() {
    super.initState();
    _themeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _themeAnimation = CurvedAnimation(
      parent: _themeController,
      curve: Curves.easeInOut,
    );
    if (!_isDarkMode) {
      _themeController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      if (_isDarkMode) {
        _themeController.reverse();
      } else {
        _themeController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeAnimation,
      builder: (context, child) {
        return MaterialApp(
          title: 'Step-Up',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: MainScreen(toggleTheme: toggleTheme),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
