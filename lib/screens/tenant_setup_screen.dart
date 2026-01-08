// FILE: lib/screens/tenant_setup_screen.dart
// OPIS: Screen za prvi login - vlasnik linkuje svoj Tenant ID.
// STATUS: ✅ FIXED (Direct HTTP call - bypassing Int64 bug!)

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TenantSetupScreen extends StatefulWidget {
  const TenantSetupScreen({super.key});

  @override
  State<TenantSetupScreen> createState() => _TenantSetupScreenState();
}

class _TenantSetupScreenState extends State<TenantSetupScreen> {
  final _tenantIdController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tenantIdController.dispose();
    super.dispose();
  }

  Future<void> _linkTenantId() async {
    final tenantId = _tenantIdController.text.trim().toUpperCase();

    // ✅ VALIDACIJA 1: Prazan input
    if (tenantId.isEmpty) {
      setState(() => _errorMessage = "Please enter your Tenant ID");
      return;
    }

    // ✅ VALIDACIJA 2: Format (6-12 uppercase letters/numbers)
    if (!RegExp(r'^[A-Z0-9]{6,12}$').hasMatch(tenantId)) {
      setState(() =>
          _errorMessage = "Invalid format (6-12 uppercase letters/numbers)");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // ✅ DEBUG: Log početak poziva
    debugPrint("🔵 Starting linkTenantId call for: $tenantId");

    try {
      // ✅ KRITIČNO: Dohvati JWT token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // ✅ Force refresh token (uvijek najnoviji!)
      final idToken = await user.getIdToken(true);
      if (idToken == null) {
        throw Exception("Failed to get authentication token");
      }

      debugPrint("🔵 Got JWT token, making HTTP request...");

      // ✅ DIREKTAN HTTP POZIV (zaobilazi Int64 bug!)
      final url = Uri.parse(
          'https://europe-west3-villa-ai-admin.cloudfunctions.net/linkTenantId');

      debugPrint("🔵 Calling: $url");

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({
          'data': {'tenantId': tenantId}
        }),
      )
          .timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception("Request timeout - check your internet connection");
        },
      );

      debugPrint("🔵 Response status: ${response.statusCode}");
      debugPrint("🔵 Response body: ${response.body}");

      // ✅ Parse response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Cloud Functions v2 callable response format:
        // {"result": {"success": true, "message": "...", "tenantId": "..."}}
        final result = data['result'];

        if (result['success'] == true) {
          debugPrint("✅ Cloud Function success: $result");

          // ✅ SUCCESS MESSAGE
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✅ Account activated! Logging you back in..."),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }

          // ✅ Pričekaj 2 sekunde da user vidi poruku
          await Future.delayed(const Duration(seconds: 2));

          // ✅ LOGOUT (AuthWrapper će detektirati i ponovno učitati Claims!)
          debugPrint("🔵 Logging out to refresh claims...");
          await FirebaseAuth.instance.signOut();

          // AuthWrapper automatski:
          // 1. Vidi logout → LoginScreen
          // 2. User se logira → Nova Custom Claims → Dashboard ✅
        } else {
          throw Exception(result['message'] ?? 'Activation failed');
        }
      } else {
        // ✅ Parse error response
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['error']?['message'] ?? 'Unknown error';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception("Server error: ${response.statusCode}");
        }
      }
    } on http.ClientException catch (e) {
      // ✅ NETWORK ERRORI
      debugPrint("❌ Network Error: $e");

      if (mounted) {
        setState(() {
          _errorMessage = "Network error. Check your internet connection.";
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      // ✅ GENERIČKI ERRORI
      debugPrint("❌ Error: $e");

      String userMessage = e.toString().replaceFirst('Exception: ', '');

      // ✅ User-friendly error messages
      if (userMessage.contains('Invalid tenant ID')) {
        userMessage = "Tenant ID not found";
      } else if (userMessage.contains('does not match')) {
        userMessage = "Email doesn't match this tenant ID";
      } else if (userMessage.contains('already linked')) {
        userMessage = "This tenant ID is already linked";
      } else if (userMessage.contains('timeout')) {
        userMessage = "Request timeout. Try again.";
      } else if (userMessage.contains('not logged in')) {
        userMessage = "Please login first";
      }

      if (mounted) {
        setState(() {
          _errorMessage = userMessage;
          _isLoading = false;
        });
      }
    } catch (e) {
      // ✅ NEOČEKIVANI ERRORI
      debugPrint("❌ Unexpected Error: $e");

      if (mounted) {
        setState(() {
          _errorMessage = "Unknown error. Please try again.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0a0a0a), Color(0xFF1a1a1a)],
          ),
        ),
        child: Center(
          child: FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Container(
              width: 450,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo/Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFB8941F)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.key, size: 40, color: Colors.black),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    "ACTIVATE ACCOUNT",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    "Enter your Tenant ID to complete setup",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Input Field
                  TextField(
                    controller: _tenantIdController,
                    enabled: !_isLoading,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: "TENANT ID",
                      labelStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                      hintText: "ENTER ID",
                      hintStyle: const TextStyle(
                        color: Colors.white24,
                        letterSpacing: 2,
                      ),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFD4AF37),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFD4AF37),
                          width: 2,
                        ),
                      ),
                      prefixIcon:
                          const Icon(Icons.vpn_key, color: Color(0xFFD4AF37)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Helper text
                  const Text(
                    "You received this ID from VillaOS support",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Activate Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _linkTenantId,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                            const Color(0xFFD4AF37).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text(
                              "ACTIVATE ACCOUNT",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Back to Login
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => FirebaseAuth.instance.signOut(),
                    child: const Text(
                      "← Back to Login",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
