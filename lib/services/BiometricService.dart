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
      
      print('Biometric authentication - isDeviceSupported: $isDeviceSupported, canCheckBiometrics: $canCheckBiometrics');
      
      // If device is not supported at all, return false
      if (!isDeviceSupported && !canCheckBiometrics) {
        print('Biometric authentication: Device not supported');
        return false;
      }

      // Check available biometrics before attempting authentication
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      print('Biometric authentication - availableBiometrics: $availableBiometrics');
      
      // Only block if we have no biometrics AND device is not supported
      // If device is supported, we should still try (some devices return empty list but still work)
      if (availableBiometrics.isEmpty) {
        // If device is supported or can check biometrics, still try authentication
        // (some devices/emulators have biometrics but return empty list)
        if (!isDeviceSupported && !canCheckBiometrics) {
          print('Biometric authentication: No biometrics available and device not supported');
          return false;
        } else {
          print('Biometric authentication: Empty biometric list but device is supported, attempting anyway');
        }
      }

      // Attempt authentication
      // Use biometricOnly: true to ensure fingerprint/face authentication (not PIN/password)
      print('Biometric authentication: Attempting authentication with biometricOnly: true...');
      
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true, // Force biometric authentication (fingerprint/face only, no PIN/password fallback)
        ),
      );

      print('Biometric authentication result: $didAuthenticate');
      return didAuthenticate;
    } on PlatformException catch (e) {
      // Handle platform-specific errors with detailed logging
      print('Biometric authentication PlatformException:');
      print('  Code: ${e.code}');
      print('  Message: ${e.message}');
      print('  Details: ${e.details}');
      
      // Common error codes from local_auth:
      // - NotAvailable: Biometric hardware not available
      // - NotEnrolled: No biometrics enrolled
      // - LockedOut: Too many failed attempts, temporarily locked
      // - PermanentlyLockedOut: Too many failed attempts, permanently locked
      // - UserCancel: User cancelled the authentication
      // - AppCancel: App cancelled the authentication
      // - InvalidContext: Invalid context
      // - NotInteractive: Not interactive
      
      if (e.code == 'NotAvailable') {
        print('Biometric hardware is not available');
      } else if (e.code == 'NotEnrolled') {
        print('No biometrics are enrolled on the device');
      } else if (e.code == 'LockedOut') {
        print('Biometric authentication is temporarily locked due to too many failed attempts');
      } else if (e.code == 'PermanentlyLockedOut') {
        print('Biometric authentication is permanently locked');
      } else if (e.code == 'UserCancel' || e.code == 'AppCancel') {
        print('User or app cancelled the authentication');
        // User cancellation is not really a failure, but we return false anyway
        // as the authentication didn't complete
      } else if (e.code == 'InvalidContext') {
        print('Invalid context for biometric authentication');
      } else if (e.code == 'NotInteractive') {
        print('Biometric authentication is not interactive');
      }
      
      return false;
    } catch (e, stackTrace) {
      print('Biometric authentication error: $e');
      print('Stack trace: $stackTrace');
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

  /// Get detailed authentication result with error information
  /// Returns a map with 'success' (bool) and 'error' (String?) keys
  static Future<Map<String, dynamic>> authenticateWithDetails({
    String reason = 'Please authenticate to continue',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Check device support first
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      
      if (!isDeviceSupported && !canCheckBiometrics) {
        return {
          'success': false,
          'error': 'Device not supported',
          'errorCode': 'NotSupported',
        };
      }

      // Check available biometrics
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty && !isDeviceSupported && !canCheckBiometrics) {
        return {
          'success': false,
          'error': 'No biometrics available',
          'errorCode': 'NotEnrolled',
        };
      }

      // Attempt authentication with biometricOnly: true for fingerprint/face
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true, // Force biometric authentication (fingerprint/face only)
        ),
      );

      if (didAuthenticate) {
        return {'success': true, 'error': null, 'errorCode': null};
      } else {
        return {
          'success': false,
          'error': 'Authentication failed or cancelled',
          'errorCode': 'Failed',
        };
      }
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.message ?? 'Unknown error',
        'errorCode': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'errorCode': 'Unknown',
      };
    }
  }

  /// Diagnostic method to check biometric status
  /// Returns detailed information about biometric availability
  static Future<Map<String, dynamic>> getDiagnostics() async {
    try {
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      
      return {
        'isDeviceSupported': isDeviceSupported,
        'canCheckBiometrics': canCheckBiometrics,
        'availableBiometrics': availableBiometrics.map((e) => e.toString()).toList(),
        'hasBiometrics': availableBiometrics.isNotEmpty,
        'status': (isDeviceSupported || canCheckBiometrics) && availableBiometrics.isNotEmpty
            ? 'Available'
            : (isDeviceSupported || canCheckBiometrics)
                ? 'Device supported but no biometrics enrolled'
                : 'Not available',
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'status': 'Error checking status',
      };
    }
  }
}

