
import 'package:flutter/material.dart';
import 'package:innvestorly_flutter/Pages/DashboardPage.dart';
import 'package:innvestorly_flutter/Pages/LoadingPage.dart';
import 'package:innvestorly_flutter/Pages/LoginPage.dart';
import 'package:innvestorly_flutter/Pages/ForgotPasswordPage.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/LoginPage',
  routes: {
    '/': (context) => LoadingPage(),
    '/LoginPage': (context) => LoginPage(),
    '/ForgotPasswordPage': (context) => Forgotpasswordpage(),
    '/DashboardPage': (context) => DashboardPage()
  },
));

