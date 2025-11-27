import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // UI State
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  // Focus Nodes
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _appCodeFocusNode = FocusNode();
  bool _isPhoneFocused = false;
  bool _isAppCodeFocused = false;
  
  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // API Configuration
  static const String _apiUrl = 'https://dailyrevue.argosstaging.com/api/authenticate/signin';
  static const String _jwtTokenKey = 'jwt_token';

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
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Formats phone number from 10 digits to (XXX) XXX-XXXX format
  String _formatPhoneNumber(String phone) {
    if (phone.length != 10) return phone;
    return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
  }

  /// Validates input fields
  bool _validateInputs() {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showErrorDialog(
        title: 'Validation Error',
        message: phone.isEmpty && password.isEmpty
            ? 'Please enter both phone number and password.'
            : phone.isEmpty
                ? 'Please enter your phone number.'
                : 'Please enter your password.',
      );
      return false;
    }
    return true;
  }

  /// Makes API call to authenticate user
  Future<void> _authenticateUser() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String phone = _phoneController.text.trim();
      String password = _passwordController.text.trim();
      String formattedPhone = _formatPhoneNumber(phone);

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'phoneNumber': formattedPhone,
        'password': password,
      };

      // Make API call
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Extract JWT token from response
        String? jwtToken;
        if (responseData is Map<String, dynamic>) {
          jwtToken = responseData['token'] ?? 
                     responseData['jwtToken'] ?? 
                     responseData['accessToken'] ??
                     responseData['jwt'];
        }

        if (jwtToken != null && jwtToken.isNotEmpty) {
          // Store JWT token
          await _saveJwtToken(jwtToken);
          
          // Navigate to dashboard
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/DashboardPage');
          }
        } else {
          // Token not found in response
          if (mounted) {
            _showErrorDialog(
              title: 'Authentication Error',
              message: 'Invalid response from server. Please try again.',
            );
          }
        }
      } else {
        // Handle error response
        String errorMessage = 'Login failed. Please check your credentials.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Use default error message
        }

        if (mounted) {
          _showErrorDialog(
            title: 'Login Failed',
            message: errorMessage,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'An error occurred. Please try again.';
        if (e.toString().contains('timeout')) {
          errorMessage = 'Request timeout. Please check your internet connection.';
        } else if (e.toString().contains('SocketException') || 
                   e.toString().contains('Failed host lookup')) {
          errorMessage = 'No internet connection. Please check your network.';
        }
        
        _showErrorDialog(
          title: 'Error',
          message: errorMessage,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Saves JWT token to local storage
  Future<void> _saveJwtToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_jwtTokenKey, token);
    } catch (e) {
      // Handle storage error silently or log it
      debugPrint('Error saving JWT token: $e');
    }
  }

  /// Shows error dialog
  void _showErrorDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'OpenSans',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Color(0xFF3AB7BF),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Handles login button press
  void _handleLogin() {
    _authenticateUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F2F7),
      body: Stack(
        children: [
          SafeArea(
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
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: '',
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
                  controller: _passwordController,
                  focusNode: _appCodeFocusNode,
                  obscureText: _obscurePassword,
                  maxLength: 12,
                  decoration: InputDecoration(
                    counterText: '',
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
                  onPressed: _isLoading ? null : _handleLogin,
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
                  child: const Text(
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
              SizedBox(height: 14),
              // Forgot App Code Link
              TextButton(
                onPressed: () {
                        Navigator.pushNamed(context,'/ForgotPasswordPage');
                },
                child: Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    color: Color(0xFF66CCDD),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Spacer(),
              // Copyright
              Text(
                '©2025 Innvestorly. All rights reserved.',
                style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'OpenSans',
                  color: Color(0xFF333333),
                ),
              ),
                ],
              ),
            ),
          ),
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Center(
                child: SpinKitCubeGrid(
                  color: Color(0xFF3AB7BF),
                  size: 80.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

