// FILE: lib/models/settings_model.dart
// STATUS: UPDATED - Added kioskExitPin for Kiosk Mode control
// VERSION: 2.0 - January 2026

import 'package:cloud_firestore/cloud_firestore.dart';

class VillaSettings {
  final String ownerId;

  // ========================================
  // OWNER INFO (Settings → General)
  // ========================================
  final String ownerFirstName;
  final String ownerLastName;
  final String contactEmail;
  final String contactPhone;
  final String companyName;

  // ========================================
  // EMERGENCY CONTACT (Digital Book → QR)
  // Potpuno ODVOJENO od Owner Info!
  // ========================================
  final String emergencyCall;
  final String emergencySms;
  final String emergencyWhatsapp;
  final String emergencyViber;
  final String emergencyEmail;

  // ========================================
  // KATEGORIJE JEDINICA
  // ========================================
  final List<String> categories;

  // ========================================
  // SIGURNOST
  // ========================================
  final String cleanerPin; // 4 digits - for cleaning staff
  final String hardResetPin; // 6 digits - for factory reset
  final String kioskExitPin; // 6 digits - for exiting kiosk mode on tablets

  // ========================================
  // AI ZNANJE
  // ========================================
  final String aiConcierge;
  final String aiHousekeeper;
  final String aiTech;
  final String aiGuide;

  // ========================================
  // DIGITAL INFO BOOK
  // ========================================
  final String welcomeMessage;
  final Map<String, String> welcomeMessageTranslations;
  final Map<String, String> houseRulesTranslations;
  final List<String> cleanerChecklist;
  final int welcomeMessageDuration; // Seconds (10-30)
  final int houseRulesDuration; // Seconds (20-60)

  // ========================================
  // KONFIGURACIJA
  // ========================================
  final String checkInTime;
  final String checkOutTime;
  final String wifiSsid;
  final String wifiPass;

  // ========================================
  // IZGLED I JEZIK
  // ========================================
  final String themeColor;
  final String themeMode;
  final String appLanguage;

  VillaSettings({
    required this.ownerId,
    // Owner Info
    this.ownerFirstName = '',
    this.ownerLastName = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.companyName = '',
    // Emergency Contact (ODVOJENO!)
    this.emergencyCall = '',
    this.emergencySms = '',
    this.emergencyWhatsapp = '',
    this.emergencyViber = '',
    this.emergencyEmail = '',
    // Kategorije
    this.categories = const [],
    // Sigurnost
    this.cleanerPin = '0000',
    this.hardResetPin = '123456',
    this.kioskExitPin = '000000', // 🆕 Default: unlocked (000000)
    // AI
    this.aiConcierge = '',
    this.aiHousekeeper = '',
    this.aiTech = '',
    this.aiGuide = '',
    // Digital Book
    this.welcomeMessage = 'Welcome to our Villa!',
    this.welcomeMessageTranslations = const {'en': 'Welcome to our Villa!'},
    this.houseRulesTranslations = const {'en': 'No smoking.'},
    this.cleanerChecklist = const ['Check bedsheets', 'Clean bathroom'],
    this.welcomeMessageDuration = 15,
    this.houseRulesDuration = 30,
    // Konfiguracija
    this.checkInTime = '16:00',
    this.checkOutTime = '10:00',
    this.wifiSsid = '',
    this.wifiPass = '',
    // Izgled
    this.themeColor = 'gold',
    this.themeMode = 'dark1',
    this.appLanguage = 'en',
  });

  bool get isOnboardingComplete =>
      ownerFirstName.isNotEmpty &&
      ownerLastName.isNotEmpty &&
      contactEmail.isNotEmpty &&
      contactPhone.isNotEmpty;

  String get ownerFullName => '$ownerFirstName $ownerLastName'.trim();

  factory VillaSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return VillaSettings(
      ownerId: data['ownerId']?.toString() ?? '',
      // Owner Info
      ownerFirstName: data['ownerFirstName']?.toString() ?? '',
      ownerLastName: data['ownerLastName']?.toString() ?? '',
      contactEmail: data['contactEmail']?.toString() ?? '',
      contactPhone: data['contactPhone']?.toString() ?? '',
      companyName: data['companyName']?.toString() ?? '',
      // Emergency Contact (ODVOJENO!)
      emergencyCall: data['emergencyCall']?.toString() ?? '',
      emergencySms: data['emergencySms']?.toString() ?? '',
      emergencyWhatsapp: data['emergencyWhatsapp']?.toString() ?? '',
      emergencyViber: data['emergencyViber']?.toString() ?? '',
      emergencyEmail: data['emergencyEmail']?.toString() ?? '',
      // Kategorije
      categories: _parseCategories(data),
      // Sigurnost
      cleanerPin: data['cleanerPin']?.toString() ??
          data['cleaner_pin']?.toString() ??
          '0000',
      hardResetPin: data['hardResetPin']?.toString() ??
          data['hard_reset_pin']?.toString() ??
          '123456',
      kioskExitPin: data['kioskExitPin']?.toString() ??
          data['kiosk_exit_pin']?.toString() ??
          '000000', // 🆕
      // AI
      aiConcierge: data['aiConcierge']?.toString() ??
          data['ai_concierge']?.toString() ??
          '',
      aiHousekeeper: data['aiHousekeeper']?.toString() ??
          data['ai_housekeeper']?.toString() ??
          '',
      aiTech: data['aiTech']?.toString() ?? data['ai_tech']?.toString() ?? '',
      aiGuide:
          data['aiGuide']?.toString() ?? data['ai_guide']?.toString() ?? '',
      // Digital Book
      welcomeMessage: data['welcomeMessage']?.toString() ??
          data['welcome_message']?.toString() ??
          'Welcome!',
      welcomeMessageTranslations: _parseWelcomeTranslations(data),
      houseRulesTranslations: _parseRules(data),
      cleanerChecklist: _parseChecklist(data),
      welcomeMessageDuration: _parseInt(data['welcomeMessageDuration'], 15),
      houseRulesDuration: _parseInt(data['houseRulesDuration'], 30),
      // Konfiguracija
      checkInTime: data['checkInTime']?.toString() ??
          data['check_in_time']?.toString() ??
          '16:00',
      checkOutTime: data['checkOutTime']?.toString() ??
          data['check_out_time']?.toString() ??
          '10:00',
      wifiSsid:
          data['wifiSsid']?.toString() ?? data['wifi_ssid']?.toString() ?? '',
      wifiPass:
          data['wifiPass']?.toString() ?? data['wifi_pass']?.toString() ?? '',
      // Izgled
      themeColor: data['themeColor']?.toString() ??
          data['theme_color']?.toString() ??
          'gold',
      themeMode: data['themeMode']?.toString() ??
          data['theme_mode']?.toString() ??
          'dark1',
      appLanguage: data['appLanguage']?.toString() ??
          data['app_language']?.toString() ??
          'en',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      // Owner Info
      'ownerFirstName': ownerFirstName,
      'ownerLastName': ownerLastName,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'companyName': companyName,
      // Emergency Contact (ODVOJENO!)
      'emergencyCall': emergencyCall,
      'emergencySms': emergencySms,
      'emergencyWhatsapp': emergencyWhatsapp,
      'emergencyViber': emergencyViber,
      'emergencyEmail': emergencyEmail,
      // Kategorije
      'categories': categories,
      // Sigurnost
      'cleanerPin': cleanerPin,
      'hardResetPin': hardResetPin,
      'kioskExitPin': kioskExitPin, // 🆕
      // AI
      'aiConcierge': aiConcierge,
      'aiHousekeeper': aiHousekeeper,
      'aiTech': aiTech,
      'aiGuide': aiGuide,
      // Digital Book (welcomeMessage REMOVED - use welcomeMessageTranslations)
      'welcomeMessageTranslations': welcomeMessageTranslations,
      'houseRulesTranslations': houseRulesTranslations,
      'cleanerChecklist': cleanerChecklist,
      'welcomeMessageDuration': welcomeMessageDuration,
      'houseRulesDuration': houseRulesDuration,
      // Konfiguracija (wifiSsid/wifiPass REMOVED - WiFi is per-unit)
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      // Izgled
      'themeColor': themeColor,
      'themeMode': themeMode,
      'appLanguage': appLanguage,
    };
  }

  // ========================================
  // HELPER: Copy with modifications
  // ========================================
  VillaSettings copyWith({
    String? ownerId,
    String? ownerFirstName,
    String? ownerLastName,
    String? contactEmail,
    String? contactPhone,
    String? companyName,
    String? emergencyCall,
    String? emergencySms,
    String? emergencyWhatsapp,
    String? emergencyViber,
    String? emergencyEmail,
    List<String>? categories,
    String? cleanerPin,
    String? hardResetPin,
    String? kioskExitPin,
    String? aiConcierge,
    String? aiHousekeeper,
    String? aiTech,
    String? aiGuide,
    String? welcomeMessage,
    Map<String, String>? welcomeMessageTranslations,
    Map<String, String>? houseRulesTranslations,
    List<String>? cleanerChecklist,
    int? welcomeMessageDuration,
    int? houseRulesDuration,
    String? checkInTime,
    String? checkOutTime,
    String? wifiSsid,
    String? wifiPass,
    String? themeColor,
    String? themeMode,
    String? appLanguage,
  }) {
    return VillaSettings(
      ownerId: ownerId ?? this.ownerId,
      ownerFirstName: ownerFirstName ?? this.ownerFirstName,
      ownerLastName: ownerLastName ?? this.ownerLastName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      companyName: companyName ?? this.companyName,
      emergencyCall: emergencyCall ?? this.emergencyCall,
      emergencySms: emergencySms ?? this.emergencySms,
      emergencyWhatsapp: emergencyWhatsapp ?? this.emergencyWhatsapp,
      emergencyViber: emergencyViber ?? this.emergencyViber,
      emergencyEmail: emergencyEmail ?? this.emergencyEmail,
      categories: categories ?? this.categories,
      cleanerPin: cleanerPin ?? this.cleanerPin,
      hardResetPin: hardResetPin ?? this.hardResetPin,
      kioskExitPin: kioskExitPin ?? this.kioskExitPin,
      aiConcierge: aiConcierge ?? this.aiConcierge,
      aiHousekeeper: aiHousekeeper ?? this.aiHousekeeper,
      aiTech: aiTech ?? this.aiTech,
      aiGuide: aiGuide ?? this.aiGuide,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      welcomeMessageTranslations:
          welcomeMessageTranslations ?? this.welcomeMessageTranslations,
      houseRulesTranslations:
          houseRulesTranslations ?? this.houseRulesTranslations,
      cleanerChecklist: cleanerChecklist ?? this.cleanerChecklist,
      welcomeMessageDuration:
          welcomeMessageDuration ?? this.welcomeMessageDuration,
      houseRulesDuration: houseRulesDuration ?? this.houseRulesDuration,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPass: wifiPass ?? this.wifiPass,
      themeColor: themeColor ?? this.themeColor,
      themeMode: themeMode ?? this.themeMode,
      appLanguage: appLanguage ?? this.appLanguage,
    );
  }

  // ========================================
  // PARSING HELPERS
  // ========================================

  static List<String> _parseCategories(Map<String, dynamic> data) {
    if (data['categories'] != null) {
      try {
        final rawList = data['categories'] as List;
        return rawList.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    return [];
  }

  static Map<String, String> _parseWelcomeTranslations(
      Map<String, dynamic> data) {
    if (data['welcomeMessageTranslations'] != null) {
      try {
        final rawMap = data['welcomeMessageTranslations'] as Map;
        return rawMap
            .map((key, value) => MapEntry(key.toString(), value.toString()));
      } catch (_) {}
    }
    if (data['welcome_message_translations'] != null) {
      try {
        final rawMap = data['welcome_message_translations'] as Map;
        return rawMap
            .map((key, value) => MapEntry(key.toString(), value.toString()));
      } catch (_) {}
    }
    if (data['welcomeMessage'] != null) {
      return {'en': data['welcomeMessage'].toString()};
    }
    return {'en': 'Welcome to our Villa!'};
  }

  static Map<String, String> _parseRules(Map<String, dynamic> data) {
    if (data['houseRulesTranslations'] != null) {
      try {
        final rawMap = data['houseRulesTranslations'] as Map;
        return rawMap
            .map((key, value) => MapEntry(key.toString(), value.toString()));
      } catch (_) {}
    }
    if (data['house_rules_translations'] != null) {
      try {
        final rawMap = data['house_rules_translations'] as Map;
        return rawMap
            .map((key, value) => MapEntry(key.toString(), value.toString()));
      } catch (_) {}
    }
    if (data['houseRules'] != null) {
      return {'en': data['houseRules'].toString()};
    }
    return {'en': 'No smoking.'};
  }

  static List<String> _parseChecklist(Map<String, dynamic> data) {
    if (data['cleanerChecklist'] != null) {
      try {
        final rawList = data['cleanerChecklist'] as List;
        return rawList.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    if (data['cleaner_checklist'] != null) {
      try {
        final rawList = data['cleaner_checklist'] as List;
        return rawList.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    return ['Check bedsheets', 'Clean bathroom'];
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }
}
