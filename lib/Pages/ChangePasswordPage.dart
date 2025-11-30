import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:innvestorly_flutter/services/AuthService.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // API Configuration
  static const String _apiUrl = 'https://dailyrevue.argosstaging.com/api/user/change-password';

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String currentPassword = _currentPasswordController.text.trim();
        String newPassword = _newPasswordController.text.trim();
        String confirmPassword = _confirmPasswordController.text.trim();

        // Get authentication headers with JWT token
        final headers = await AuthService.getAuthHeaders();

        // Prepare request body
        final Map<String, dynamic> requestBody = {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        };

        // Make API call
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: headers,
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
          String message = 'Password changed successfully';
          
          if (responseData is Map<String, dynamic> && responseData['message'] != null) {
            message = responseData['message'];
          }

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            
            // Clear authentication data (logout user)
            await AuthService.clearAuthData();
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$message Please login with your new password.',
                  style: TextStyle(fontFamily: 'OpenSans'),
                ),
                backgroundColor: Color(0xFF3AB7BF),
                duration: Duration(seconds: 3),
              ),
            );
            
            // Navigate to LoginPage and clear navigation stack
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/LoginPage',
              (route) => false, // Remove all previous routes
            );
          }
        } else if (response.statusCode == 401) {
          // Unauthorized - token expired or invalid
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog(
              title: 'Authentication Error',
              message: 'Your session has expired. Please log in again.',
            );
          }
        } else {
          // Handle error response
          String errorMessage = 'Failed to change password. Please try again.';
          try {
            final errorData = jsonDecode(response.body);
            if (errorData is Map<String, dynamic>) {
              if (errorData['errors'] != null && errorData['errors'] is List) {
                List errors = errorData['errors'];
                if (errors.isNotEmpty && errors[0] is Map) {
                  errorMessage = errors[0]['message'] ?? errorMessage;
                }
              } else if (errorData['message'] != null) {
                errorMessage = errorData['message'];
              }
            }
          } catch (e) {
            // Use default error message
          }

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog(
              title: 'Change Password Failed',
              message: errorMessage,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          String errorMessage = 'An error occurred. Please try again.';
          String errorString = e.toString().toLowerCase();
          
          if (errorString.contains('timeout')) {
            errorMessage = 'Request timeout. Please check your internet connection.';
          } else if (errorString.contains('socketexception') || 
                     errorString.contains('failed host lookup') ||
                     errorString.contains('network is unreachable') ||
                     errorString.contains('no address associated with hostname')) {
            errorMessage = 'No internet connection. Please check your network.';
          } else if (errorString.contains('handshakeexception') ||
                     errorString.contains('tlsexception') ||
                     errorString.contains('certificateexception') ||
                     errorString.contains('certificate verify failed')) {
            errorMessage = 'SSL certificate error. Please check your network security settings.';
          } else if (errorString.contains('connection refused') ||
                     errorString.contains('connection reset')) {
            errorMessage = 'Connection error. Please try again later.';
          }
          
          _showErrorDialog(
            title: 'Error',
            message: errorMessage,
          );
        }
      }
    }
  }

  /// Shows error dialog
  void _showErrorDialog({required String title, required String message}) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: theme.colorScheme.onSurface,
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

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your current password';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onBackground,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Password Field
                SizedBox(height: 8),
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                  placeholder: 'Enter your current password',
                  obscureText: _obscureCurrentPassword,
                  validator: _validateCurrentPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
                // New Password Field
                SizedBox(height: 8),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  placeholder: 'Enter your new password',
                  obscureText: _obscureNewPassword,
                  validator: _validateNewPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                SizedBox(height: 8),

                // Confirm Password Field
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  placeholder: 'Confirm your new password',
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),

                Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'Password must be at least 8 characters long',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleChangePassword,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Color(0xFF3AB7BF)),
                      elevation: WidgetStatePropertyAll(0.0),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Change Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'OpenSans',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required bool obscureText,
    required String? Function(String?) validator,
    required VoidCallback onToggleVisibility,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          fontFamily: 'OpenSans',
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          hintStyle: TextStyle(
            fontFamily: 'OpenSans',
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          ),
          labelStyle: TextStyle(
            fontFamily: 'OpenSans',
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Color(0xFF3AB7BF),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            onPressed: onToggleVisibility,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

