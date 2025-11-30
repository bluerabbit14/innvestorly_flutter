import 'package:innvestorly_flutter/services/HardCodedDataService.dart';

class OccupancyService {
  /// Fetches daily occupancy data from hardcoded data
  /// Returns a List of daily occupancy data or throws an exception on error
  static Future<List<Map<String, dynamic>>> getDailyOccupancy() async {
    try {
      final hardCodedService = HardCodedDataService();
      return await hardCodedService.getDailyOccupancy();
    } catch (e) {
      throw Exception('Failed to fetch daily occupancy data: ${e.toString()}');
    }
  }

  /// Fetches weekly occupancy data from hardcoded data
  /// Returns a List of weekly occupancy data or throws an exception on error
  static Future<List<Map<String, dynamic>>> getWeeklyOccupancy() async {
    try {
      final hardCodedService = HardCodedDataService();
      return await hardCodedService.getWeeklyOccupancy();
    } catch (e) {
      throw Exception('Failed to fetch weekly occupancy data: ${e.toString()}');
    }
  }

  /// Fetches monthly occupancy data from hardcoded data
  /// Returns a List of monthly occupancy data grouped by month or throws an exception on error
  static Future<List<Map<String, dynamic>>> getMonthlyOccupancy() async {
    try {
      final hardCodedService = HardCodedDataService();
      return await hardCodedService.getMonthlyOccupancy();
    } catch (e) {
      throw Exception('Failed to fetch monthly occupancy data: ${e.toString()}');
    }
  }

  /// Fetches yearly occupancy data from hardcoded data
  /// Returns a List of yearly occupancy data grouped by hotel or throws an exception on error
  static Future<List<Map<String, dynamic>>> getYearlyOccupancy() async {
    try {
      final hardCodedService = HardCodedDataService();
      return await hardCodedService.getYearlyOccupancy();
    } catch (e) {
      throw Exception('Failed to fetch yearly occupancy data: ${e.toString()}');
    }
  }
}
