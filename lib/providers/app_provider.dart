// FILE: lib/providers/app_provider.dart
// OPIS: Globalno stanje aplikacije. Sadrži logiku za boje, jezik i postavke.
// STATUS: VERIFIED (Koristi SettingsService koji je već fixan sa Tenant ID)

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

  // ✅ FIXED: Dodao error handling za sigurnost
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
        // Ako dođe do greške (npr. permission denied), postavi default
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

  String translate(String key) {
    return AppTranslations.get(currentLanguage, key);
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
