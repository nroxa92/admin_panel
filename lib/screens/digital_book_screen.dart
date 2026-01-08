// FILE: lib/screens/digital_book_screen.dart
// OPIS: CMS za Kućni Red (11 Jezika) + Welcome Message (11 Jezika) + AI Prijevod + Checklist + Emergency Contact
// STATUS: FIXED - 1:1 translation (no timeout!)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../services/settings_service.dart';
import '../models/settings_model.dart';
import '../providers/app_provider.dart';

class DigitalBookScreen extends StatefulWidget {
  const DigitalBookScreen({super.key});

  @override
  State<DigitalBookScreen> createState() => _DigitalBookScreenState();
}

class _DigitalBookScreenState extends State<DigitalBookScreen> {
  final SettingsService _settingsService = SettingsService();

  bool _isLoadingWelcome = false;
  bool _isLoadingHouseRules = false;
  bool _isLoadingChecklist = false;
  bool _isLoadingAI = false;
  bool _isLoadingEmergency = false;

  // ✅ NOVO: Primary language (from Settings → General)
  String _primaryLanguage = 'en';

  // 1. WELCOME MESSAGE (11 JEZIKA)
  final Map<String, TextEditingController> _welcomeControllers = {};
  String _selectedWelcomeLang = 'en';

  // 2. HOUSE RULES (11 JEZIKA)
  final Map<String, TextEditingController> _houseRulesControllers = {};
  String _selectedRulesLang = 'en';

  // TIMERI ZA TABLET (sekunde)
  double _welcomeMessageDuration = 15;
  double _houseRulesDuration = 30;
  bool _isSavingTimers = false;

  // 3. CLEANER CHECKLIST (12 predlošaka)
  final List<TextEditingController> _checklistControllers = [];

  // 4. AI CONTEXT (4 SEKCIJE za upoznavanje vlasnika i okoline)
  final _aiLocationController = TextEditingController();
  final _aiPropertyController = TextEditingController();
  final _aiServicesController = TextEditingController();
  final _aiPersonalityController = TextEditingController();

  // 5. EMERGENCY CONTACT (kontakt za goste - QR kodovi)
  final _emergencyCallController = TextEditingController();
  final _emergencySmsController = TextEditingController();
  final _emergencyWhatsappController = TextEditingController();
  final _emergencyViberController = TextEditingController();
  final _emergencyEmailController = TextEditingController();

  final List<String> _languages = [
    'en',
    'hr',
    'de',
    'it',
    'sk',
    'hu',
    'fr',
    'es',
    'pl',
    'cz',
    'sl'
  ];

  // ✅ Firebase Functions instance (europe-west3)
  final _functions = FirebaseFunctions.instanceFor(region: 'europe-west3');

  // Checklist predlošci (12 taskova)
  final List<String> _checklistTemplates = [
    'Change bed linens',
    'Clean bathroom & toilets',
    'Vacuum all floors',
    'Mop kitchen & bathrooms',
    'Empty all trash bins',
    'Clean kitchen surfaces',
    'Dust all surfaces',
    'Check towels & supplies',
    'Clean windows & mirrors',
    'Check appliances work',
    'Inspect for damage',
    'Restock amenities',
  ];

  @override
  void initState() {
    super.initState();
    for (var lang in _languages) {
      _welcomeControllers[lang] = TextEditingController();
      _houseRulesControllers[lang] = TextEditingController();
    }
    // 12 checkboxova sa predlošcima
    for (int i = 0; i < 12; i++) {
      _checklistControllers.add(TextEditingController());
    }
    _loadData();
  }

  @override
  void dispose() {
    for (var controller in _welcomeControllers.values) {
      controller.dispose();
    }
    for (var controller in _houseRulesControllers.values) {
      controller.dispose();
    }
    for (var controller in _checklistControllers) {
      controller.dispose();
    }
    _aiLocationController.dispose();
    _aiPropertyController.dispose();
    _aiServicesController.dispose();
    _aiPersonalityController.dispose();
    // Emergency Contact
    _emergencyCallController.dispose();
    _emergencySmsController.dispose();
    _emergencyWhatsappController.dispose();
    _emergencyViberController.dispose();
    _emergencyEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final settings = await _settingsService.getSettingsStream().first;

      if (mounted) {
        setState(() {
          // ✅ Load primary language
          _primaryLanguage = settings.appLanguage;

          // Load Welcome Messages
          for (var lang in _languages) {
            _welcomeControllers[lang]!.text =
                settings.welcomeMessageTranslations[lang] ?? '';
          }

          // Load House Rules
          for (var lang in _languages) {
            _houseRulesControllers[lang]!.text =
                settings.houseRulesTranslations[lang] ?? '';
          }

          // Load Checklist ili koristi predloške
          if (settings.cleanerChecklist.isEmpty) {
            for (int i = 0; i < 12; i++) {
              _checklistControllers[i].text = _checklistTemplates[i];
            }
          } else {
            for (int i = 0;
                i < settings.cleanerChecklist.length && i < 12;
                i++) {
              _checklistControllers[i].text = settings.cleanerChecklist[i];
            }
            // Popuni ostatak sa predlošcima
            for (int i = settings.cleanerChecklist.length; i < 12; i++) {
              _checklistControllers[i].text = _checklistTemplates[i];
            }
          }

          // ✅ FIXED: AI Context - bez default vrijednosti (dopušta prazno!)
          _aiLocationController.text = settings.aiConcierge;
          _aiPropertyController.text = settings.aiHousekeeper;
          _aiServicesController.text = settings.aiTech;
          _aiPersonalityController.text = settings.aiGuide;

          // Load Emergency Contact
          _emergencyCallController.text = settings.emergencyCall;
          _emergencySmsController.text = settings.emergencySms;
          _emergencyWhatsappController.text = settings.emergencyWhatsapp;
          _emergencyViberController.text = settings.emergencyViber;
          _emergencyEmailController.text = settings.emergencyEmail;

          // Load Timers
          _welcomeMessageDuration = settings.welcomeMessageDuration.toDouble();
          _houseRulesDuration = settings.houseRulesDuration.toDouble();
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  // =============================================================================
  // WELCOME MESSAGE - SAVE (samo trenutni jezik)
  // =============================================================================
  Future<void> _saveWelcomeMessage() async {
    setState(() => _isLoadingWelcome = true);
    try {
      final currentSettings = await _settingsService.getSettingsStream().first;

      Map<String, String> welcomeMap =
          Map.from(currentSettings.welcomeMessageTranslations);
      welcomeMap[_selectedWelcomeLang] =
          _welcomeControllers[_selectedWelcomeLang]!.text.trim();

      final newSettings = VillaSettings(
        ownerId: currentSettings.ownerId,
        ownerFirstName: currentSettings.ownerFirstName,
        ownerLastName: currentSettings.ownerLastName,
        contactEmail: currentSettings.contactEmail,
        contactPhone: currentSettings.contactPhone,
        companyName: currentSettings.companyName,
        emergencyCall: currentSettings.emergencyCall,
        emergencySms: currentSettings.emergencySms,
        emergencyWhatsapp: currentSettings.emergencyWhatsapp,
        emergencyViber: currentSettings.emergencyViber,
        emergencyEmail: currentSettings.emergencyEmail,
        categories: currentSettings.categories,
        cleanerPin: currentSettings.cleanerPin,
        hardResetPin: currentSettings.hardResetPin,
        themeColor: currentSettings.themeColor,
        themeMode: currentSettings.themeMode,
        appLanguage: currentSettings.appLanguage,
        checkInTime: currentSettings.checkInTime,
        checkOutTime: currentSettings.checkOutTime,
        wifiSsid: currentSettings.wifiSsid,
        wifiPass: currentSettings.wifiPass,
        houseRulesTranslations: currentSettings.houseRulesTranslations,
        welcomeMessageTranslations: welcomeMap,
        cleanerChecklist: currentSettings.cleanerChecklist,
        aiConcierge: currentSettings.aiConcierge,
        aiHousekeeper: currentSettings.aiHousekeeper,
        aiTech: currentSettings.aiTech,
        aiGuide: currentSettings.aiGuide,
        welcomeMessage: currentSettings.welcomeMessage,
      );

      await _settingsService.saveSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Welcome Message (${_selectedWelcomeLang.toUpperCase()}) saved!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving welcome message: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingWelcome = false);
    }
  }

  // =============================================================================
  // WELCOME MESSAGE - AUTO TRANSLATE (✅ FIXED: 1:1 = no timeout!)
  // =============================================================================
  Future<void> _saveAndTranslateWelcome() async {
    // ✅ NOVO: Provjeri da nije isti jezik
    if (_selectedWelcomeLang == _primaryLanguage) {
      _showError(
          "Select a different language to translate to. Current: ${_primaryLanguage.toUpperCase()}");
      return;
    }

    // ✅ NOVO: Provjeri da postoji source tekst
    final sourceText = _welcomeControllers[_primaryLanguage]!.text.trim();
    if (sourceText.isEmpty) {
      _showError(
          "First enter Welcome Message in ${_primaryLanguage.toUpperCase()} (your primary language)!");
      return;
    }

    setState(() => _isLoadingWelcome = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "🔵 Translating ${_primaryLanguage.toUpperCase()} → ${_selectedWelcomeLang.toUpperCase()}..."),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      final currentSettings = await _settingsService.getSettingsStream().first;

      debugPrint(
          "🔵 Translating Welcome: $_primaryLanguage → $_selectedWelcomeLang");

      // ✅ FIXED: Samo 1 jezik = brzo, nema timeouta!
      final callable = _functions.httpsCallable('translateHouseRules');
      final result = await callable.call({
        'text': sourceText,
        'sourceLang': _primaryLanguage,
        'targetLangs': [_selectedWelcomeLang], // ✅ SAMO 1 JEZIK!
      });

      final data = result.data as Map<String, dynamic>;
      debugPrint("🔵 Response: $data");

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Translation failed');
      }

      final rawTranslations = data['translations'] as Map<String, dynamic>;
      final translatedText =
          rawTranslations[_selectedWelcomeLang]?.toString() ?? '';

      if (translatedText.isEmpty) {
        throw Exception("No translation received");
      }

      // Update controller
      _welcomeControllers[_selectedWelcomeLang]!.text = translatedText;

      // Save to Firestore
      Map<String, String> welcomeMap =
          Map.from(currentSettings.welcomeMessageTranslations);
      welcomeMap[_selectedWelcomeLang] = translatedText;

      final newSettings = VillaSettings(
        ownerId: currentSettings.ownerId,
        ownerFirstName: currentSettings.ownerFirstName,
        ownerLastName: currentSettings.ownerLastName,
        contactEmail: currentSettings.contactEmail,
        contactPhone: currentSettings.contactPhone,
        companyName: currentSettings.companyName,
        emergencyCall: currentSettings.emergencyCall,
        emergencySms: currentSettings.emergencySms,
        emergencyWhatsapp: currentSettings.emergencyWhatsapp,
        emergencyViber: currentSettings.emergencyViber,
        emergencyEmail: currentSettings.emergencyEmail,
        categories: currentSettings.categories,
        cleanerPin: currentSettings.cleanerPin,
        hardResetPin: currentSettings.hardResetPin,
        themeColor: currentSettings.themeColor,
        themeMode: currentSettings.themeMode,
        appLanguage: currentSettings.appLanguage,
        checkInTime: currentSettings.checkInTime,
        checkOutTime: currentSettings.checkOutTime,
        wifiSsid: currentSettings.wifiSsid,
        wifiPass: currentSettings.wifiPass,
        houseRulesTranslations: currentSettings.houseRulesTranslations,
        welcomeMessageTranslations: welcomeMap,
        cleanerChecklist: currentSettings.cleanerChecklist,
        aiConcierge: currentSettings.aiConcierge,
        aiHousekeeper: currentSettings.aiHousekeeper,
        aiTech: currentSettings.aiTech,
        aiGuide: currentSettings.aiGuide,
        welcomeMessage: currentSettings.welcomeMessage,
      );

      await _settingsService.saveSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "✅ Translated & saved to ${_selectedWelcomeLang.toUpperCase()}!"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Translation error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingWelcome = false);
    }
  }

  // =============================================================================
  // HOUSE RULES - SAVE (samo trenutni jezik)
  // =============================================================================
  Future<void> _saveHouseRules() async {
    setState(() => _isLoadingHouseRules = true);
    try {
      final currentSettings = await _settingsService.getSettingsStream().first;

      Map<String, String> rulesMap =
          Map.from(currentSettings.houseRulesTranslations);
      rulesMap[_selectedRulesLang] =
          _houseRulesControllers[_selectedRulesLang]!.text.trim();

      final newSettings = VillaSettings(
        ownerId: currentSettings.ownerId,
        ownerFirstName: currentSettings.ownerFirstName,
        ownerLastName: currentSettings.ownerLastName,
        contactEmail: currentSettings.contactEmail,
        contactPhone: currentSettings.contactPhone,
        companyName: currentSettings.companyName,
        emergencyCall: currentSettings.emergencyCall,
        emergencySms: currentSettings.emergencySms,
        emergencyWhatsapp: currentSettings.emergencyWhatsapp,
        emergencyViber: currentSettings.emergencyViber,
        emergencyEmail: currentSettings.emergencyEmail,
        categories: currentSettings.categories,
        cleanerPin: currentSettings.cleanerPin,
        hardResetPin: currentSettings.hardResetPin,
        themeColor: currentSettings.themeColor,
        themeMode: currentSettings.themeMode,
        appLanguage: currentSettings.appLanguage,
        checkInTime: currentSettings.checkInTime,
        checkOutTime: currentSettings.checkOutTime,
        wifiSsid: currentSettings.wifiSsid,
        wifiPass: currentSettings.wifiPass,
        houseRulesTranslations: rulesMap,
        welcomeMessageTranslations: currentSettings.welcomeMessageTranslations,
        cleanerChecklist: currentSettings.cleanerChecklist,
        aiConcierge: currentSettings.aiConcierge,
        aiHousekeeper: currentSettings.aiHousekeeper,
        aiTech: currentSettings.aiTech,
        aiGuide: currentSettings.aiGuide,
        welcomeMessage: currentSettings.welcomeMessage,
      );

      await _settingsService.saveSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "House Rules (${_selectedRulesLang.toUpperCase()}) saved!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving house rules: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingHouseRules = false);
    }
  }

  // =============================================================================
  // HOUSE RULES - AUTO TRANSLATE (✅ FIXED: 1:1 = no timeout!)
  // =============================================================================
  Future<void> _saveAndTranslateHouseRules() async {
    // ✅ NOVO: Provjeri da nije isti jezik
    if (_selectedRulesLang == _primaryLanguage) {
      _showError(
          "Select a different language to translate to. Current: ${_primaryLanguage.toUpperCase()}");
      return;
    }

    // ✅ NOVO: Provjeri da postoji source tekst
    final sourceText = _houseRulesControllers[_primaryLanguage]!.text.trim();
    if (sourceText.isEmpty) {
      _showError(
          "First enter House Rules in ${_primaryLanguage.toUpperCase()} (your primary language)!");
      return;
    }

    setState(() => _isLoadingHouseRules = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "🔵 Translating ${_primaryLanguage.toUpperCase()} → ${_selectedRulesLang.toUpperCase()}..."),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      final currentSettings = await _settingsService.getSettingsStream().first;

      debugPrint(
          "🔵 Translating House Rules: $_primaryLanguage → $_selectedRulesLang");

      // ✅ FIXED: Samo 1 jezik = brzo, nema timeouta!
      final callable = _functions.httpsCallable('translateHouseRules');
      final result = await callable.call({
        'text': sourceText,
        'sourceLang': _primaryLanguage,
        'targetLangs': [_selectedRulesLang], // ✅ SAMO 1 JEZIK!
      });

      final data = result.data as Map<String, dynamic>;
      debugPrint("🔵 Response: $data");

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Translation failed');
      }

      final rawTranslations = data['translations'] as Map<String, dynamic>;
      final translatedText =
          rawTranslations[_selectedRulesLang]?.toString() ?? '';

      if (translatedText.isEmpty) {
        throw Exception("No translation received");
      }

      // Update controller
      _houseRulesControllers[_selectedRulesLang]!.text = translatedText;

      // Save to Firestore
      Map<String, String> rulesMap =
          Map.from(currentSettings.houseRulesTranslations);
      rulesMap[_selectedRulesLang] = translatedText;

      final newSettings = VillaSettings(
        ownerId: currentSettings.ownerId,
        ownerFirstName: currentSettings.ownerFirstName,
        ownerLastName: currentSettings.ownerLastName,
        contactEmail: currentSettings.contactEmail,
        contactPhone: currentSettings.contactPhone,
        companyName: currentSettings.companyName,
        emergencyCall: currentSettings.emergencyCall,
        emergencySms: currentSettings.emergencySms,
        emergencyWhatsapp: currentSettings.emergencyWhatsapp,
        emergencyViber: currentSettings.emergencyViber,
        emergencyEmail: currentSettings.emergencyEmail,
        categories: currentSettings.categories,
        cleanerPin: currentSettings.cleanerPin,
        hardResetPin: currentSettings.hardResetPin,
        themeColor: currentSettings.themeColor,
        themeMode: currentSettings.themeMode,
        appLanguage: currentSettings.appLanguage,
        checkInTime: currentSettings.checkInTime,
        checkOutTime: currentSettings.checkOutTime,
        wifiSsid: currentSettings.wifiSsid,
        wifiPass: currentSettings.wifiPass,
        houseRulesTranslations: rulesMap,
        welcomeMessageTranslations: currentSettings.welcomeMessageTranslations,
        cleanerChecklist: currentSettings.cleanerChecklist,
        aiConcierge: currentSettings.aiConcierge,
        aiHousekeeper: currentSettings.aiHousekeeper,
        aiTech: currentSettings.aiTech,
        aiGuide: currentSettings.aiGuide,
        welcomeMessage: currentSettings.welcomeMessage,
      );

      await _settingsService.saveSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "✅ Translated & saved to ${_selectedRulesLang.toUpperCase()}!"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Translation error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingHouseRules = false);
    }
  }

  // =============================================================================
  // EMERGENCY CONTACT - SAVE
  // =============================================================================
  Future<void> _saveEmergencyContact() async {
    final call = _emergencyCallController.text.trim();
    final sms = _emergencySmsController.text.trim();
    final whatsapp = _emergencyWhatsappController.text.trim();
    final viber = _emergencyViberController.text.trim();
    final email = _emergencyEmailController.text.trim();

    // Validacija telefona: mora početi s + i imati 8-15 brojeva
    final phoneRegex = RegExp(r'^\+[0-9]{8,15}$');

    if (call.isNotEmpty && !phoneRegex.hasMatch(call)) {
      _showError("Call: Must start with + and have 8-15 digits");
      return;
    }
    if (sms.isNotEmpty && !phoneRegex.hasMatch(sms)) {
      _showError("SMS: Must start with + and have 8-15 digits");
      return;
    }
    if (whatsapp.isNotEmpty && !phoneRegex.hasMatch(whatsapp)) {
      _showError("WhatsApp: Must start with + and have 8-15 digits");
      return;
    }
    if (viber.isNotEmpty && !phoneRegex.hasMatch(viber)) {
      _showError("Viber: Must start with + and have 8-15 digits");
      return;
    }
    if (email.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      _showError("Please enter a valid email address");
      return;
    }

    setState(() => _isLoadingEmergency = true);
    try {
      final currentSettings = await _settingsService.getSettingsStream().first;

      final newSettings = VillaSettings(
        ownerId: currentSettings.ownerId,
        ownerFirstName: currentSettings.ownerFirstName,
        ownerLastName: currentSettings.ownerLastName,
        contactEmail: currentSettings.contactEmail,
        contactPhone: currentSettings.contactPhone,
        companyName: currentSettings.companyName,
        emergencyCall: call,
        emergencySms: sms,
        emergencyWhatsapp: whatsapp,
        emergencyViber: viber,
        emergencyEmail: email,
        categories: currentSettings.categories,
        cleanerPin: currentSettings.cleanerPin,
        hardResetPin: currentSettings.hardResetPin,
        themeColor: currentSettings.themeColor,
        themeMode: currentSettings.themeMode,
        appLanguage: currentSettings.appLanguage,
        checkInTime: currentSettings.checkInTime,
        checkOutTime: currentSettings.checkOutTime,
        wifiSsid: currentSettings.wifiSsid,
        wifiPass: currentSettings.wifiPass,
        houseRulesTranslations: currentSettings.houseRulesTranslations,
        welcomeMessageTranslations: currentSettings.welcomeMessageTranslations,
        cleanerChecklist: currentSettings.cleanerChecklist,
        aiConcierge: currentSettings.aiConcierge,
        aiHousekeeper: currentSettings.aiHousekeeper,
        aiTech: currentSettings.aiTech,
        aiGuide: currentSettings.aiGuide,
        welcomeMessage: currentSettings.welcomeMessage,
      );

      await _settingsService.saveSettings(newSettings);
      debugPrint("✅ Emergency Contact SAVED!");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Emergency Contact Saved!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Error saving emergency contact: $e");
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingEmergency = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  // =============================================================================
  // TIMERS - SAVE (za tablet screensaver)
  // =============================================================================
  Future<void> _saveTimers() async {
    setState(() => _isSavingTimers = true);
    try {
      final currentSettings = await _settingsService.getSettingsStream().first;

      final newSettings = VillaSettings(
        ownerId: currentSettings.ownerId,
        ownerFirstName: currentSettings.ownerFirstName,
        ownerLastName: currentSettings.ownerLastName,
        contactEmail: currentSettings.contactEmail,
        contactPhone: currentSettings.contactPhone,
        companyName: currentSettings.companyName,
        emergencyCall: currentSettings.emergencyCall,
        emergencySms: currentSettings.emergencySms,
        emergencyWhatsapp: currentSettings.emergencyWhatsapp,
        emergencyViber: currentSettings.emergencyViber,
        emergencyEmail: currentSettings.emergencyEmail,
        categories: currentSettings.categories,
        cleanerPin: currentSettings.cleanerPin,
        hardResetPin: currentSettings.hardResetPin,
        themeColor: currentSettings.themeColor,
        themeMode: currentSettings.themeMode,
        appLanguage: currentSettings.appLanguage,
        checkInTime: currentSettings.checkInTime,
        checkOutTime: currentSettings.checkOutTime,
        wifiSsid: currentSettings.wifiSsid,
        wifiPass: currentSettings.wifiPass,
        houseRulesTranslations: currentSettings.houseRulesTranslations,
        welcomeMessageTranslations: currentSettings.welcomeMessageTranslations,
        cleanerChecklist: currentSettings.cleanerChecklist,
        welcomeMessageDuration: _welcomeMessageDuration.toInt(),
        houseRulesDuration: _houseRulesDuration.toInt(),
        aiConcierge: currentSettings.aiConcierge,
        aiHousekeeper: currentSettings.aiHousekeeper,
        aiTech: currentSettings.aiTech,
        aiGuide: currentSettings.aiGuide,
        welcomeMessage: currentSettings.welcomeMessage,
      );

      await _settingsService.saveSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Timers saved!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving timers: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingTimers = false);
    }
  }

  // =============================================================================
  // CLEANER CHECKLIST - SAVE
  // =============================================================================
  Future<void> _saveChecklist() async {
    setState(() => _isLoadingChecklist = true);
    try {
      final currentSettings = await _settingsService.getSettingsStream().first;

      final tasks = _checklistControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final newSettings = VillaSettings(
        ownerId: currentSettings.ownerId,
        ownerFirstName: currentSettings.ownerFirstName,
        ownerLastName: currentSettings.ownerLastName,
        contactEmail: currentSettings.contactEmail,
        contactPhone: currentSettings.contactPhone,
        companyName: currentSettings.companyName,
        emergencyCall: currentSettings.emergencyCall,
        emergencySms: currentSettings.emergencySms,
        emergencyWhatsapp: currentSettings.emergencyWhatsapp,
        emergencyViber: currentSettings.emergencyViber,
        emergencyEmail: currentSettings.emergencyEmail,
        categories: currentSettings.categories,
        cleanerPin: currentSettings.cleanerPin,
        hardResetPin: currentSettings.hardResetPin,
        themeColor: currentSettings.themeColor,
        themeMode: currentSettings.themeMode,
        appLanguage: currentSettings.appLanguage,
        checkInTime: currentSettings.checkInTime,
        checkOutTime: currentSettings.checkOutTime,
        wifiSsid: currentSettings.wifiSsid,
        wifiPass: currentSettings.wifiPass,
        houseRulesTranslations: currentSettings.houseRulesTranslations,
        welcomeMessageTranslations: currentSettings.welcomeMessageTranslations,
        cleanerChecklist: tasks,
        aiConcierge: currentSettings.aiConcierge,
        aiHousekeeper: currentSettings.aiHousekeeper,
        aiTech: currentSettings.aiTech,
        aiGuide: currentSettings.aiGuide,
        welcomeMessage: currentSettings.welcomeMessage,
      );

      await _settingsService.saveSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Checklist saved (${tasks.length} tasks)!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving checklist: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingChecklist = false);
    }
  }

  // =============================================================================
  // AI CONTEXT - SAVE
  // =============================================================================
  Future<void> _saveAIContext() async {
    setState(() => _isLoadingAI = true);
    try {
      final currentSettings = await _settingsService.getSettingsStream().first;

      final newSettings = VillaSettings(
        ownerId: currentSettings.ownerId,
        ownerFirstName: currentSettings.ownerFirstName,
        ownerLastName: currentSettings.ownerLastName,
        contactEmail: currentSettings.contactEmail,
        contactPhone: currentSettings.contactPhone,
        companyName: currentSettings.companyName,
        emergencyCall: currentSettings.emergencyCall,
        emergencySms: currentSettings.emergencySms,
        emergencyWhatsapp: currentSettings.emergencyWhatsapp,
        emergencyViber: currentSettings.emergencyViber,
        emergencyEmail: currentSettings.emergencyEmail,
        categories: currentSettings.categories,
        cleanerPin: currentSettings.cleanerPin,
        hardResetPin: currentSettings.hardResetPin,
        themeColor: currentSettings.themeColor,
        themeMode: currentSettings.themeMode,
        appLanguage: currentSettings.appLanguage,
        checkInTime: currentSettings.checkInTime,
        checkOutTime: currentSettings.checkOutTime,
        wifiSsid: currentSettings.wifiSsid,
        wifiPass: currentSettings.wifiPass,
        houseRulesTranslations: currentSettings.houseRulesTranslations,
        welcomeMessageTranslations: currentSettings.welcomeMessageTranslations,
        cleanerChecklist: currentSettings.cleanerChecklist,
        aiConcierge: _aiLocationController.text.trim(),
        aiHousekeeper: _aiPropertyController.text.trim(),
        aiTech: _aiServicesController.text.trim(),
        aiGuide: _aiPersonalityController.text.trim(),
        welcomeMessage: currentSettings.welcomeMessage,
      );

      await _settingsService.saveSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("AI Context saved!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving AI context: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAI = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final primaryColor = provider.primaryColor;
    final backgroundColor = provider.backgroundColor;
    final isDark = backgroundColor.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black87;

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          // ===== HEADER =====
          Text(
            "Digital Info Book",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Manage content visible to guests on tablets",
            style: TextStyle(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 40),

          // ===== SECTION 1: WELCOME MESSAGE =====
          _buildSectionHeader(
              context, "1. WELCOME MESSAGE (11 Languages)", textColor),
          const SizedBox(height: 15),
          _buildLanguageSelector(_selectedWelcomeLang, (lang) {
            setState(() => _selectedWelcomeLang = lang);
          }, primaryColor, _primaryLanguage, controllers: _welcomeControllers),
          const SizedBox(height: 15),
          _buildMultilineField(
            context,
            _welcomeControllers[_selectedWelcomeLang]!,
            "Welcome Message in ${_selectedWelcomeLang.toUpperCase()}",
            maxLines: 5,
            textColor: textColor,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.end,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 180,
                height: 36,
                child: ElevatedButton(
                  onPressed: _isLoadingWelcome ? null : _saveWelcomeMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: 10,
                    ),
                  ),
                  child: _isLoadingWelcome
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          "SAVE",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 180,
                height: 36,
                child: ElevatedButton(
                  onPressed:
                      _isLoadingWelcome ? null : _saveAndTranslateWelcome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: 10,
                    ),
                  ),
                  child: _isLoadingWelcome
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          "AUTO TRANSLATE",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),

          // ===== SECTION 2: HOUSE RULES =====
          _buildSectionHeader(
              context, "2. HOUSE RULES (11 Languages)", textColor),
          const SizedBox(height: 15),
          _buildLanguageSelector(_selectedRulesLang, (lang) {
            setState(() => _selectedRulesLang = lang);
          }, primaryColor, _primaryLanguage,
              controllers: _houseRulesControllers),
          const SizedBox(height: 15),
          _buildMultilineField(
            context,
            _houseRulesControllers[_selectedRulesLang]!,
            "House Rules in ${_selectedRulesLang.toUpperCase()}",
            maxLines: 15,
            textColor: textColor,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.end,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 180,
                height: 36,
                child: ElevatedButton(
                  onPressed: _isLoadingHouseRules ? null : _saveHouseRules,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: 10,
                    ),
                  ),
                  child: _isLoadingHouseRules
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          "SAVE",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 180,
                height: 36,
                child: ElevatedButton(
                  onPressed:
                      _isLoadingHouseRules ? null : _saveAndTranslateHouseRules,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: 10,
                    ),
                  ),
                  child: _isLoadingHouseRules
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          "AUTO TRANSLATE",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),

          // ===== SECTION 2.5: TABLET TIMERS =====
          _buildSectionHeader(context, "⏱️ TABLET DISPLAY TIMERS", textColor),
          const SizedBox(height: 10),
          Text(
            "How long each screen shows on the tablet before moving to next",
            style: TextStyle(
              fontSize: 13,
              color: textColor.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),

          // Welcome Message Timer
          Row(
            children: [
              SizedBox(
                width: 180,
                child: Text(
                  "Welcome Message:",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _welcomeMessageDuration,
                  min: 10,
                  max: 30,
                  divisions: 20,
                  activeColor: primaryColor,
                  inactiveColor: primaryColor.withValues(alpha: 0.3),
                  label: "${_welcomeMessageDuration.toInt()} sec",
                  onChanged: (value) {
                    setState(() => _welcomeMessageDuration = value);
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  "${_welcomeMessageDuration.toInt()} sec",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // House Rules Timer
          Row(
            children: [
              SizedBox(
                width: 180,
                child: Text(
                  "House Rules:",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _houseRulesDuration,
                  min: 20,
                  max: 60,
                  divisions: 40,
                  activeColor: primaryColor,
                  inactiveColor: primaryColor.withValues(alpha: 0.3),
                  label: "${_houseRulesDuration.toInt()} sec",
                  onChanged: (value) {
                    setState(() => _houseRulesDuration = value);
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  "${_houseRulesDuration.toInt()} sec",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Save Timers Button
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: isMobile ? double.infinity : 180,
              height: 36,
              child: ElevatedButton(
                onPressed: _isSavingTimers ? null : _saveTimers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: _isSavingTimers
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        "SAVE TIMERS",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 50),

          // ===== SECTION 2.5: EMERGENCY CONTACT =====
          _buildSectionHeader(
              context, "📞 EMERGENCY CONTACT (Guest Help QR)", textColor),
          const SizedBox(height: 10),
          Text(
            "These contacts will be shown as QR codes on the tablet when guests need help",
            style: TextStyle(
              fontSize: 13,
              color: textColor.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          _buildEmergencyContactFields(
              textColor, primaryColor, isDark, isMobile),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: isMobile ? double.infinity : 180,
              height: 36,
              child: ElevatedButton(
                onPressed: _isLoadingEmergency ? null : _saveEmergencyContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                ),
                child: _isLoadingEmergency
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        "SAVE",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 50),

          // ===== SECTION 3: CLEANER CHECKLIST =====
          _buildSectionHeader(
              context, "3. CLEANER CHECKLIST (Tablet Tasks)", textColor),
          const SizedBox(height: 15),
          _buildChecklist(context, textColor, primaryColor, isMobile),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: isMobile ? double.infinity : 180,
              height: 36,
              child: ElevatedButton(
                onPressed: _isLoadingChecklist ? null : _saveChecklist,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                ),
                child: _isLoadingChecklist
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        "SAVE",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 50),

          // ===== SECTION 4: AI CONTEXT =====
          _buildSectionHeader(
              context, "4. AI PERSONALITY (Get to Know You)", textColor),
          const SizedBox(height: 10),
          Text(
            "Help AI agents understand your property, location, and hosting style",
            style: TextStyle(
              fontSize: 13,
              color: textColor.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          _buildAIContextFields(context, textColor, primaryColor),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: isMobile ? double.infinity : 180,
              height: 36,
              child: ElevatedButton(
                onPressed: _isLoadingAI ? null : _saveAIContext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                ),
                child: _isLoadingAI
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        "SAVE",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  // ✅ UPDATED: Primary = plavo, ostali = crveno/zeleno po sadržaju
  Widget _buildLanguageSelector(String selected, Function(String) onSelect,
      Color primaryColor, String primaryLang,
      {Map<String, TextEditingController>? controllers}) {
    final otherLanguages =
        _languages.where((lang) => lang != primaryLang).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== SOURCE LANGUAGE (PRIMARY) - IZDVOJENO! =====
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "SOURCE: ${primaryLang.toUpperCase()}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Write your text in ${primaryLang.toUpperCase()} first",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              // Edit source button
              GestureDetector(
                onTap: () => onSelect(primaryLang),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected == primaryLang
                        ? Colors.blue[700]
                        : Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    selected == primaryLang ? "✏️ EDITING" : "📝 EDIT",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: selected == primaryLang
                          ? Colors.white
                          : Colors.blue[700],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ===== TARGET LANGUAGES =====
        Row(
          children: [
            Icon(Icons.translate, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              "TRANSLATE TO:",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "(🔴 empty  🟢 translated)",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Language chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: otherLanguages.map((lang) {
            final isSelected = lang == selected;
            final hasContent = controllers != null &&
                controllers[lang]!.text.trim().isNotEmpty;

            Color chipColor;
            Color textColor;

            if (hasContent) {
              chipColor = isSelected ? Colors.green[600]! : Colors.green[50]!;
              textColor = isSelected ? Colors.white : Colors.green[800]!;
            } else {
              chipColor = isSelected ? Colors.red[400]! : Colors.red[50]!;
              textColor = isSelected ? Colors.white : Colors.red[700]!;
            }

            return ChoiceChip(
              avatar: Icon(
                hasContent ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (hasContent ? Colors.green[600] : Colors.red[400]),
              ),
              label: Text(lang.toUpperCase()),
              selected: isSelected,
              onSelected: (_) => onSelect(lang),
              selectedColor: chipColor,
              backgroundColor: chipColor,
              labelStyle: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              side: BorderSide(
                color: hasContent ? Colors.green[600]! : Colors.red[400]!,
                width: isSelected ? 2 : 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultilineField(
    BuildContext context,
    TextEditingController controller,
    String label, {
    int maxLines = 10,
    required Color textColor,
    required Color primaryColor,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        labelStyle:
            TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
    );
  }

  // Emergency Contact Fields
  Widget _buildEmergencyContactFields(
      Color textColor, Color primaryColor, bool isDark, bool isMobile) {
    return Column(
      children: [
        // Row 1: Call & SMS
        isMobile
            ? Column(children: [
                _buildContactField(_emergencyCallController, "📞 Call",
                    "+385911234567", Icons.phone, textColor, primaryColor),
                const SizedBox(height: 15),
                _buildContactField(_emergencySmsController, "💬 SMS",
                    "+385911234567", Icons.sms, textColor, primaryColor),
              ])
            : Row(children: [
                Expanded(
                    child: _buildContactField(
                        _emergencyCallController,
                        "📞 Call",
                        "+385911234567",
                        Icons.phone,
                        textColor,
                        primaryColor)),
                const SizedBox(width: 20),
                Expanded(
                    child: _buildContactField(_emergencySmsController, "💬 SMS",
                        "+385911234567", Icons.sms, textColor, primaryColor)),
              ]),
        const SizedBox(height: 15),
        // Row 2: WhatsApp & Viber
        isMobile
            ? Column(children: [
                _buildContactField(_emergencyWhatsappController, "📱 WhatsApp",
                    "+385911234567", Icons.chat, textColor, primaryColor),
                const SizedBox(height: 15),
                _buildContactField(
                    _emergencyViberController,
                    "📲 Viber",
                    "+385911234567",
                    Icons.phone_android,
                    textColor,
                    primaryColor),
              ])
            : Row(children: [
                Expanded(
                    child: _buildContactField(
                        _emergencyWhatsappController,
                        "📱 WhatsApp",
                        "+385911234567",
                        Icons.chat,
                        textColor,
                        primaryColor)),
                const SizedBox(width: 20),
                Expanded(
                    child: _buildContactField(
                        _emergencyViberController,
                        "📲 Viber",
                        "+385911234567",
                        Icons.phone_android,
                        textColor,
                        primaryColor)),
              ]),
        const SizedBox(height: 15),
        // Row 3: Email (full width)
        _buildContactField(_emergencyEmailController, "📧 Email",
            "owner@example.com", Icons.email, textColor, primaryColor,
            keyboardType: TextInputType.emailAddress),
      ],
    );
  }

  Widget _buildContactField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
    Color textColor,
    Color primaryColor, {
    TextInputType keyboardType = TextInputType.phone,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: textColor.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3)),
            prefixIcon: Icon(icon, color: primaryColor, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: textColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklist(BuildContext context, Color textColor,
      Color primaryColor, bool isMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        childAspectRatio: isMobile ? 4 : 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return TextField(
          controller: _checklistControllers[index],
          style: TextStyle(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            labelText: "Task ${index + 1}",
            labelStyle: TextStyle(
                fontSize: 11, color: textColor.withValues(alpha: 0.6)),
            prefixIcon: Icon(Icons.check_box_outline_blank,
                size: 18, color: primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          ),
        );
      },
    );
  }

  Widget _buildAIContextFields(
      BuildContext context, Color textColor, Color primaryColor) {
    return Column(
      children: [
        _buildMultilineField(
          context,
          _aiLocationController,
          "📍 Location & Access (Where is property? How to get there? Parking?)",
          maxLines: 4,
          textColor: textColor,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 15),
        _buildMultilineField(
          context,
          _aiPropertyController,
          "🏠 Property Details (Size? Rooms? Amenities? Special features?)",
          maxLines: 4,
          textColor: textColor,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 15),
        _buildMultilineField(
          context,
          _aiServicesController,
          "⚙️ House Rules & Services (WiFi? Check times? Quiet hours? Policies?)",
          maxLines: 4,
          textColor: textColor,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 15),
        _buildMultilineField(
          context,
          _aiPersonalityController,
          "💬 Your Hosting Style (How do you communicate? What's your approach?)",
          maxLines: 4,
          textColor: textColor,
          primaryColor: primaryColor,
        ),
      ],
    );
  }
}
