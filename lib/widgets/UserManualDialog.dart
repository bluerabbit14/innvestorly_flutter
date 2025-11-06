import 'package:flutter/material.dart';

// User Manual Dialog Widget
class UserManualDialog extends StatelessWidget {
  const UserManualDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: EdgeInsets.all(24.0),
        constraints: BoxConstraints(maxWidth: 350),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Manual',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.close, color: Color(0xFF2C3E50)),
                  //   onPressed: () {
                  //     Navigator.of(context).pop();
                  //   },
                  //   padding: EdgeInsets.zero,
                  //   constraints: BoxConstraints(),
                  // ),
                ],
              ),
              SizedBox(height: 20),
              // Face ID Section
              InfoSection(
                icon: Icons.face,
                title: 'Face Id Authorize',
                description: 'Use your device\'s facial recognition feature to securely authenticate. Make sure you have Face ID enabled on your device and your face is clearly visible.',
              ),
              SizedBox(height: 16),
              // Fingerprint Section
              InfoSection(
                icon: Icons.fingerprint,
                title: 'Finger Print Authorize',
                description: 'Use your registered fingerprint to authenticate. Place your registered finger on the fingerprint sensor for quick and secure access.',
              ),
              SizedBox(height: 16),
              // MPIN Section
              InfoSection(
                icon: Icons.grid_4x4,
                title: 'Set MPIN',
                description: 'Create a 4-digit Master PIN for authentication. Choose a memorable but secure PIN that you can easily recall. This PIN will be required for future logins.',
              ),
              SizedBox(height: 20),
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0xFF3AB7BF)),
                    elevation: WidgetStatePropertyAll(0.0),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 14.0),
                    ),
                  ),
                  child: Text(
                    'Got it',
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
    );
  }
}

// Info Section Widget for Dialog
class InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const InfoSection({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFFE0F2F7),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            icon,
            color: Color(0xFF3AB7BF),
            size: 24,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'OpenSans',
                ),
              ),
              SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontFamily: 'OpenSans',
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

