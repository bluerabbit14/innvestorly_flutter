import 'package:flutter/material.dart';
import 'ProfilePage.dart';
import 'AuthenticationPage.dart';
import 'package:innvestorly_flutter/services/AuthService.dart';
import 'package:innvestorly_flutter/services/ProfileService.dart';
import 'package:innvestorly_flutter/services/ThemeService.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'LoginPage.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isDarkMode = false;
  bool _isLoading = false;
  String? _firstName;
  String? _lastName;
  String? _phoneNumber;
  String? _email;
  File? _profileImage;
  static const String _profileImagePathKey = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _loadTheme();
    _loadProfileImage();
  }

  Future<void> _loadTheme() async {
    final isDark = await ThemeService.isDarkMode();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  /// Loads profile image path from SharedPreferences
  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString(_profileImagePathKey);
      
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        // Check if file still exists
        if (await file.exists()) {
          setState(() {
            _profileImage = file;
          });
        } else {
          // File doesn't exist, remove from preferences
          await prefs.remove(_profileImagePathKey);
        }
      }
    } catch (e) {
      // Handle error silently or log it
      print('Error loading profile image: $e');
    }
  }

  /// Fetches user profile data from the API
  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileData = await ProfileService.getUserProfile();
      
      if (mounted) {
        setState(() {
          _firstName = profileData['firstName'] as String?;
          _lastName = profileData['lastName'] as String?;
          _phoneNumber = profileData['phoneNumber'] as String?;
          _email = profileData['email'] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error dialog
        _showErrorDialog(
          title: 'Error',
          message: e.toString().replaceFirst('Exception: ', ''),
        );
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
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontFamily: 'OpenSans',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Logo and Title
                  Row(
                    children: [
                      Image.asset(
                        'assets/innvestorly_logo.png',
                        height: 45,
                        width: 45,
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Setting',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color:Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Color(0xFF2C3E50),
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Main white container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // First Container - Profile Section
                          _buildProfileContainer(),
                          SizedBox(height: 16),

                          // Second Container - Set Authentication
                          _buildAuthContainer(),
                          SizedBox(height: 16),

                          // Third Container - App Theme
                          _buildThemeContainer(),

                          SizedBox(height: 24),

                          // Log Out Button
                          _buildLogoutButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Loading overlay
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

  Widget _buildProfileContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () async {
          // Combine first name and last name into full name
          String? fullName;
          if (_firstName != null || _lastName != null) {
            fullName = [(_firstName ?? '').trim(), (_lastName ?? '').trim()]
                .where((name) => name.isNotEmpty)
                .join(' ');
          }
          
          // Navigate to ProfilePage and wait for result
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                fullName: fullName,
                email: _email,
                phoneNumber: _phoneNumber,
              ),
            ),
          );
          
          // Reload profile image when returning from ProfilePage
          _loadProfileImage();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF3AB7BF),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _profileImage != null
                      ? Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.person,
                          color: Color(0xFF3AB7BF),
                          size: 28,
                        ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _firstName != null && _lastName != null
                          ? '$_firstName $_lastName'
                          : 'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _phoneNumber ?? 'Loading...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade700,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuthenticationPage()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.grey.shade700,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Set Authentication',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade700,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.grey.shade700,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'App Theme',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                  fontFamily: 'OpenSans',
                ),
              ),
            ),
            Switch(
              value: _isDarkMode,
              onChanged: (value) async {
                final newMode = value ? ThemeMode.dark : ThemeMode.light;
                await ThemeService.setThemeMode(newMode);
                setState(() {
                  _isDarkMode = value;
                });
              },
              activeColor: Color(0xFF3AB7BF),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles logout functionality
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Log Out',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              fontFamily: 'OpenSans',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Log Out',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Clear auth data (JWT token and login flag)
      await AuthService.clearAuthData();
      
      // Check login status after clearing
      final isLoggedIn = await AuthService.isUserLoggedIn();
      
      // Navigate to LoginPage (since user is now logged out)
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/LoginPage',
          (route) => false, // Remove all previous routes
        );
      }
    }
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.red.shade50),
          elevation: WidgetStatePropertyAll(0.0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: Colors.red.shade300,
                width: 1,
              ),
            ),
          ),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
        child: Text(
          'Log Out',
          style: TextStyle(
            color: Colors.red.shade700,
            fontFamily: 'OpenSans',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}