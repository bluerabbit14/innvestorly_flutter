import 'package:flutter/material.dart';
import 'package:innvestorly_flutter/Pages/ForgotPasswordPage.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe8f4fd),
      body:Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20.0,
          children: [
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children: [
                Image.asset('assets/innvestorly_logo.png', height: 45, width: 45),
                Text('Innvestorly', style: TextStyle(fontSize: 30,
                    fontFamily: 'OpenSans',
                    color: Color(0xff265984),
                    fontWeight: FontWeight.w600))
              ],
            ),
            SizedBox(
              width: double.infinity,
              child:  ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0xFF3AB7BF)),
                    elevation: WidgetStatePropertyAll(0.0),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0))),
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 16.0)),
                  ),
                  child: Text('Login', style: TextStyle(fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                      fontSize: 18,color: Colors.white)),
            )
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context,'/ForgotPasswordPage');
                },
                child: Text('Forgot Password')
            ),
            Spacer(),
            Text('©2025 Innvestorly. All right reserved.')
          ],
        ),
      )
    );
  }
}
