import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:innvestorly_flutter/services/ProfileService.dart';
import 'package:innvestorly_flutter/services/HardCodedDataService.dart';

class EditProfilePage extends StatefulWidget {
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final File? profileImage;

  const EditProfilePage({
    super.key,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profileImage,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaved = false; // Track if profile has been saved
  static const String _profileImagePathKey = 'profile_image_path';
  
  // Store initial values to detect changes
  String _initialFullName = '';
  String _initialEmail = '';
  String _initialPhoneNumber = '';
  File? _initialProfileImage;


  @override
  void initState() {
    super.initState();
    // Set initial values from passed data
    if (widget.fullName != null) {
      _fullNameController.text = widget.fullName!;
      _initialFullName = widget.fullName!;
    }
    if (widget.email != null) {
      _emailController.text = widget.email!;
      _initialEmail = widget.email!;
    }
    if (widget.phoneNumber != null) {
      _phoneNumberController.text = widget.phoneNumber!;
      _initialPhoneNumber = widget.phoneNumber!;
    }
    if (widget.profileImage != null) {
      _profileImage = widget.profileImage;
      _initialProfileImage = widget.profileImage;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  /// Shows image source selection dialog
  Future<void> _showImageSourceDialog() async {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text(
            'Select Image Source',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Color(0xFF3AB7BF)),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(0xFF3AB7BF)),
                title: Text(
                  'Gallery',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Picks image from selected source
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (image != null) {
        final imageFile = File(image.path);
        setState(() {
          _profileImage = imageFile;
        });
        // Save image path to preferences
        await _saveProfileImagePath(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image: ${e.toString()}',
              style: TextStyle(fontFamily: 'OpenSans'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  /// Checks if there are unsaved changes
  bool _hasUnsavedChanges() {
    if (_isSaved) return false;
    
    final currentFullName = _fullNameController.text.trim();
    final currentEmail = _emailController.text.trim();
    final currentPhoneNumber = _phoneNumberController.text.trim();
    
    return currentFullName != _initialFullName ||
           currentEmail != _initialEmail ||
           currentPhoneNumber != _initialPhoneNumber ||
           _profileImage != _initialProfileImage;
  }

  /// Shows confirmation dialog before exiting with unsaved changes
  Future<bool> _showUnsavedChangesDialog() async {
    final theme = Theme.of(context);
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text(
            'Unsaved Changes',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'You have unsaved changes. Are you sure you want to leave?',
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: theme.colorScheme.onSurface,
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
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Leave',
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
    return shouldExit ?? false;
  }

  /// Splits full name into first and last name
  Map<String, String> _splitFullName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return {'firstName': '', 'lastName': ''};
    }
    
    final parts = trimmed.split(' ');
    if (parts.length == 1) {
      return {'firstName': parts[0], 'lastName': ''};
    } else {
      final firstName = parts[0];
      final lastName = parts.sublist(1).join(' ');
      return {'firstName': firstName, 'lastName': lastName};
    }
  }

  /// Validates and saves profile data using hardcoded data service
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final fullName = _fullNameController.text.trim();
        final email = _emailController.text.trim();
        final phoneNumber = _phoneNumberController.text.trim();
        
        // Check if phone number is being changed (not allowed)
        if (phoneNumber != _initialPhoneNumber) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog(
              title: 'Update Failed',
              message: 'Phone number cannot be changed. Please keep the original phone number.',
            );
            // Reset phone number to original
            _phoneNumberController.text = _initialPhoneNumber;
            return;
          }
        }
        
        // Split full name into first and last name
        final nameParts = _splitFullName(fullName);
        
        // Use hardcoded data service to update profile
        final hardCodedService = HardCodedDataService();
        final response = await hardCodedService.updateProfile(
          firstName: nameParts['firstName'] ?? '',
          lastName: nameParts['lastName'] ?? '',
          email: email,
          phoneNumber: phoneNumber, // This will be ignored by the service
        );

        if (response['success'] == true) {
          String message = response['message'] ?? 'Profile updated successfully';

          if (mounted) {
            setState(() {
              _isLoading = false;
              _isSaved = true;
            });
            
            // Fetch fresh profile data
            try {
              await ProfileService.getUserProfile();
            } catch (e) {
              // Log error but don't block navigation
              print('Error fetching fresh profile data: $e');
            }
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message,
                  style: TextStyle(fontFamily: 'OpenSans'),
                ),
                backgroundColor: Color(0xFF3AB7BF),
              ),
            );
            
            // Pop twice to go back to Settings page (EditProfile -> Profile -> Settings)
            Navigator.pop(context); // Pop EditProfilePage
            Navigator.pop(context); // Pop ProfilePage to return to Settings
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog(
              title: 'Update Failed',
              message: response['message'] ?? 'Failed to update profile. Please try again.',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          String errorMessage = e.toString().replaceFirst('Exception: ', '');
          if (errorMessage.isEmpty) {
            errorMessage = 'An error occurred. Please try again.';
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

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        
        if (_hasUnsavedChanges()) {
          final shouldPop = await _showUnsavedChangesDialog();
          if (shouldPop && mounted) {
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
                onPressed: () async {
                  if (_hasUnsavedChanges()) {
                    final shouldPop = await _showUnsavedChangesDialog();
                    if (shouldPop && mounted) {
                      Navigator.pop(context);
                    }
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text(
                'Edit Profile',
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
                      // Profile Photo Section
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
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
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF3AB7BF),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _showImageSourceDialog,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: _showImageSourceDialog,
                        child: Text(
                          'Change Photo',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            color: Color(0xFF3AB7BF),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                      // Personal Information Section
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onBackground,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                SizedBox(height: 16),

                // Full Name Field
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  placeholder: 'Enter your full name',
                  icon: Icons.person_outline,
                  validator: _validateFullName,
                ),
                SizedBox(height: 16),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  placeholder: 'Enter your email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: 16),

                // Phone Number Field (Read-only, cannot be changed)
                _buildTextField(
                  controller: _phoneNumberController,
                  label: 'Phone Number',
                  placeholder: 'Enter your phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhoneNumber,
                  enabled: false, // Disable editing
                ),
                      SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
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
                            'Save Changes',
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
        },
      ),
    ); // closes PopScope
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool enabled = true,
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
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        style: TextStyle(
          fontFamily: 'OpenSans',
          color: enabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.6),
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
        ),
      ),
    );
  }
}

