import 'package:flutter/material.dart';

/// Supported locales for AgriPrice AI.
class L10n {
  static const supportedLocales = [
    Locale('en'), // English
    Locale('ta'), // Tamil
  ];

  static const fallbackLocale = Locale('en');

  /// Returns the display name for a locale code.
  static String getLanguageName(String code) {
    switch (code) {
      case 'ta':
        return 'தமிழ்';
      case 'en':
      default:
        return 'English';
    }
  }

  /// Returns the flag emoji for a locale code.
  static String getFlag(String code) {
    switch (code) {
      case 'ta':
        return '🇮🇳';
      case 'en':
      default:
        return '🇬🇧';
    }
  }
}
