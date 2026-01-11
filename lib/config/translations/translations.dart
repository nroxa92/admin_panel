// FILE: lib/config/translations/translations.dart
// PROJECT: VillaOS Admin Panel
// VERSION: 3.0.0 - Modular Language Files
// DATE: 2026-01-11
// DESCRIPTION: Main loader that imports all language files with EN fallback

import 'lang_en.dart';
import 'lang_hr.dart';
import 'lang_de.dart';
import 'lang_sk.dart';
import 'lang_cs.dart';
import 'lang_it.dart';
import 'lang_es.dart';
import 'lang_fr.dart';
import 'lang_pl.dart';
import 'lang_hu.dart';
import 'lang_sl.dart';

class AppTranslations {
  // Supported language codes (11 languages)
  static const List<String> supportedLanguages = [
    'en', // English (Master)
    'hr', // Croatian
    'de', // German
    'sk', // Slovak
    'cs', // Czech
    'it', // Italian
    'es', // Spanish
    'fr', // French
    'pl', // Polish
    'hu', // Hungarian
    'sl', // Slovenian
  ];

  // Language display names (native)
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hr': 'Hrvatski',
    'de': 'Deutsch',
    'sk': 'Slovenčina',
    'cs': 'Čeština',
    'it': 'Italiano',
    'es': 'Español',
    'fr': 'Français',
    'pl': 'Polski',
    'hu': 'Magyar',
    'sl': 'Slovenščina',
  };

  // Language flags (emoji)
  static const Map<String, String> languageFlags = {
    'en': '🇬🇧',
    'hr': '🇭🇷',
    'de': '🇩🇪',
    'sk': '🇸🇰',
    'cs': '🇨🇿',
    'it': '🇮🇹',
    'es': '🇪🇸',
    'fr': '🇫🇷',
    'pl': '🇵🇱',
    'hu': '🇭🇺',
    'sl': '🇸🇮',
  };

  // All language maps
  static const Map<String, Map<String, String>> languages = {
    'en': LangEN.translations,
    'hr': LangHR.translations,
    'de': LangDE.translations,
    'sk': LangSK.translations,
    'cs': LangCS.translations,
    'it': LangIT.translations,
    'es': LangES.translations,
    'fr': LangFR.translations,
    'pl': LangPL.translations,
    'hu': LangHU.translations,
    'sl': LangSL.translations,
  };

  /// Get translation with EN fallback
  /// Usage: AppTranslations.get('hr', 'nav_calendar') → 'Kalendar'
  static String get(String langCode, String key) {
    // Try requested language first
    final langMap = languages[langCode];
    if (langMap != null && langMap.containsKey(key)) {
      return langMap[key]!;
    }

    // Fallback to English
    final enMap = languages['en'];
    if (enMap != null && enMap.containsKey(key)) {
      return enMap[key]!;
    }

    // Key not found - return key itself (for debugging)
    return '[$key]';
  }

  /// Get all translations for a language (with EN fallback for missing keys)
  /// Returns complete map with all keys guaranteed
  static Map<String, String> getLanguage(String langCode) {
    final Map<String, String> result = Map.from(languages['en'] ?? {});

    // Override with target language translations
    final langMap = languages[langCode];
    if (langMap != null) {
      result.addAll(langMap);
    }

    return result;
  }

  /// Check if language is supported
  static bool isSupported(String langCode) {
    return supportedLanguages.contains(langCode);
  }

  /// Get display name for language code
  /// Returns native name: 'hr' → 'Hrvatski'
  static String getDisplayName(String langCode) {
    return languageNames[langCode] ?? langCode.toUpperCase();
  }

  /// Get flag emoji for language code
  /// Returns: 'hr' → '🇭🇷'
  static String getFlag(String langCode) {
    return languageFlags[langCode] ?? '🏳️';
  }

  /// Get display with flag: '🇭🇷 Hrvatski'
  static String getDisplayWithFlag(String langCode) {
    return '${getFlag(langCode)} ${getDisplayName(langCode)}';
  }

  /// Get total number of supported languages
  static int get languageCount => supportedLanguages.length;

  /// Get total number of translation keys (from EN master)
  static int get keyCount => languages['en']?.length ?? 0;
}
