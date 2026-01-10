// FILE: lib/providers/app_provider.dart
// PROJECT: VillaOS Admin Panel
// STATUS: ✅ FIXED - Corrected translate method argument order
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../config/translations.dart';

class AppProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  VillaSettings _settings = VillaSettings(ownerId: '');

  String? _languageOverride;
  String? _themeColorOverride;
  String? _themeModeOverride;

  VillaSettings get settings => _settings;

  String get currentLanguage => _languageOverride ?? _settings.appLanguage;

  AppProvider() {
    _initStream();
  }

  void _initStream() {
    _settingsService.getSettingsStream().listen(
      (newSettings) {
        _settings = newSettings;
        _languageOverride = null;
        _themeColorOverride = null;
        _themeModeOverride = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("AppProvider Stream Error: $error");
        _settings = VillaSettings(ownerId: '');
        notifyListeners();
      },
    );
  }

  // --- METODE ZA PROMJENU STANJA ---

  void setLanguage(String lang) {
    _languageOverride = lang;
    notifyListeners();
  }

  void updateTheme(String colorKey, String modeKey) {
    _themeColorOverride = colorKey;
    _themeModeOverride = modeKey;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ FIXED: Corrected argument order - was get(currentLanguage, key)
  //          Now correctly: get(key, currentLanguage)
  // ═══════════════════════════════════════════════════════════════════════════
  String translate(String key) {
    return AppTranslations.get(key, currentLanguage);
  }

  // --- LOGIKA BOJA (PALETA) ---

  Color get primaryColor {
    final key = _themeColorOverride ?? _settings.themeColor;

    switch (key) {
      // --- LUXURY PALETTE (Elegancija) ---
      case 'gold':
        return const Color(0xFFD4AF37);
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'royal_blue':
        return const Color(0xFF1B4F72);
      case 'burgundy':
        return const Color(0xFF800020);
      case 'emerald':
        return const Color(0xFF2E8B57);
      case 'slate':
        return const Color(0xFF708090);

      // --- NEON / TECH PALETTE (Hacker stil) ---
      case 'neon_green':
        return const Color(0xFF39FF14);
      case 'cyan':
        return const Color(0xFF00FFFF);
      case 'hot_pink':
        return const Color(0xFFFF69B4);
      case 'electric_orange':
        return const Color(0xFFFF4500);

      default:
        return const Color(0xFFD4AF37);
    }
  }

  // --- BOJE POZADINE (6 NIJANSI) ---
  Color get backgroundColor {
    final key = _themeModeOverride ?? _settings.themeMode;

    switch (key) {
      // --- TAMNE NIJANSE (Za OLED i noć) ---
      case 'dark1':
        return Colors.black;
      case 'dark2':
        return const Color(0xFF121212);
      case 'dark3':
        return const Color(0xFF1E1E1E);

      // --- SVIJETLE NIJANSE (Za dan i svježinu) ---
      case 'light1':
        return const Color(0xFFE0E0E0);
      case 'light2':
        return const Color(0xFFF5F5F5);
      case 'light3':
        return Colors.white;

      default:
        return const Color(0xFF121212);
    }
  }
}
