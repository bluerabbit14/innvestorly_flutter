import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Forgotpasswordpage extends StatefulWidget {
  const Forgotpasswordpage({super.key});

  @override
  State<Forgotpasswordpage> createState() => _ForgotpasswordpageState();
}

class _ForgotpasswordpageState extends State<Forgotpasswordpage> {
  // UI State
  bool _isLoading = false;
  
  // Focus Nodes
  final FocusNode _emailFocusNode = FocusNode();
  bool _isEmailFocused = false;
  
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  
  // API Configuration
  static const String _apiUrl = 'https://dailyrevue.argosstaging.com/api/authenticate/forgot-password';

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
    _emailController.dispose();
    super.dispose();
  }

  /// Validates input fields
  bool _validateInputs() {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog(
        title: 'Validation Error',
        message: 'Please enter your email address.',
      );
      return false;
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      _showErrorDialog(
        title: 'Validation Error',
        message: 'Please enter a valid email address.',
      );
      return false;
    }

    return true;
  }

  /// Makes API call to send forgot password email
  Future<void> _sendForgotPasswordRequest() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String email = _emailController.text.trim();

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'email': email,
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - show success message
        if (mounted) {
          _showSuccessDialog(
            title: 'Email Sent',
            message: 'A password reset link has been sent to your email address. Please check your inbox.',
          );
        }
      } else {
        // Handle error response
        String errorMessage = 'Failed to send reset email. Please try again.';
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
            title: 'Request Failed',
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

  /// Shows success dialog
  void _showSuccessDialog({required String title, required String message}) {
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
                // Navigate back to login page
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

  /// Handles submit button press
  void _handleSubmit() {
    _sendForgotPasswordRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Forgot Password',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 130.0),
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Color(0xFF2C3E50),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Reset App Code',
                    style: TextStyle(
                      fontSize: 25,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Color(0xff2C3E50),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'OpenSans',
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
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
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
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
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
                  Spacer(),
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFF265984)
                      : Color(0xFF3AB7BF),
                  size: 80.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
