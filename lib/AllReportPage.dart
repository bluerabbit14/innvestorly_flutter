import 'package:flutter/material.dart';

class AllReportPage extends StatefulWidget {
  const AllReportPage({super.key});

  @override
  State<AllReportPage> createState() => _AllReportPageState();
}

class _AllReportPageState extends State<AllReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe8f4fd),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
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
                    'Reports Dashboard',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              
              // Occupancy Report Container
              _buildReportContainer(
                icon: Icons.bed,
                title: 'Occupancy',
                subtitle: 'Tap to view Occupancy Data',
                onTap: () {
                  // Navigate to Occupancy page
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => OccupancyPage()));
                  print('Occupancy tapped');
                },
              ),
              SizedBox(height: 20),
              
              // YoY Report Container
              _buildReportContainer(
                icon: Icons.bar_chart,
                title: 'YoY Report',
                subtitle: 'Tap to view YoY Data',
                onTap: () {
                  // Navigate to YoY Report page
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => YoYReportPage()));
                  print('YoY Report tapped');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContainer({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 28,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                      fontFamily: 'OpenSans',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
