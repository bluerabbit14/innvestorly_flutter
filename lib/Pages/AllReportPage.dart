import 'package:flutter/material.dart';
import 'OccupancyPage.dart';
import 'YoYReportPage.dart';

class AllReportPage extends StatefulWidget {
  const AllReportPage({super.key});

  @override
  State<AllReportPage> createState() => _AllReportPageState();
}


class _AllReportPageState extends State<AllReportPage> {
  // List of report items
  List<Map<String, dynamic>> get _reportItems => [
    {
      'icon': Icons.bed,
      'title': 'Occupancy',
      'subtitle': 'Tap to view Occupancy Data',
    },
    {
      'icon': Icons.bar_chart,
      'title': 'YoY Report',
      'subtitle': 'Tap to view YoY Data',
    },
  ];

  void _handleReportTap(int index) {
    switch (index) {
      case 0: // Occupancy
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OccupancyPage()),
        );
        break;
      case 1: // YoY Report
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => YoYReportPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logo and Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Row(
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
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onBackground,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ],
              ),
            ),
            
            // ListView for Report Items
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: _reportItems.length,
                itemBuilder: (context, index) {
                  final item = _reportItems[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: _buildReportContainer(
                      icon: item['icon'] as IconData,
                      title: item['title'] as String,
                      subtitle: item['subtitle'] as String,
                      onTap: () => _handleReportTap(index),
                    ),
                  );
                },
              ),
            ),
          ],
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
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
                color: isDark 
                    ? theme.colorScheme.surface.withOpacity(0.5)
                    : Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 28,
                color: theme.colorScheme.onSurface,
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
                      color: theme.colorScheme.onSurface,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark 
                          ? theme.colorScheme.onSurface.withOpacity(0.7)
                          : Colors.grey[600],
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(
              Icons.chevron_right,
              color: isDark 
                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                  : Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
