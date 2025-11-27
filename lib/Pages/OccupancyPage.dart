import 'package:flutter/material.dart';

class OccupancyPage extends StatefulWidget {
  const OccupancyPage({super.key});

  @override
  State<OccupancyPage> createState() => _OccupancyPageState();
}

class _OccupancyPageState extends State<OccupancyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F2F7),
      appBar: AppBar(
        backgroundColor: Color(0xffE0F2F7),
        title: Text('Occupancy'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Logo and Title

            ],
          ),
        ),
      ),
    );
  }
}

