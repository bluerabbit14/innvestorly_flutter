import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _appCodeFocusNode = FocusNode();
  bool _isPhoneFocused = false;
  bool _isAppCodeFocused = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {
        _isPhoneFocused = _phoneFocusNode.hasFocus;
      });
    });
    _appCodeFocusNode.addListener(() {
      setState(() {
        _isAppCodeFocused = _appCodeFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _appCodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F2F7),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              // Logo and Branding
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/innvestorly_logo.png',
                    height: 60,
                    width: 60,
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Innvestorly',
                    style: TextStyle(
                      fontSize: 38,
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              // Phone Number Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: _isPhoneFocused ? Color(0xFFADD8E6) : Colors.white,
                    width: 2.0,
                  ),
                ),
                child: TextField(
                  focusNode: _phoneFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(
                      color: Color(0xFFA0A0A0),
                      fontFamily: 'OpenSans',
                    ),
                    prefixIcon: Icon(
                      Icons.phone_android,
                      color: Color(0xFFA0A0A0),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
              SizedBox(height: 20),
              // User App Code Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: _isAppCodeFocused ? Color(0xFFADD8E6) : Colors.white,
                    width: 2.0,
                  ),
                ),
                child: TextField(
                  focusNode: _appCodeFocusNode,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'User App Code',
                    hintStyle: TextStyle(
                      color: Color(0xFFA0A0A0),
                      fontFamily: 'OpenSans',
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Color(0xFFA0A0A0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Color(0xFFA0A0A0),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0xFF3AB7BF)),
                    elevation: WidgetStatePropertyAll(0.0),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 16.0),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'OpenSans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Forgot App Code Link
              TextButton(
                onPressed: () {},
                child: Text(
                  'FORGOT APP CODE',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    color: Color(0xFF66CCDD),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Spacer(),
              // Copyright
              Text(
                '©2025 Innvestorly. All rights reserved.',
                style: TextStyle(
                  fontSize: 10.0,
                  fontFamily: 'OpenSans',
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

