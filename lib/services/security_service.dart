// FILE: lib/services/security_service.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 2.0.0 - Phase 1 Production Readiness

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Security Service - PIN brute-force protection
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // =====================================================
  // CONFIGURATION
  // =====================================================

  static const int maxAttempts = 5;
  static const int lockoutMinutes = 15;
  static const int attemptWindowMinutes = 30;

  static const String _keyAttempts = 'security_pin_attempts';
  static const String _keyLockoutUntil = 'security_lockout_until';
  static const String _keyLastAttempt = 'security_last_attempt';

  // =====================================================
  // PIN VALIDATION WITH RATE LIMITING
  // =====================================================

  Future<PinLockStatus> checkLockStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final lockoutUntilMs = prefs.getInt(_keyLockoutUntil) ?? 0;
    final lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lockoutUntilMs);

    if (lockoutUntilMs > 0 && DateTime.now().isBefore(lockoutUntil)) {
      final remaining = lockoutUntil.difference(DateTime.now());
      return PinLockStatus(
        isLocked: true,
        remainingTime: remaining,
        attemptsRemaining: 0,
        message:
            'Too many failed attempts. Try again in ${_formatDuration(remaining)}',
      );
    }

    if (lockoutUntilMs > 0) {
      await _clearLockout();
    }

    final attempts = await _getRecentAttempts();
    final attemptsRemaining = maxAttempts - attempts;

    return PinLockStatus(
      isLocked: false,
      remainingTime: Duration.zero,
      attemptsRemaining: attemptsRemaining,
      message: attemptsRemaining <= 2
          ? 'Warning: $attemptsRemaining attempts remaining'
          : null,
    );
  }

  Future<PinLockStatus> recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();

    int attempts = prefs.getInt(_keyAttempts) ?? 0;
    final lastAttemptMs = prefs.getInt(_keyLastAttempt) ?? 0;

    if (lastAttemptMs > 0) {
      final lastAttempt = DateTime.fromMillisecondsSinceEpoch(lastAttemptMs);
      final windowEnd =
          lastAttempt.add(const Duration(minutes: attemptWindowMinutes));

      if (DateTime.now().isAfter(windowEnd)) {
        attempts = 0;
      }
    }

    attempts++;
    await prefs.setInt(_keyAttempts, attempts);
    await prefs.setInt(_keyLastAttempt, DateTime.now().millisecondsSinceEpoch);

    debugPrint('🔐 SecurityService: Failed attempt #$attempts');

    if (attempts >= maxAttempts) {
      final lockoutUntil =
          DateTime.now().add(const Duration(minutes: lockoutMinutes));
      await prefs.setInt(_keyLockoutUntil, lockoutUntil.millisecondsSinceEpoch);

      debugPrint('🔒 SecurityService: Lockout activated until $lockoutUntil');

      return const PinLockStatus(
        isLocked: true,
        remainingTime: Duration(minutes: lockoutMinutes),
        attemptsRemaining: 0,
        message:
            'Account locked for $lockoutMinutes minutes due to too many failed attempts.',
      );
    }

    final attemptsRemaining = maxAttempts - attempts;
    return PinLockStatus(
      isLocked: false,
      remainingTime: Duration.zero,
      attemptsRemaining: attemptsRemaining,
      message: attemptsRemaining <= 2
          ? 'Warning: $attemptsRemaining attempts remaining before lockout'
          : 'Incorrect PIN. $attemptsRemaining attempts remaining.',
    );
  }

  Future<void> recordSuccessfulAttempt() async {
    await _clearLockout();
    debugPrint('✅ SecurityService: Successful PIN entry, counter reset');
  }

  Future<int> _getRecentAttempts() async {
    final prefs = await SharedPreferences.getInstance();

    final attempts = prefs.getInt(_keyAttempts) ?? 0;
    final lastAttemptMs = prefs.getInt(_keyLastAttempt) ?? 0;

    if (lastAttemptMs == 0) return 0;

    final lastAttempt = DateTime.fromMillisecondsSinceEpoch(lastAttemptMs);
    final windowEnd =
        lastAttempt.add(const Duration(minutes: attemptWindowMinutes));

    if (DateTime.now().isAfter(windowEnd)) {
      await prefs.setInt(_keyAttempts, 0);
      return 0;
    }

    return attempts;
  }

  Future<void> _clearLockout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAttempts);
    await prefs.remove(_keyLockoutUntil);
    await prefs.remove(_keyLastAttempt);
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    }
    return '${duration.inSeconds} second${duration.inSeconds == 1 ? '' : 's'}';
  }

  Future<void> adminResetLockout() async {
    await _clearLockout();
    debugPrint('🔓 SecurityService: Admin reset lockout');
  }

  // =====================================================
  // SESSION SECURITY
  // =====================================================

  static const Duration sessionTimeout = Duration(minutes: 30);

  DateTime? _lastActivity;
  Timer? _sessionTimer;
  VoidCallback? _onSessionExpired;

  void startSessionMonitoring({required VoidCallback onExpired}) {
    _onSessionExpired = onExpired;
    _lastActivity = DateTime.now();

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkSessionTimeout();
    });

    debugPrint('⏱️ SecurityService: Session monitoring started');
  }

  void recordActivity() {
    _lastActivity = DateTime.now();
  }

  void _checkSessionTimeout() {
    if (_lastActivity == null) return;

    final elapsed = DateTime.now().difference(_lastActivity!);
    if (elapsed > sessionTimeout) {
      debugPrint('⏱️ SecurityService: Session expired');
      _sessionTimer?.cancel();
      _onSessionExpired?.call();
    }
  }

  void stopSessionMonitoring() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _lastActivity = null;
    _onSessionExpired = null;
    debugPrint('⏱️ SecurityService: Session monitoring stopped');
  }

  // =====================================================
  // INPUT SANITIZATION
  // =====================================================

  String sanitizeInput(String input) {
    String sanitized = input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .trim();

    return sanitized;
  }

  bool isValidPinFormat(String pin) {
    return RegExp(r'^\d{4,6}$').hasMatch(pin);
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  bool isWeakPin(String pin) {
    const weakPins = [
      '0000',
      '1111',
      '2222',
      '3333',
      '4444',
      '5555',
      '6666',
      '7777',
      '8888',
      '9999',
      '1234',
      '4321',
      '1212',
      '2121',
      '0123',
      '9876',
      '1010',
      '2020',
      '1122',
      '2233',
    ];

    return weakPins.contains(pin);
  }
}

class PinLockStatus {
  final bool isLocked;
  final Duration remainingTime;
  final int attemptsRemaining;
  final String? message;

  const PinLockStatus({
    required this.isLocked,
    required this.remainingTime,
    required this.attemptsRemaining,
    this.message,
  });
}

enum SecurityEvent {
  loginSuccess,
  loginFailed,
  logoutManual,
  logoutSessionExpired,
  pinEntrySuccess,
  pinEntryFailed,
  pinLockoutTriggered,
  pinLockoutReset,
}

class SecurityAuditLog {
  static void log(SecurityEvent event, {Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('🔐 AUDIT [$timestamp]: ${event.name} ${data ?? ''}');
  }
}
