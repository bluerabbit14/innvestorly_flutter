import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device is compatible with biometric authentication
  static Future<bool> isDeviceCompatible() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric authentication is available on the device
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      
      print('Biometric check - canCheckBiometrics: $canCheckBiometrics');
      print('Biometric check - isDeviceSupported: $isDeviceSupported');
      print('Biometric check - availableBiometrics: $availableBiometrics');
      
      // On some devices/emulators, getAvailableBiometrics might return empty
      // even when biometrics are available, so we check device support as well
      if (availableBiometrics.isNotEmpty) {
        return true;
      }
      
      // If no specific biometrics found but device is supported, still return true
      // This handles cases where emulators have biometrics configured but
      // getAvailableBiometrics doesn't return them
      if (isDeviceSupported || canCheckBiometrics) {
        return true;
      }
      
      return false;
    } catch (e) {
      print('Biometric availability check error: $e');
      return false;
    }
  }

  /// Get available biometric types (fingerprint, face, etc.)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Get a user-friendly name for the biometric type
  static String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face Recognition';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Authentication';
      case BiometricType.weak:
        return 'Weak Authentication';
      default:
        return 'Biometric';
    }
  }

  /// Authenticate using biometrics
  /// Returns true if authentication is successful, false otherwise
  static Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Check device support first
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      
      if (!isDeviceSupported && !canCheckBiometrics) {
        print('Biometric authentication: Device not supported');
        return false;
      }

      // Attempt authentication
      // Note: On emulators, biometricOnly might need to be false
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow device credentials as fallback (needed for some emulators)
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      // Handle platform-specific errors
      print('Biometric authentication error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  /// Stop authentication (if in progress)
  static Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (e) {
      print('Error stopping authentication: $e');
    }
  }
}

