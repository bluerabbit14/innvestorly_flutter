import 'package:flutter/material.dart';
import 'widgets/UserManualDialog.dart';

class MandatoryPinpage extends StatefulWidget {
  const MandatoryPinpage({super.key});

  @override
  State<MandatoryPinpage> createState() => _MandatoryPinpageState();
}

class _MandatoryPinpageState extends State<MandatoryPinpage> {
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UserManualDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F2F7),
      body: SafeArea(
        child: Stack(
          children: [
            // Background logo with lighter opacity
            Center(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/innvestorly_logo.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Main content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                        // Info icon at top right
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              _showInfoDialog();
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.info_outline,
                                color: Color(0xFF2C3E50),
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Face Id Authorize Card
                        GestureDetector(
                          onTap: () {
                            // Handle Face ID tap
                            print('Face ID Authorize tapped');
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: Color(0xFFADD8E6),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Color(0xFF2C3E50),
                                      width: 2.0,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    Icons.face,
                                    color: Color(0xFF2C3E50),
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Face Id Authorize',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF2C3E50),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'OpenSans',
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'use your face',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFA0A0A0),
                                          fontFamily: 'OpenSans',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Finger Print Authorize Card
                        GestureDetector(
                          onTap: () {
                            // Handle Fingerprint tap
                            print('Finger Print Authorize tapped');
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: Color(0xFFADD8E6),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Color(0xFF2C3E50),
                                      width: 2.0,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    Icons.fingerprint,
                                    color: Color(0xFF2C3E50),
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Finger Print Authorize',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF2C3E50),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'OpenSans',
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'use your finger',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFA0A0A0),
                                          fontFamily: 'OpenSans',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Set MPIN Card
                        GestureDetector(
                          onTap: () {
                            // Handle Set MPIN tap
                            print('Set MPIN tapped');
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: Color(0xFFADD8E6),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Color(0xFF2C3E50),
                                      width: 2.0,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    Icons.grid_4x4,
                                    color: Color(0xFF2C3E50),
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Set MPIN',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF2C3E50),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'OpenSans',
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'use a set 4 digit code',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFA0A0A0),
                                          fontFamily: 'OpenSans',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
