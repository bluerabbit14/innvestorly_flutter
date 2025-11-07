import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe8f4fd),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo and title
              Row(
                children: [
                  Image.asset('assets/innvestorly_logo.png', height: 45, width: 45,),
                  SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              
              // Main white container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // First Container - Profile Section
                        _buildProfileContainer(),
                        SizedBox(height: 16),
                        
                        // Second Container - Set Authentication
                        _buildAuthContainer(),
                        SizedBox(height: 16),
                        
                        // Third Container - App Theme
                        _buildThemeContainer(),
                        
                        Spacer(),
                        
                        // Log Out Button
                        _buildLogoutButton(),
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
        onTap: () {
          // Navigate to profile details
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
                  color: Color(0xFFE0F2F7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF3AB7BF),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  color: Color(0xFF3AB7BF),
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Loading...',
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
          // Navigate to authentication settings
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
                Icons.light_mode,
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
              onChanged: (value) {
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle logout
        },
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
