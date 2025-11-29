import 'package:flutter/material.dart';
import 'package:innvestorly_flutter/services/AuthService.dart';
import 'package:innvestorly_flutter/services/BiometricService.dart';
import 'LoginPage.dart';
import 'DashboardPage.dart';
import 'MPINPage.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingpageState();
}

class _LoadingpageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await AuthService.isUserLoggedIn();
    
    if (mounted) {
      if (isLoggedIn) {
        // Check if biometric is enabled
        final isBiometricEnabled = await AuthService.isBiometricEnabled();
        if (isBiometricEnabled) {
          // Check if biometric is available
          final isBiometricAvailable = await BiometricService.isBiometricAvailable();
          if (isBiometricAvailable) {
            // Authenticate with biometric
            final authenticated = await BiometricService.authenticate(
              reason: 'Please authenticate to access the app',
            );
            
            if (authenticated) {
              // Biometric authentication successful, go to dashboard
              Navigator.pushReplacementNamed(context, '/DashboardPage');
            } else {
              // Biometric authentication failed, show MPIN as fallback if available
              final isMPINSet = await AuthService.isMPINSet();
              if (isMPINSet) {
                Navigator.pushReplacementNamed(context, '/MPINPage');
              } else {
                // No fallback, go to dashboard anyway (or show error)
                Navigator.pushReplacementNamed(context, '/DashboardPage');
              }
            }
          } else {
            // Biometric not available, fallback to MPIN
            final isMPINSet = await AuthService.isMPINSet();
            if (isMPINSet) {
              Navigator.pushReplacementNamed(context, '/MPINPage');
            } else {
              Navigator.pushReplacementNamed(context, '/DashboardPage');
            }
          }
        } else {
          // Biometric not enabled, check if MPIN is set
          final isMPINSet = await AuthService.isMPINSet();
          if (isMPINSet) {
            // Show MPINPage for authentication
            Navigator.pushReplacementNamed(context, '/MPINPage');
          } else {
            // No MPIN set, go directly to dashboard
            Navigator.pushReplacementNamed(context, '/DashboardPage');
          }
        }
      } else {
        Navigator.pushReplacementNamed(context, '/LoginPage');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).brightness == Brightness.dark
              ? Color(0xFF265984)
              : Color(0xFF3AB7BF),
        ),
      ),
    );
  }
}
