import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:innvestorly_flutter/services/AuthService.dart';

class RevenueService {
  static const String _baseUrl = 'https://dailyrevue.argosstaging.com/api/dashboard';

  /// Fetches daily revenue data for the previous day
  /// Returns a List of daily revenue data or throws an exception on error
  static Future<List<Map<String, dynamic>>> getDailyRevenue() async {
    try {
      // Get authentication headers with JWT token
      final headers = await AuthService.getAuthHeaders();

      // Make API call
      final response = await http.get(
        Uri.parse('$_baseUrl/daily-revenue'),
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
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(
            responseData.map((item) => item as Map<String, dynamic>),
          );
        } else {
          throw Exception('Invalid response format from server.');
        }
      } else if (response.statusCode == 401) {
        // Try to extract error message
        String errorMessage = 'Unauthorized. Please log in again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              errorMessage = errors[0].toString();
            }
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 400) {
        // Bad Request - try to extract error message
        String errorMessage = 'Bad request. Please try again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              final firstError = errors[0];
              if (firstError is Map<String, dynamic> && firstError['message'] != null) {
                errorMessage = firstError['message'];
              } else {
                errorMessage = firstError.toString();
              }
            }
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      } else {
        // Other error status codes
        String errorMessage = 'Failed to fetch daily revenue data.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              errorMessage = errors[0].toString();
            }
          } else if (errorData is Map<String, dynamic> && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Log the actual error for debugging
      print('RevenueService Error: ${e.toString()}');
      
      if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('HandshakeException') ||
                 e.toString().contains('TlsException') ||
                 e.toString().contains('CertificateException')) {
        throw Exception('SSL certificate error. Please check your network security settings.');
      } else if (e.toString().contains('Connection refused') ||
                 e.toString().contains('Connection reset')) {
        throw Exception('Connection error. Please try again later.');
      }
      // Rethrow with original message for better debugging
      rethrow;
    }
  }

  /// Fetches weekly revenue data for the last 7 days (including current day)
  /// Returns a List of weekly revenue data or throws an exception on error
  static Future<List<Map<String, dynamic>>> getWeeklyRevenue() async {
    try {
      // Get authentication headers with JWT token
      final headers = await AuthService.getAuthHeaders();

      // Make API call
      final response = await http.get(
        Uri.parse('$_baseUrl/weekly-revenue'),
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
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(
            responseData.map((item) => item as Map<String, dynamic>),
          );
        } else {
          throw Exception('Invalid response format from server.');
        }
      } else if (response.statusCode == 401) {
        // Try to extract error message
        String errorMessage = 'Unauthorized. Please log in again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              errorMessage = errors[0].toString();
            }
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 400) {
        // Bad Request - try to extract error message
        String errorMessage = 'Bad request. Please try again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              final firstError = errors[0];
              if (firstError is Map<String, dynamic> && firstError['message'] != null) {
                errorMessage = firstError['message'];
              } else {
                errorMessage = firstError.toString();
              }
            }
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      } else {
        // Other error status codes
        String errorMessage = 'Failed to fetch weekly revenue data.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              errorMessage = errors[0].toString();
            }
          } else if (errorData is Map<String, dynamic> && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Log the actual error for debugging
      print('RevenueService Error: ${e.toString()}');
      
      if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('HandshakeException') ||
                 e.toString().contains('TlsException') ||
                 e.toString().contains('CertificateException')) {
        throw Exception('SSL certificate error. Please check your network security settings.');
      } else if (e.toString().contains('Connection refused') ||
                 e.toString().contains('Connection reset')) {
        throw Exception('Connection error. Please try again later.');
      }
      // Rethrow with original message for better debugging
      rethrow;
    }
  }

  /// Fetches monthly revenue data for the current year up to the current month
  /// Returns a List of monthly revenue data grouped by month or throws an exception on error
  static Future<List<Map<String, dynamic>>> getMonthlyRevenue() async {
    try {
      // Get authentication headers with JWT token
      final headers = await AuthService.getAuthHeaders();

      // Make API call
      final response = await http.get(
        Uri.parse('$_baseUrl/monthly-revenue'),
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
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(
            responseData.map((item) => item as Map<String, dynamic>),
          );
        } else {
          throw Exception('Invalid response format from server.');
        }
      } else if (response.statusCode == 401) {
        // Try to extract error message
        String errorMessage = 'Unauthorized. Please log in again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              errorMessage = errors[0].toString();
            }
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 400) {
        // Bad Request - try to extract error message
        String errorMessage = 'Bad request. Please try again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              final firstError = errors[0];
              if (firstError is Map<String, dynamic> && firstError['message'] != null) {
                errorMessage = firstError['message'];
              } else {
                errorMessage = firstError.toString();
              }
            }
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      } else {
        // Other error status codes
        String errorMessage = 'Failed to fetch monthly revenue data.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              errorMessage = errors[0].toString();
            }
          } else if (errorData is Map<String, dynamic> && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Log the actual error for debugging
      print('RevenueService Error: ${e.toString()}');
      
      if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('HandshakeException') ||
                 e.toString().contains('TlsException') ||
                 e.toString().contains('CertificateException')) {
        throw Exception('SSL certificate error. Please check your network security settings.');
      } else if (e.toString().contains('Connection refused') ||
                 e.toString().contains('Connection reset')) {
        throw Exception('Connection error. Please try again later.');
      }
      // Rethrow with original message for better debugging
      rethrow;
    }
  }

  /// Fetches yearly revenue data for all historical years, grouped by hotel
  /// Returns a List of yearly revenue data grouped by hotel or throws an exception on error
  static Future<List<Map<String, dynamic>>> getYearlyRevenue() async {
    try {
      // Get authentication headers with JWT token
      final headers = await AuthService.getAuthHeaders();

      // Make API call
      final response = await http.get(
        Uri.parse('$_baseUrl/yearly-revenue'),
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
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(
            responseData.map((item) => item as Map<String, dynamic>),
          );
        } else {
          throw Exception('Invalid response format from server.');
        }
      } else if (response.statusCode == 401) {
        // Try to extract error message
        String errorMessage = 'Unauthorized. Please log in again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              errorMessage = errors[0].toString();
            }
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 400) {
        // Bad Request - try to extract error message
        String errorMessage = 'Bad request. Please try again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              final firstError = errors[0];
              if (firstError is Map<String, dynamic> && firstError['message'] != null) {
                errorMessage = firstError['message'];
              } else {
                errorMessage = firstError.toString();
              }
            }
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      } else {
        // Other error status codes
        String errorMessage = 'Failed to fetch yearly revenue data.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              errorMessage = errors[0].toString();
            }
          } else if (errorData is Map<String, dynamic> && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Log the actual error for debugging
      print('RevenueService Error: ${e.toString()}');
      
      if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('HandshakeException') ||
                 e.toString().contains('TlsException') ||
                 e.toString().contains('CertificateException')) {
        throw Exception('SSL certificate error. Please check your network security settings.');
      } else if (e.toString().contains('Connection refused') ||
                 e.toString().contains('Connection reset')) {
        throw Exception('Connection error. Please try again later.');
      }
      // Rethrow with original message for better debugging
      rethrow;
    }
  }

  /// Fetches year-over-year (YoY) revenue data for comparing two years
  /// Returns a List of YoY revenue data grouped by hotel or throws an exception on error
  static Future<List<Map<String, dynamic>>> getYoYRevenue() async {
    try {
      // Get authentication headers with JWT token
      final headers = await AuthService.getAuthHeaders();

      // Make API call
      final response = await http.get(
        Uri.parse('$_baseUrl/yoy-revenue'),
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
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(
            responseData.map((item) => item as Map<String, dynamic>),
          );
        } else {
          throw Exception('Invalid response format from server.');
        }
      } else if (response.statusCode == 401) {
        // Try to extract error message
        String errorMessage = 'Unauthorized. Please log in again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              errorMessage = errors[0].toString();
            }
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 400) {
        // Bad Request - try to extract error message
        String errorMessage = 'Bad request. Please try again.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              final firstError = errors[0];
              if (firstError is Map<String, dynamic> && firstError['message'] != null) {
                errorMessage = firstError['message'];
              } else {
                errorMessage = firstError.toString();
              }
            }
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      } else {
        // Other error status codes
        String errorMessage = 'Failed to fetch YoY revenue data.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> && errorData['errors'] != null) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              errorMessage = errors[0].toString();
            }
          } else if (errorData is Map<String, dynamic> && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Use default error message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Log the actual error for debugging
      print('RevenueService Error: ${e.toString()}');
      
      if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('HandshakeException') ||
                 e.toString().contains('TlsException') ||
                 e.toString().contains('CertificateException')) {
        throw Exception('SSL certificate error. Please check your network security settings.');
      } else if (e.toString().contains('Connection refused') ||
                 e.toString().contains('Connection reset')) {
        throw Exception('Connection error. Please try again later.');
      }
      // Rethrow with original message for better debugging
      rethrow;
    }
  }
}

