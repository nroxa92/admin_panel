// FILE: lib/screens/settings_screen.dart
// OPIS: Ekran općih postavki (Owner Info, Jezik, Teme, PIN-ovi, Lozinka).
// STATUS: UPDATED - Reorganized with ExpansionTiles for PINs and Owner Info

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../models/settings_model.dart';
import '../providers/app_provider.dart';

import 'digital_book_screen.dart';
import 'gallery_screen.dart';
import 'analytics_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final SettingsService _settingsService = SettingsService();
  late TabController _tabController;

  // LOADING STATES
  bool _isSavingOwnerInfo = false;
  bool _isSavingLanguage = false;
  bool _isSavingCleanerPin = false;
  bool _isSavingMasterPin = false;
  bool _isChangingPassword = false;

  // ==================== OWNER INFO KONTROLERI ====================
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _companyNameController = TextEditingController();

  // Read-only polja (prikazuju se ali se ne mogu mijenjati)
  String _ownerFirstName = '';
  String _ownerLastName = '';

  // PIN KONTROLERI - 4 boxes za Cleaner, 6 za Master Reset
  final List<TextEditingController> _cleanerPinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _cleanerPinFocusNodes =
      List.generate(4, (_) => FocusNode());

  final List<TextEditingController> _masterPinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _masterPinFocusNodes =
      List.generate(6, (_) => FocusNode());

  // 🆕 KIOSK PIN KONTROLERI - 6 boxes
  final List<TextEditingController> _kioskPinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _kioskPinFocusNodes =
      List.generate(6, (_) => FocusNode());
  bool _isSavingKioskPin = false;
  bool _isLockingTablets = false;

  // PASSWORD KONTROLERI
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // STATE VARIJABLE
  String _selectedThemeColor = 'gold';
  String _selectedThemeMode = 'dark1';
  String _selectedLanguage = 'en';

  // Color palettes
  final Map<String, Color> _luxuryColors = {
    'gold': const Color(0xFFD4AF37),
    'bronze': const Color(0xFFCD7F32),
    'royal_blue': const Color(0xFF1B4F72),
    'burgundy': const Color(0xFF800020),
    'emerald': const Color(0xFF2E8B57),
    'slate': const Color(0xFF708090),
  };

  final Map<String, Color> _neonColors = {
    'neon_green': const Color(0xFF39FF14),
    'cyan': const Color(0xFF00FFFF),
    'hot_pink': const Color(0xFFFF69B4),
    'electric_orange': const Color(0xFFFF4500),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Owner Info
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _companyNameController.dispose();
    // PIN
    for (var ctrl in _cleanerPinControllers) {
      ctrl.dispose();
    }
    for (var node in _cleanerPinFocusNodes) {
      node.dispose();
    }
    for (var ctrl in _masterPinControllers) {
      ctrl.dispose();
    }
    for (var node in _masterPinFocusNodes) {
      node.dispose();
    }
    // Kiosk PIN
    for (var ctrl in _kioskPinControllers) {
      ctrl.dispose();
    }
    for (var node in _kioskPinFocusNodes) {
      node.dispose();
    }
    // Password
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      debugPrint("🔵 Loading settings data...");
      final settings = await _settingsService.getSettingsStream().first;
      debugPrint(
          "🔵 Settings loaded: cleanerPin=${settings.cleanerPin}, masterPin=${settings.hardResetPin}");

      if (mounted) {
        setState(() {
          // ✅ Load Owner Info
          _ownerFirstName = settings.ownerFirstName;
          _ownerLastName = settings.ownerLastName;
          _contactEmailController.text = settings.contactEmail;
          _contactPhoneController.text = settings.contactPhone;
          _companyNameController.text = settings.companyName;

          // Load language and theme
          _selectedThemeColor = settings.themeColor;
          _selectedThemeMode = settings.themeMode;
          _selectedLanguage = settings.appLanguage;

          // Load Cleaner PIN (4 digits)
          final cleanerPin = settings.cleanerPin.padRight(4, '');
          for (int i = 0; i < 4; i++) {
            _cleanerPinControllers[i].text =
                i < cleanerPin.length ? cleanerPin[i] : '';
          }

          // Load Master Reset PIN (6 digits)
          final masterPin = settings.hardResetPin.padRight(6, '');
          for (int i = 0; i < 6; i++) {
            _masterPinControllers[i].text =
                i < masterPin.length ? masterPin[i] : '';
          }

          // Load Kiosk Exit PIN (6 digits)
          final kioskPin = settings.kioskExitPin.padRight(6, '');
          for (int i = 0; i < 6; i++) {
            _kioskPinControllers[i].text =
                i < kioskPin.length ? kioskPin[i] : '';
          }
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading settings: $e");
    }
  }

  // ==================== SAVE OWNER INFO ====================
  Future<void> _saveOwnerInfo() async {
    // Validacija
    if (_contactEmailController.text.trim().isEmpty) {
      _showError("Please enter contact email");
      return;
    }
    if (_contactPhoneController.text.trim().isEmpty) {
      _showError("Please enter contact phone");
      return;
    }

    // Email format validacija
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_contactEmailController.text.trim())) {
      _showError("Please enter a valid email address");
      return;
    }

    setState(() => _isSavingOwnerInfo = true);

    try {
      final currentSettings = await _settingsService.getSettingsStream().first;

      final newSettings = VillaSettings(
        ownerId: currentSettings.ownerId,
        ownerFirstName: currentSettings.ownerFirstName,
        ownerLastName: currentSettings.ownerLastName,
        contactEmail: _contactEmailController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        companyName: _companyNameController.text.trim(),
        emergencyCall: currentSettings.emergencyCall,
        emergencySms: currentSettings.emergencySms,
        emergencyWhatsapp: currentSettings.emergencyWhatsapp,
        emergencyViber: currentSettings.emergencyViber,
        emergencyEmail: currentSettings.emergencyEmail,
        categories: currentSettings.categories,
        themeColor: currentSettings.themeColor,
        themeMode: currentSettings.themeMode,
        appLanguage: currentSettings.appLanguage,
        cleanerPin: currentSettings.cleanerPin,
        hardResetPin: currentSettings.hardResetPin,
        houseRulesTranslations: currentSettings.houseRulesTranslations,
        welcomeMessageTranslations: currentSettings.welcomeMessageTranslations,
        cleanerChecklist: currentSettings.cleanerChecklist,
        aiConcierge: currentSettings.aiConcierge,
        aiHousekeeper: currentSettings.aiHousekeeper,
        aiTech: currentSettings.aiTech,
        aiGuide: currentSettings.aiGuide,
        welcomeMessage: currentSettings.welcomeMessage,
        checkInTime: currentSettings.checkInTime,
        checkOutTime: currentSettings.checkOutTime,
        wifiSsid: currentSettings.wifiSsid,
        wifiPass: currentSettings.wifiPass,
      );

      await _settingsService.saveSettings(newSettings);

      if (mounted) {
        _showSuccess("Contact Info Saved!");
      }
    } catch (e) {
      debugPrint("❌ Error saving owner info: $e");
      if (mounted) {
        _showError("Error: $e");
      }
    } finally {
      if (mounted) setState(() => _isSavingOwnerInfo = false);
    }
  }

  // ==================== SAVE LANGUAGE & COLORS ====================
  Future<void> _saveLanguageAndColors() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() => _isSavingLanguage = true);

    try {
      final currentSettings = await _settingsService.getSettingsStream().first;

      appProvider.setLanguage(_selectedLanguage);
      appProvider.updateTheme(_selectedThemeColor, _selectedThemeMode);

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
        themeColor: _selectedThemeColor,
        themeMode: _selectedThemeMode,
        appLanguage: _selectedLanguage,
        cleanerPin: currentSettings.cleanerPin,
        hardResetPin: currentSettings.hardResetPin,
        houseRulesTranslations: currentSettings.houseRulesTranslations,
        welcomeMessageTranslations: currentSettings.welcomeMessageTranslations,
        cleanerChecklist: currentSettings.cleanerChecklist,
        aiConcierge: currentSettings.aiConcierge,
        aiHousekeeper: currentSettings.aiHousekeeper,
        aiTech: currentSettings.aiTech,
        aiGuide: currentSettings.aiGuide,
        welcomeMessage: currentSettings.welcomeMessage,
        checkInTime: currentSettings.checkInTime,
        checkOutTime: currentSettings.checkOutTime,
        wifiSsid: currentSettings.wifiSsid,
        wifiPass: currentSettings.wifiPass,
      );

      await _settingsService.saveSettings(newSettings);

      if (mounted) {
        _showSuccess("Language & Colors Saved!");
      }
    } catch (e) {
      debugPrint("Error saving language/colors: $e");
      if (mounted) {
        _showError("Error: $e");
      }
    } finally {
      if (mounted) setState(() => _isSavingLanguage = false);
    }
  }

  // ==================== SAVE CLEANER PIN ====================
  Future<void> _saveCleanerPin() async {
    for (var ctrl in _cleanerPinControllers) {
      if (ctrl.text.isEmpty) {
        _showError("Please fill all 4 digits for Cleaner PIN");
        return;
      }
    }

    final cleanerPin = _cleanerPinControllers.map((c) => c.text).join();
    setState(() => _isSavingCleanerPin = true);

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
        cleanerPin: cleanerPin,
        themeColor: currentSettings.themeColor,
        themeMode: currentSettings.themeMode,
        appLanguage: currentSettings.appLanguage,
        hardResetPin: currentSettings.hardResetPin,
        houseRulesTranslations: currentSettings.houseRulesTranslations,
        welcomeMessageTranslations: currentSettings.welcomeMessageTranslations,
        cleanerChecklist: currentSettings.cleanerChecklist,
        aiConcierge: currentSettings.aiConcierge,
        aiHousekeeper: currentSettings.aiHousekeeper,
        aiTech: currentSettings.aiTech,
        aiGuide: currentSettings.aiGuide,
        welcomeMessage: currentSettings.welcomeMessage,
        checkInTime: currentSettings.checkInTime,
        checkOutTime: currentSettings.checkOutTime,
        wifiSsid: currentSettings.wifiSsid,
        wifiPass: currentSettings.wifiPass,
      );

      await _settingsService.saveSettings(newSettings);

      if (mounted) {
        _showSuccess("Cleaner PIN Saved!");
      }
    } catch (e) {
      debugPrint("❌ Error saving cleaner PIN: $e");
      if (mounted) {
        _showError("Error: $e");
      }
    } finally {
      if (mounted) setState(() => _isSavingCleanerPin = false);
    }
  }

  // ==================== SAVE MASTER RESET PIN ====================
  Future<void> _saveMasterPin() async {
    for (var ctrl in _masterPinControllers) {
      if (ctrl.text.isEmpty) {
        _showError("Please fill all 6 digits for Master Reset PIN");
        return;
      }
    }

    final masterPin = _masterPinControllers.map((c) => c.text).join();
    setState(() => _isSavingMasterPin = true);

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
        hardResetPin: masterPin,
        themeColor: currentSettings.themeColor,
        themeMode: currentSettings.themeMode,
        appLanguage: currentSettings.appLanguage,
        cleanerPin: currentSettings.cleanerPin,
        houseRulesTranslations: currentSettings.houseRulesTranslations,
        welcomeMessageTranslations: currentSettings.welcomeMessageTranslations,
        cleanerChecklist: currentSettings.cleanerChecklist,
        aiConcierge: currentSettings.aiConcierge,
        aiHousekeeper: currentSettings.aiHousekeeper,
        aiTech: currentSettings.aiTech,
        aiGuide: currentSettings.aiGuide,
        welcomeMessage: currentSettings.welcomeMessage,
        checkInTime: currentSettings.checkInTime,
        checkOutTime: currentSettings.checkOutTime,
        wifiSsid: currentSettings.wifiSsid,
        wifiPass: currentSettings.wifiPass,
      );

      await _settingsService.saveSettings(newSettings);

      if (mounted) {
        _showSuccess("Master Reset PIN Saved!");
      }
    } catch (e) {
      debugPrint("❌ Error saving master PIN: $e");
      if (mounted) {
        _showError("Error: $e");
      }
    } finally {
      if (mounted) setState(() => _isSavingMasterPin = false);
    }
  }

  // ==================== SAVE KIOSK EXIT PIN ====================
  Future<void> _saveKioskPin() async {
    for (var ctrl in _kioskPinControllers) {
      if (ctrl.text.isEmpty) {
        _showError("Please fill all 6 digits for Kiosk Exit PIN");
        return;
      }
    }

    final kioskPin = _kioskPinControllers.map((c) => c.text).join();

    if (!mounted) return;
    setState(() => _isSavingKioskPin = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final ownerId = provider.settings.ownerId;
      if (ownerId.isEmpty) return;

      await FirebaseFirestore.instance
          .collection('settings')
          .doc(ownerId)
          .update({'kioskExitPin': kioskPin});

      if (mounted) {
        setState(() => _isSavingKioskPin = false);
        _showSuccess("Kiosk Exit PIN Saved!");
      }
    } catch (e) {
      debugPrint("❌ Error saving kiosk PIN: $e");
      if (mounted) {
        setState(() => _isSavingKioskPin = false);
        _showError("Failed to save Kiosk Exit PIN");
      }
    }
  }

  // ==================== LOCK ALL TABLETS ====================
  Future<void> _lockAllTablets() async {
    final t = context.read<AppProvider>().translate;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            const Icon(Icons.lock, color: Colors.orange),
            const SizedBox(width: 12),
            Text(t('lock_all_tablets_confirm'),
                style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'This will enable kiosk mode on ALL your tablets. '
          'Guests will not be able to exit the app.\n\n'
          '⚠️ Only an Admin can remotely unlock tablets after this.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('btn_cancel'),
                style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(t('lock_all_tablets'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    setState(() => _isLockingTablets = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final ownerId = provider.settings.ownerId;
      if (ownerId.isEmpty) return;

      final tabletsSnapshot = await FirebaseFirestore.instance
          .collection('tablets')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in tabletsSnapshot.docs) {
        batch.update(doc.reference, {
          'kioskModeEnabled': true,
          'kioskLockedAt': FieldValue.serverTimestamp(),
          'kioskLockedBy': 'owner',
        });
      }
      await batch.commit();

      if (mounted) {
        setState(() => _isLockingTablets = false);
        _showSuccess("${tabletsSnapshot.docs.length} tablet(s) locked!");
      }
    } catch (e) {
      debugPrint("❌ Error locking tablets: $e");
      if (mounted) {
        setState(() => _isLockingTablets = false);
        _showError("Failed to lock tablets");
      }
    }
  }

  // ==================== CHANGE PASSWORD ====================
  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty) {
      _showError("Please enter current password");
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError("New passwords do not match");
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    setState(() => _isChangingPassword = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final cred = EmailAuthProvider.credential(
            email: user.email!, password: _currentPasswordController.text);

        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(_newPasswordController.text);

        if (mounted) {
          _showSuccess("Password Updated Successfully!");
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      }
    } catch (e) {
      _showError("Failed: Incorrect current password or error.");
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
    }
  }

  void _showSuccess(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.green));
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = provider.translate;
    final primaryColor = provider.primaryColor;
    final backgroundColor = provider.backgroundColor;

    final isDark = backgroundColor.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black87;
    final unselectedColor = isDark ? Colors.grey : Colors.grey[700];

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(children: [
      Container(
          color: backgroundColor,
          child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: unselectedColor,
              indicatorColor: primaryColor,
              isScrollable: false,
              labelStyle: TextStyle(fontSize: isSmallScreen ? 11 : 14),
              tabs: [
                Tab(
                    icon: Icon(Icons.tune, size: isSmallScreen ? 18 : 24),
                    text: t('tab_general')),
                Tab(
                    icon: Icon(Icons.menu_book, size: isSmallScreen ? 18 : 24),
                    text: t('tab_info')),
                Tab(
                    icon: Icon(Icons.analytics, size: isSmallScreen ? 18 : 24),
                    text: t('tab_feedback')),
                Tab(
                    icon: Icon(Icons.photo_library,
                        size: isSmallScreen ? 18 : 24),
                    text: t('tab_gallery')),
              ])),
      Expanded(
          child: TabBarView(
              controller: _tabController,
              physics: isSmallScreen
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              children: [
            _buildGeneralTab(
                t, primaryColor, backgroundColor, textColor, isDark),
            const DigitalBookScreen(),
            const AnalyticsScreen(),
            const GalleryScreen(),
          ])),
    ]);
  }

  Widget _buildGeneralTab(String Function(String) t, Color primaryColor,
      Color bgColor, Color textColor, bool isDark) {
    final cardColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ==================== 1. PERSONALIZATION (FIKSNO VIDLJIVO) ====================
              _buildSectionCard(
                cardColor: cardColor,
                textColor: textColor,
                primaryColor: primaryColor,
                isDark: isDark,
                title: t('header_personalization'),
                children: [
                  _buildLanguageDropdown(
                      textColor, primaryColor, cardColor, isDark),
                  const SizedBox(height: 30),
                  Text(t('theme_luxury'),
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 10),
                  Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _luxuryColors.entries
                          .map((e) => _buildColorCircle(e.key, e.value, isDark))
                          .toList()),
                  const SizedBox(height: 20),
                  Text(t('theme_neon'),
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 10),
                  Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _neonColors.entries
                          .map((e) => _buildColorCircle(e.key, e.value, isDark))
                          .toList()),
                  const SizedBox(height: 30),
                  Text(t('label_bg_tone'),
                      style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontSize: 13)),
                  const SizedBox(height: 10),
                  Text(t('theme_dark'),
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 12, children: [
                    _buildBgCircle('dark1', Colors.black, "OLED Black",
                        primaryColor, isDark),
                    _buildBgCircle('dark2', const Color(0xFF121212),
                        "Standard Dark", primaryColor, isDark),
                    _buildBgCircle('dark3', const Color(0xFF1E1E1E),
                        "Slate Grey", primaryColor, isDark),
                  ]),
                  const SizedBox(height: 15),
                  Text(t('theme_light'),
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 12, children: [
                    _buildBgCircle('light1', const Color(0xFFE0E0E0), "Silver",
                        primaryColor, isDark),
                    _buildBgCircle('light2', const Color(0xFFF5F5F5),
                        "Soft White", primaryColor, isDark),
                    _buildBgCircle('light3', Colors.white, "Pure White",
                        primaryColor, isDark),
                  ]),
                  const SizedBox(height: 25),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isSavingLanguage ? null : _saveLanguageAndColors,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      icon: _isSavingLanguage
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Icon(Icons.save,
                              color: isDark ? Colors.black : Colors.white),
                      label: Text(t('btn_save'),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==================== 2. SECURITY PINS (EXPANSION TILE) ====================
              _buildSecurityPinsExpansion(
                cardColor: cardColor,
                textColor: textColor,
                primaryColor: primaryColor,
                isDark: isDark,
                t: t,
                isSmallScreen: isSmallScreen,
              ),

              const SizedBox(height: 20),

              // ==================== 3. OWNER INFO + PASSWORD (EXPANSION TILE) ====================
              _buildOwnerInfoExpansion(
                cardColor: cardColor,
                textColor: textColor,
                primaryColor: primaryColor,
                isDark: isDark,
                t: t,
                isSmallScreen: isSmallScreen,
              ),

              const SizedBox(height: 50),
            ]),
          ),
        ),
      ),
    );
  }

  // ==================== SECURITY PINS EXPANSION TILE ====================
  Widget _buildSecurityPinsExpansion({
    required Color cardColor,
    required Color textColor,
    required Color primaryColor,
    required bool isDark,
    required String Function(String) t,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          leading: Icon(Icons.lock, color: primaryColor, size: 24),
          title: Text(
            "🔐 Security PINs",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            "Cleaner access & Master reset codes",
            style: TextStyle(
              color: textColor.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          iconColor: primaryColor,
          collapsedIconColor: textColor.withValues(alpha: 0.5),
          children: [
            // ===== CLEANER PIN =====
            Text(
              "Cleaner PIN (4 digits)",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Staff use this to access cleaning tasks",
              style: TextStyle(
                color: textColor.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 6),
                  child: _buildPinBox(
                    controller: _cleanerPinControllers[index],
                    focusNode: _cleanerPinFocusNodes[index],
                    nextFocusNode:
                        index < 3 ? _cleanerPinFocusNodes[index + 1] : null,
                    textColor: textColor,
                    primaryColor: primaryColor,
                    cardColor: cardColor,
                    isSmallScreen: isSmallScreen,
                  ),
                );
              }),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isSavingCleanerPin ? null : _saveCleanerPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: _isSavingCleanerPin
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.save,
                        size: 18, color: isDark ? Colors.black : Colors.white),
                label: Text(t('btn_save'),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 30),
            Divider(color: textColor.withValues(alpha: 0.2)),
            const SizedBox(height: 20),

            // ===== MASTER RESET PIN =====
            Text(
              "Master Reset PIN (6 digits)",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Use this to factory reset tablets",
              style: TextStyle(
                color: textColor.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 6),
                  child: _buildPinBox(
                    controller: _masterPinControllers[index],
                    focusNode: _masterPinFocusNodes[index],
                    nextFocusNode:
                        index < 5 ? _masterPinFocusNodes[index + 1] : null,
                    textColor: textColor,
                    primaryColor: primaryColor,
                    cardColor: cardColor,
                    isSmallScreen: isSmallScreen,
                  ),
                );
              }),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isSavingMasterPin ? null : _saveMasterPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: _isSavingMasterPin
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.save,
                        size: 18, color: isDark ? Colors.black : Colors.white),
                label: Text(t('btn_save'),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 30),
            Divider(color: textColor.withValues(alpha: 0.2)),
            const SizedBox(height: 20),

            // ===== KIOSK EXIT PIN =====
            Row(
              children: [
                const Icon(Icons.screen_lock_portrait,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Kiosk Exit PIN (6 digits)",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "PIN to exit kiosk mode on tablets (local unlock)",
              style: TextStyle(
                color: textColor.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 6),
                  child: _buildPinBox(
                    controller: _kioskPinControllers[index],
                    focusNode: _kioskPinFocusNodes[index],
                    nextFocusNode:
                        index < 5 ? _kioskPinFocusNodes[index + 1] : null,
                    textColor: textColor,
                    primaryColor: Colors.orange,
                    cardColor: cardColor,
                    isSmallScreen: isSmallScreen,
                  ),
                );
              }),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Lock All Tablets Button
                ElevatedButton.icon(
                  onPressed: _isLockingTablets ? null : _lockAllTablets,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withValues(alpha: 0.2),
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  icon: _isLockingTablets
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.orange))
                      : const Icon(Icons.lock, size: 18),
                  label: const Text("Lock All Tablets",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                // Save PIN Button
                ElevatedButton.icon(
                  onPressed: _isSavingKioskPin ? null : _saveKioskPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  icon: _isSavingKioskPin
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save, size: 18),
                  label: Text(t('btn_save'),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orange, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Once locked, only an Admin can remotely unlock tablets. "
                      "Local unlock requires this PIN.",
                      style: TextStyle(
                        color: Colors.orange.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== OWNER INFO + PASSWORD EXPANSION TILE ====================
  Widget _buildOwnerInfoExpansion({
    required Color cardColor,
    required Color textColor,
    required Color primaryColor,
    required bool isDark,
    required String Function(String) t,
    required bool isSmallScreen,
  }) {
    final fieldWidth = isSmallScreen ? double.infinity : 350.0;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          leading: Icon(Icons.person, color: primaryColor, size: 24),
          title: Text(
            "👤 Owner Information",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            "Contact details & account security",
            style: TextStyle(
              color: textColor.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          iconColor: primaryColor,
          collapsedIconColor: textColor.withValues(alpha: 0.5),
          children: [
            // ===== OWNER NAME (READ-ONLY) =====
            if (_ownerFirstName.isNotEmpty || _ownerLastName.isNotEmpty) ...[
              Text(
                "Owner Name",
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: fieldWidth,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: textColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock,
                        color: textColor.withValues(alpha: 0.4), size: 18),
                    const SizedBox(width: 10),
                    Text(
                      "$_ownerFirstName $_ownerLastName",
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Tooltip(
                      message: "Name cannot be changed after initial setup",
                      child: Icon(
                        Icons.info_outline,
                        color: textColor.withValues(alpha: 0.4),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ===== CONTACT EMAIL =====
            Text(
              "Contact Email *",
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: fieldWidth,
              child: TextField(
                controller: _contactEmailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "contact@example.com",
                  hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3)),
                  prefixIcon: Icon(Icons.email, color: primaryColor, size: 20),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: textColor.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: cardColor.withValues(alpha: 0.5),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== CONTACT PHONE =====
            Text(
              "Contact Phone *",
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: fieldWidth,
              child: TextField(
                controller: _contactPhoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "+385 91 234 5678",
                  hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3)),
                  prefixIcon: Icon(Icons.phone, color: primaryColor, size: 20),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: textColor.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: cardColor.withValues(alpha: 0.5),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== COMPANY NAME =====
            Text(
              "Company Name (optional)",
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: fieldWidth,
              child: TextField(
                controller: _companyNameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Villa Sunshine d.o.o.",
                  hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3)),
                  prefixIcon:
                      Icon(Icons.business, color: primaryColor, size: 20),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: textColor.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: cardColor.withValues(alpha: 0.5),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== SAVE OWNER INFO BUTTON =====
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isSavingOwnerInfo ? null : _saveOwnerInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: _isSavingOwnerInfo
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.save,
                        size: 18, color: isDark ? Colors.black : Colors.white),
                label: Text(t('btn_save'),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 30),
            Divider(color: textColor.withValues(alpha: 0.2)),
            const SizedBox(height: 20),

            // ===== PASSWORD CHANGE SECTION =====
            Row(
              children: [
                const Icon(Icons.lock_reset, color: Colors.redAccent, size: 20),
                const SizedBox(width: 10),
                Text(
                  t('header_password'),
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildPasswordField(
              controller: _currentPasswordController,
              label: t('label_current_password'),
              icon: Icons.lock_clock,
              textColor: textColor,
              primaryColor: primaryColor,
              cardColor: cardColor,
            ),
            const SizedBox(height: 15),
            _buildPasswordField(
              controller: _newPasswordController,
              label: t('label_new_password'),
              icon: Icons.lock_outline,
              textColor: textColor,
              primaryColor: primaryColor,
              cardColor: cardColor,
            ),
            const SizedBox(height: 15),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: t('label_confirm_password'),
              icon: Icons.lock,
              textColor: textColor,
              primaryColor: primaryColor,
              cardColor: cardColor,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isChangingPassword ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: _isChangingPassword
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.lock_reset, color: Colors.white),
                label: Text(t('btn_change'),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildSectionCard({
    required Color cardColor,
    required Color textColor,
    required Color primaryColor,
    required bool isDark,
    required String title,
    Color? titleColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: titleColor ?? primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(
      Color textColor, Color primaryColor, Color cardColor, bool isDark) {
    final t = context.read<AppProvider>().translate;
    final languages = {
      'en': 'English',
      'hr': 'Hrvatski',
      'de': 'Deutsch',
      'it': 'Italiano',
      'fr': 'Français',
      'es': 'Español',
      'pl': 'Polski',
      'cz': 'Čeština',
      'hu': 'Magyar',
      'sl': 'Slovenščina',
      'sk': 'Slovenčina',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('label_language'),
            style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          width: 280,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: textColor.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              isExpanded: true,
              dropdownColor: isDark ? Colors.grey[850] : Colors.grey[200],
              style: TextStyle(color: textColor, fontSize: 15),
              icon: Icon(Icons.arrow_drop_down, color: primaryColor),
              items: languages.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorCircle(String key, Color color, bool isDark) {
    final isSelected = _selectedThemeColor == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedThemeColor = key),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: isDark ? Colors.white : Colors.black, width: 3)
              : Border.all(color: isDark ? Colors.white10 : Colors.black12),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 12,
                  spreadRadius: 2)
          ],
        ),
        child: isSelected
            ? Icon(Icons.check,
                color: isDark ? Colors.white : Colors.black, size: 18)
            : null,
      ),
    );
  }

  Widget _buildBgCircle(String key, Color color, String tooltip,
      Color primaryColor, bool isDark) {
    final isSelected = _selectedThemeMode == key;
    final iconColor = (key.startsWith('dark') || key == 'dark1')
        ? Colors.white
        : Colors.black;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => setState(() => _selectedThemeMode = key),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: primaryColor, width: 3)
                : Border.all(color: Colors.grey.withValues(alpha: 0.5)),
            boxShadow: [
              if (isSelected)
                const BoxShadow(color: Colors.black45, blurRadius: 5)
            ],
          ),
          child:
              isSelected ? Icon(Icons.check, color: iconColor, size: 18) : null,
        ),
      ),
    );
  }

  Widget _buildPinBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required Color textColor,
    required Color primaryColor,
    required Color cardColor,
    required bool isSmallScreen,
  }) {
    final boxSize = isSmallScreen ? 40.0 : 50.0;
    final fontSize = isSmallScreen ? 20.0 : 24.0;

    return SizedBox(
      width: boxSize,
      height: boxSize + 10,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
            color: textColor, fontSize: fontSize, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onTap: () {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: textColor.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: cardColor.withValues(alpha: 0.5),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
      ),
    );
  }

  // ✅ UPDATED: Password fields are now VISIBLE (obscureText: false)
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color textColor,
    required Color primaryColor,
    required Color cardColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          width: 350,
          child: TextField(
            controller: controller,
            obscureText: false, // ✅ VIDLJIVA LOZINKA za lakše postavljanje
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: "Enter password",
              hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3)),
              prefixIcon: Icon(icon, color: primaryColor, size: 20),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: textColor.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: cardColor.withValues(alpha: 0.5),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
