import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:innvestorly_flutter/services/AuthService.dart';

class ProfileService {
  static const String _apiUrl = 'https://dailyrevue.argosstaging.com/api/user/profile';

  /// Fetches user profile data from the API
  /// Returns a Map containing user data or throws an exception on error
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      // Get authentication headers with JWT token
      final headers = await AuthService.getAuthHeaders();

      // Make API call
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else {
          throw Exception('Invalid response format from server.');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        // Try to extract error message from response
        String errorMessage = 'Failed to fetch profile data.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network.');
      }
      rethrow;
    }
  }
}

