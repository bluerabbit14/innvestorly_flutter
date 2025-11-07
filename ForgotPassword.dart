import 'package:flutter/material.dart';

class ForgotpasswordPage extends StatefulWidget {
  const ForgotpasswordPage({super.key});

  @override
  State<ForgotpasswordPage> createState() => _ForgotpasswordPageState();
}

class _ForgotpasswordPageState extends State<ForgotpasswordPage> {
  final FocusNode _emailFocusNode = FocusNode();
  bool _isEmailFocused = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
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
              Text('Reset App Code',style:
                    TextStyle(
                      fontSize: 25, color: Color(0xff2C3E50),
                      fontWeight: FontWeight.w600, fontFamily: 'OpenSans'
                    ),
              ),
              SizedBox(height: 40),
              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: _isEmailFocused ? Color(0xFFADD8E6) : Colors.white,
                    width: 2.0,
                  ),
                ),
                child: TextField(
                  focusNode: _emailFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Enter Email Address',
                    hintStyle: TextStyle(
                      color: Color(0xFFA0A0A0),
                      fontFamily: 'OpenSans',
                    ),
                    prefixIcon: Icon(
                      Icons.email,
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
                    'Submit',
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
              // Back to Login Link
              TextButton(
                onPressed: () {},
                child: Text(
                  'BACK TO LOGIN',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    color: Color(0xFF66CCDD),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}