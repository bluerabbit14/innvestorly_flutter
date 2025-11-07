
import 'package:flutter/material.dart';
import 'package:innvestorly_flutter/Pages/LoadingPage.dart';
import 'package:innvestorly_flutter/Pages/LoginPage.dart';
import 'package:innvestorly_flutter/Pages/ForgotPasswordPage.dart';

void main() => runApp(MaterialApp(
  home: Loginpage(),
  routes: {
    '/LoginPage': (context) => Loginpage(),
    '/ForgotPasswordPage': (context) => Forgotpasswordpage()
  },
));

