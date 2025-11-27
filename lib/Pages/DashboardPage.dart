import 'package:flutter/material.dart';
import 'SettingPage.dart';
import 'RevenuePage.dart';
import 'AllReportPage.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  // List of tab pages - each tab will have its own top widget and content
  final List<TabPage> _tabs = [
    TabPage(
      title: 'Home',
      icon: Icons.home,
      content: RevenuePage(),
    ),
    TabPage(
      title: 'Reports',
      icon: Icons.bar_chart_outlined,
      content: AllReportPage(),
    ),
    TabPage(
      title: 'Setting',
      icon: Icons.settings,
      content: SettingPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F2F7),
      body: Column(
        children: [

          // Content area
          Expanded(
            child: _tabs[_currentIndex].content,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF2C3E50),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: _tabs.map((tab) {
          return BottomNavigationBarItem(
            icon: Icon(tab.icon),
            label: tab.title,
          );
        }).toList(),
      ),
    );
  }
}

// Model class to hold tab information
class TabPage {
  final String title;
  final IconData icon;
  final Widget content;

  TabPage({
    required this.title,
    required this.icon,
    required this.content,
  });
}