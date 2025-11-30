import 'package:innvestorly_flutter/services/HardCodedDataService.dart';

class ProfileService {
  /// Fetches user profile data from hardcoded data
  /// Returns a Map containing user data or throws an exception on error
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final hardCodedService = HardCodedDataService();
      return await hardCodedService.getUserProfile();
    } catch (e) {
      throw Exception('Failed to fetch profile data: ${e.toString()}');
    }
  }
}

