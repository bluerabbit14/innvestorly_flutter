import 'package:innvestorly_flutter/services/HardCodedDataService.dart';

class RevenueService {
  /// Fetches daily revenue data from hardcoded data
  /// Returns a List of daily revenue data or throws an exception on error
  static Future<List<Map<String, dynamic>>> getDailyRevenue() async {
    try {
      final hardCodedService = HardCodedDataService();
      return await hardCodedService.getDailyRevenue();
    } catch (e) {
      throw Exception('Failed to fetch daily revenue data: ${e.toString()}');
    }
  }

  /// Fetches weekly revenue data from hardcoded data
  /// Returns a List of weekly revenue data or throws an exception on error
  static Future<List<Map<String, dynamic>>> getWeeklyRevenue() async {
    try {
      final hardCodedService = HardCodedDataService();
      return await hardCodedService.getWeeklyRevenue();
    } catch (e) {
      throw Exception('Failed to fetch weekly revenue data: ${e.toString()}');
    }
  }

  /// Fetches monthly revenue data from hardcoded data
  /// Returns a List of monthly revenue data grouped by month or throws an exception on error
  static Future<List<Map<String, dynamic>>> getMonthlyRevenue() async {
    try {
      final hardCodedService = HardCodedDataService();
      return await hardCodedService.getMonthlyRevenue();
    } catch (e) {
      throw Exception('Failed to fetch monthly revenue data: ${e.toString()}');
    }
  }

  /// Fetches yearly revenue data from hardcoded data
  /// Returns a List of yearly revenue data grouped by hotel or throws an exception on error
  static Future<List<Map<String, dynamic>>> getYearlyRevenue() async {
    try {
      final hardCodedService = HardCodedDataService();
      return await hardCodedService.getYearlyRevenue();
    } catch (e) {
      throw Exception('Failed to fetch yearly revenue data: ${e.toString()}');
    }
  }

  /// Fetches year-over-year (YoY) revenue data from hardcoded data
  /// Returns a List of YoY revenue data grouped by hotel or throws an exception on error
  static Future<List<Map<String, dynamic>>> getYoYRevenue() async {
    try {
      final hardCodedService = HardCodedDataService();
      return await hardCodedService.getYoYRevenue();
    } catch (e) {
      throw Exception('Failed to fetch YoY revenue data: ${e.toString()}');
    }
  }
}
