import 'package:flutter/material.dart';

class Forgotpasswordpage extends StatefulWidget {
  const Forgotpasswordpage({super.key});

  @override
  State<Forgotpasswordpage> createState() => _ForgotpasswordpageState();
}

class _ForgotpasswordpageState extends State<Forgotpasswordpage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
     backgroundColor: Color(0xffe8f4fd),
      appBar:AppBar(
        backgroundColor: Color(0xff53bbd2),
        title: Text('Forgot Password', style: TextStyle(color: Colors.white, fontFamily: 'OpenSans')),
        centerTitle: false,
      ) ,
    )
    );
  }
}
