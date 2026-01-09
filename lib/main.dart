// FILE: lib/main.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 4.0 - New Firebase Project
// DATE: 2026-01-09

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tenant_setup_screen.dart';
import 'screens/super_admin_screen.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'services/settings_service.dart';
import 'models/settings_model.dart';

// =============================================================================
// 🔐 SUPER ADMIN EMAIL - Samo ovaj email vidi Super Admin Dashboard
// =============================================================================
const String superAdminEmail = 'vestaluminasystem@gmail.com';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const AdminApp(),
    ),
  );
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return MaterialApp(
      title: 'VLS Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.generateTheme(
        primaryColor: appProvider.primaryColor,
        backgroundColor: appProvider.backgroundColor,
      ),
      home: const AuthWrapper(),
    );
  }
}

// =============================================================================
// AuthWrapper - Sa Super Admin Check + Tenant ID Check
// =============================================================================
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        final userEmail = snapshot.data!.email;
        if (userEmail == superAdminEmail) {
          return const SuperAdminScreen();
        }

        return FutureBuilder<IdTokenResult>(
          future: snapshot.data!.getIdTokenResult(true),
          builder: (context, tokenSnapshot) {
            if (tokenSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (tokenSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 60),
                      const SizedBox(height: 20),
                      Text(
                        "Error: ${tokenSnapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: const Text("Logout & Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }

            final claims = tokenSnapshot.data?.claims;
            final hasOwnerRole = claims?['role'] == 'owner';

            if (!hasOwnerRole) {
              return const TenantSetupScreen();
            }

            return const OnboardingWrapper();
          },
        );
      },
    );
  }
}

// =====================================================
// OnboardingWrapper - Provjera profila + Router
// =====================================================
class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final SettingsService _settingsService = SettingsService();
  bool _isLoading = true;
  bool _showOnboarding = false;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _initRouter();
    _checkOnboardingStatus();
  }

  void _initRouter() {
    _router = GoRouter(
      initialLocation: '/reception',
      routes: [
        GoRoute(
          path: '/reception',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(initialRoute: 'reception'),
          ),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(initialRoute: 'calendar'),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(initialRoute: 'settings'),
          ),
        ),
      ],
    );
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final settings = await _settingsService.getSettingsStream().first;

      if (mounted) {
        setState(() {
          _showOnboarding = !settings.isOnboardingComplete;
          _isLoading = false;
        });

        if (_showOnboarding) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showOnboardingDialog();
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Error checking onboarding: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showOnboarding = false;
        });
      }
    }
  }

  void _showOnboardingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OnboardingPopup(
        onComplete: () {
          Navigator.of(context).pop();
          setState(() {
            _showOnboarding = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Loading profile...", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Router.withConfig(config: _router);
  }
}

// =====================================================
// OnboardingPopup - Unos podataka vlasnika
// =====================================================
class OnboardingPopup extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingPopup({super.key, required this.onComplete});

  @override
  State<OnboardingPopup> createState() => _OnboardingPopupState();
}

class _OnboardingPopupState extends State<OnboardingPopup> {
  static const Color _primaryColor = Color(0xFFD4AF37);

  final SettingsService _settingsService = SettingsService();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (firstName.isEmpty) {
      setState(() => _errorMessage = "Please enter your first name");
      return;
    }
    if (lastName.isEmpty) {
      setState(() => _errorMessage = "Please enter your last name");
      return;
    }
    if (email.isEmpty) {
      setState(() => _errorMessage = "Please enter your contact email");
      return;
    }
    if (phone.isEmpty) {
      setState(() => _errorMessage = "Please enter your phone number");
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = "Please enter a valid email address");
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final currentSettings = await _settingsService.getSettingsStream().first;

      final newSettings = VillaSettings(
        ownerId: currentSettings.ownerId,
        ownerFirstName: firstName,
        ownerLastName: lastName,
        contactEmail: email,
        contactPhone: phone,
        companyName: '',
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
      widget.onComplete();
    } catch (e) {
      debugPrint("❌ Error saving onboarding: $e");
      setState(() {
        _errorMessage = "Error saving data. Please try again.";
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _primaryColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primaryColor,
                      _primaryColor.withValues(alpha: 0.7)
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.person_add, size: 35, color: Colors.black),
              ),
              const SizedBox(height: 20),
              const Text(
                "COMPLETE YOUR PROFILE",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This information will be used for guest communication\nand legal documents.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white54),
              ),
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              _buildTextField(
                controller: _firstNameController,
                label: "First Name *",
                hint: "Ivan",
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastNameController,
                label: "Last Name *",
                hint: "Horvat",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: "Contact Email *",
                hint: "contact@example.com",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: "Phone Number *",
                hint: "+385 91 234 5678",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 14, color: Colors.white.withValues(alpha: 0.4)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Name cannot be changed after setup (used for legal documents)",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor:
                        _primaryColor.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "CONTINUE TO DASHBOARD",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            prefixIcon: Icon(icon, color: _primaryColor, size: 20),
            filled: true,
            fillColor: Colors.black26,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _primaryColor, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
