import 'package:shared_preferences/shared_preferences.dart';
import 'package:innvestorly_flutter/services/ThemeService.dart';

class AuthService {
  static const String _jwtTokenKey = 'jwt_token';
  static const String _isUserLoggedInKey = 'is_user_logged_in';

  /// Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isUserLoggedInKey) ?? false;
      final token = prefs.getString(_jwtTokenKey);
      
      // User is logged in only if both flag is true and token exists
      return isLoggedIn && token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get stored JWT token
  static Future<String?> getJwtToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_jwtTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Save JWT token and set login flag
  static Future<void> saveJwtToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_jwtTokenKey, token);
      await prefs.setBool(_isUserLoggedInKey, true);
    } catch (e) {
      rethrow;
    }
  }

  /// Clear JWT token and login flag (logout)
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_jwtTokenKey);
      await prefs.setBool(_isUserLoggedInKey, false);
      // Reset theme to default (light) on logout
      await ThemeService.resetTheme();
    } catch (e) {
      rethrow;
    }
  }

  /// Set login flag to true (after successful login)
  static Future<void> setUserLoggedIn(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isUserLoggedInKey, value);
    } catch (e) {
      rethrow;
    }
  }

  /// Get authentication headers with JWT token
  /// Returns a Map with 'Authorization' header containing the Bearer token
  /// Returns empty map if token is not available
  static Future<Map<String, String>> getAuthHeaders() async {
    try {
      final token = await getJwtToken();
      if (token != null && token.isNotEmpty) {
        return {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };
      }
      return {'Content-Type': 'application/json'};
    } catch (e) {
      return {'Content-Type': 'application/json'};
    }
  }

  // MPIN related methods
  static const String _mpinKey = 'mpin';
  static const String _isMPINSetKey = 'is_mpin_set';

  // Biometric authentication related methods
  static const String _isBiometricEnabledKey = 'is_biometric_enabled';

  /// Check if MPIN is set
  static Future<bool> isMPINSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isMPINSetKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get stored MPIN
  static Future<String?> getMPIN() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_mpinKey);
    } catch (e) {
      return null;
    }
  }

  /// Save MPIN and set flag
  static Future<void> saveMPIN(String mpin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_mpinKey, mpin);
      await prefs.setBool(_isMPINSetKey, true);
    } catch (e) {
      rethrow;
    }
  }

  /// Clear MPIN and flag
  static Future<void> clearMPIN() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_mpinKey);
      await prefs.setBool(_isMPINSetKey, false);
    } catch (e) {
      rethrow;
    }
  }

  /// Verify MPIN
  static Future<bool> verifyMPIN(String mpin) async {
    try {
      final storedMPIN = await getMPIN();
      return storedMPIN != null && storedMPIN == mpin;
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric authentication is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isBiometricEnabledKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Enable biometric authentication
  static Future<void> enableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isBiometricEnabledKey, true);
    } catch (e) {
      rethrow;
    }
  }

  /// Disable biometric authentication
  static Future<void> disableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isBiometricEnabledKey, false);
    } catch (e) {
      rethrow;
    }
  }

  /// Reset all app data (logout, clear MPIN, clear all flags)
  static Future<void> resetAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear authentication data
      await prefs.remove(_jwtTokenKey);
      await prefs.setBool(_isUserLoggedInKey, false);
      // Clear MPIN data
      await prefs.remove(_mpinKey);
      await prefs.setBool(_isMPINSetKey, false);
      // Clear biometric preference
      await prefs.setBool(_isBiometricEnabledKey, false);
    } catch (e) {
      rethrow;
    }
  }

}

