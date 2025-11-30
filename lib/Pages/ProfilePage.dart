import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'ChangePasswordPage.dart';
import 'EditProfilePage.dart';

class ProfilePage extends StatefulWidget {
  final String? fullName;
  final String? email;
  final String? phoneNumber;

  const ProfilePage({
    super.key,
    this.fullName,
    this.email,
    this.phoneNumber,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  static const String _profileImagePathKey = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    // Set initial values from passed data
    if (widget.fullName != null) {
      _fullNameController.text = widget.fullName!;
    }
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
    if (widget.phoneNumber != null) {
      _phoneNumberController.text = widget.phoneNumber!;
    }
    // Load profile image from preferences
    _loadProfileImage();
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

  /// Saves profile image path to SharedPreferences
  Future<void> _saveProfileImagePath(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImagePathKey, imagePath);
    } catch (e) {
      // Handle error silently or log it
      print('Error saving profile image path: $e');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }


  /// Navigates to change password page
  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(),
      ),
    );
  }

  /// Navigates to edit profile page
  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          fullName: _fullNameController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text,
          profileImage: _profileImage,
        ),
      ),
    ).then((result) {
      // Refresh profile data when returning from EditProfilePage
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          if (result['fullName'] != null) {
            _fullNameController.text = result['fullName'];
          }
          if (result['email'] != null) {
            _emailController.text = result['email'];
          }
          if (result['phoneNumber'] != null) {
            _phoneNumberController.text = result['phoneNumber'];
          }
          if (result['profileImage'] != null) {
            _profileImage = result['profileImage'];
          }
        });
        // Reload profile image from preferences
        _loadProfileImage();
      }
    });
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
          'Profile',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Section
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFF3AB7BF),
                      width: 3,
                    ),
                    color: isDark ? theme.colorScheme.surface : Color(0xFFE0F2F7),
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(
                            _profileImage!,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF3AB7BF),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Credential Details Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToEditProfile,
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3AB7BF),
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Full Name Field
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                placeholder: 'Enter your full name',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 16),

              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                placeholder: 'Enter your email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),

              // Phone Number Field
              _buildTextField(
                controller: _phoneNumberController,
                label: 'Phone Number',
                placeholder: 'Enter your phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 32),

              // Change Password Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: _navigateToChangePassword,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onBackground,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Update your password',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
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
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: false, // Make field read-only
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
            icon,
            color: Color(0xFF3AB7BF),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
