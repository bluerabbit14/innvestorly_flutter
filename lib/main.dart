
import 'package:flutter/material.dart';
import 'package:innvestorly_flutter/Pages/DashboardPage.dart';
import 'package:innvestorly_flutter/Pages/LoadingPage.dart';
import 'package:innvestorly_flutter/Pages/LoginPage.dart';
import 'package:innvestorly_flutter/Pages/ForgotPasswordPage.dart';
import 'package:innvestorly_flutter/Pages/MPINPage.dart';
import 'package:innvestorly_flutter/services/ThemeService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeMode = await ThemeService.getThemeMode();
  
  runApp(MyApp(initialThemeMode: themeMode));
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  
  const MyApp({super.key, required this.initialThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    ThemeService.themeNotifier.value = widget.initialThemeMode;
    // Listen to theme changes
    ThemeService.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeService.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {
      _themeMode = ThemeService.themeNotifier.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Color(0xFF3AB7BF),
        scaffoldBackgroundColor: Color(0xFFE0F2F7),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF3AB7BF),
          secondary: Color(0xFF4A90E2),
          surface: Colors.white,
          background: Color(0xFFE0F2F7),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: Color(0xFF3AB7BF),
        scaffoldBackgroundColor: Color(0xFF265984),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF3AB7BF),
          secondary: Color(0xFF4A90E2),
          surface: Color(0xFF1E3A5F),
          background: Color(0xFF265984),
        ),
      ),
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => LoadingPage(),
        '/LoginPage': (context) => LoginPage(),
        '/ForgotPasswordPage': (context) => Forgotpasswordpage(),
        '/DashboardPage': (context) => DashboardPage(),
        '/MPINPage': (context) => MPINPage(),
      },
    );
  }
}

