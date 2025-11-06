
import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'ForgotPassword.dart';
import 'MandatoryPinPage.dart';
import 'DashboardPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innvestorly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xffe8f4fd)),
      ),
      home: Dashboardpage(),
    );
  }
}
