import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ThemeService {
  static const String _themeKey = 'app_theme';
  static const String _lightTheme = 'light';
  static const String _darkTheme = 'dark';
  
  // ValueNotifier to notify theme changes
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Get current theme mode
  static Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString(_themeKey) ?? _lightTheme;
      final mode = theme == _darkTheme ? ThemeMode.dark : ThemeMode.light;
      themeNotifier.value = mode; // Update notifier
      return mode;
    } catch (e) {
      return ThemeMode.light; // Default to light theme
    }
  }

  /// Check if dark mode is enabled
  static Future<bool> isDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString(_themeKey) ?? _lightTheme;
      return theme == _darkTheme;
    } catch (e) {
      return false; // Default to light theme
    }
  }

  /// Set theme mode
  static Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = mode == ThemeMode.dark ? _darkTheme : _lightTheme;
      await prefs.setString(_themeKey, theme);
      themeNotifier.value = mode; // Notify listeners
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle theme (light to dark or dark to light)
  static Future<ThemeMode> toggleTheme() async {
    try {
      final currentMode = await getThemeMode();
      final newMode = currentMode == ThemeMode.light 
          ? ThemeMode.dark 
          : ThemeMode.light;
      await setThemeMode(newMode);
      return newMode;
    } catch (e) {
      return ThemeMode.light;
    }
  }

  /// Reset theme to default (light)
  static Future<void> resetTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _lightTheme);
      themeNotifier.value = ThemeMode.light; // Notify listeners
    } catch (e) {
      rethrow;
    }
  }
}

