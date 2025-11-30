import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:innvestorly_flutter/services/AuthService.dart';

class OccupancyService {
  static const String _baseUrl = 'https://dailyrevue.argosstaging.com/api/dashboard';

  /// Fetches daily occupancy data
  /// Returns a List of daily occupancy data or throws an exception on error
  static Future<List<Map<String, dynamic>>> getDailyOccupancy() async {
    try {
      // Get authentication headers with JWT token
      final headers = await AuthService.getAuthHeaders();

      // Make API call
      final response = await http.get(
        Uri.parse('$_baseUrl/daily-occupancy'),
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
        String errorMessage = 'Failed to fetch daily occupancy data.';
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
      print('OccupancyService Error: ${e.toString()}');
      
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
      rethrow;
    }
  }

  /// Fetches weekly occupancy data
  /// Returns a List of weekly occupancy data or throws an exception on error
  static Future<List<Map<String, dynamic>>> getWeeklyOccupancy() async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('$_baseUrl/weekly-occupancy'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

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
        String errorMessage = 'Failed to fetch weekly occupancy data.';
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
      print('OccupancyService Error: ${e.toString()}');
      
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
      rethrow;
    }
  }

  /// Fetches monthly occupancy data
  /// Returns a List of monthly occupancy data grouped by month or throws an exception on error
  static Future<List<Map<String, dynamic>>> getMonthlyOccupancy() async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('$_baseUrl/monthly-occupancy'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

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
        String errorMessage = 'Failed to fetch monthly occupancy data.';
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
      print('OccupancyService Error: ${e.toString()}');
      
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
      rethrow;
    }
  }

  /// Fetches yearly occupancy data
  /// Returns a List of yearly occupancy data grouped by hotel or throws an exception on error
  static Future<List<Map<String, dynamic>>> getYearlyOccupancy() async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('$_baseUrl/yearly-occupancy'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

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
        String errorMessage = 'Failed to fetch yearly occupancy data.';
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
      print('OccupancyService Error: ${e.toString()}');
      
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
      rethrow;
    }
  }
}



