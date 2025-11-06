
import 'package:flutter/material.dart';

class RevenuePage extends StatefulWidget {
  const RevenuePage({super.key});

  @override
  State<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 20.0, vertical: 50.0),
        child: Column(
          children: [
            Image.asset('assets/innvestorly_logo.png', height: 50, width: 50),
            Container(
              color: Colors.white,

            ),
            Container(
              color: Colors.white,

            ),
          ],
        ),
    );
  }
}
