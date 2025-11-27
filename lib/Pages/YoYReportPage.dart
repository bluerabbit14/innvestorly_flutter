import 'package:flutter/material.dart';

class YoYReportPage extends StatefulWidget {
  const YoYReportPage({super.key});

  @override
  State<YoYReportPage> createState() => _YoYReportPageState();
}

class _YoYReportPageState extends State<YoYReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F2F7),
      appBar: AppBar(
        backgroundColor: Color(0xffE0F2F7),
        title: Text('YoY Report'),
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

