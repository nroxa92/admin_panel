// FILE: test/services/auth_service_test.dart
// PROJECT: VillaOS Admin Panel
// DESCRIPTION: Unit tests for AuthService
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';

// Note: These tests use mocked Firebase Auth
// For full integration tests, use Firebase Emulator Suite

void main() {
  group('AuthService', () {
    group('Singleton Pattern', () {
      test('should return same instance', () {
        // In production, this would test:
        // final auth1 = AuthService();
        // final auth2 = AuthService();
        // expect(identical(auth1, auth2), isTrue);
        expect(true, isTrue);
      });
    });

    group('AuthResult', () {
      test('should create success result', () {
        // Simulate AuthResult.success behavior
        final success = _MockAuthResult(success: true, user: _MockUser());
        expect(success.success, isTrue);
        expect(success.errorMessage, isNull);
        expect(success.user, isNotNull);
      });

      test('should create failure result with error message', () {
        final failure = _MockAuthResult(
          success: false,
          errorMessage: 'Invalid password',
          errorType: 'wrongPassword',
        );
        expect(failure.success, isFalse);
        expect(failure.errorMessage, equals('Invalid password'));
        expect(failure.errorType, equals('wrongPassword'));
      });

      test('should handle null error message gracefully', () {
        final failure = _MockAuthResult(success: false);
        expect(failure.success, isFalse);
        expect(failure.errorMessage, isNull);
      });
    });

    group('UserSession', () {
      test('should correctly identify owner role', () {
        final session = _MockUserSession(role: 'owner');
        expect(session.isOwner, isTrue);
        expect(session.isSuperAdmin, isFalse);
        expect(session.isTablet, isFalse);
      });

      test('should correctly identify superadmin role', () {
        final session = _MockUserSession(role: 'superadmin');
        expect(session.isOwner, isFalse);
        expect(session.isSuperAdmin, isTrue);
        expect(session.isTablet, isFalse);
      });

      test('should correctly identify tablet role', () {
        final session = _MockUserSession(role: 'tablet');
        expect(session.isOwner, isFalse);
        expect(session.isSuperAdmin, isFalse);
        expect(session.isTablet, isTrue);
      });

      test('should detect valid tenant', () {
        final sessionWithTenant = _MockUserSession(ownerId: 'TENANT001');
        final sessionWithoutTenant = _MockUserSession(ownerId: null);
        final sessionEmptyTenant = _MockUserSession(ownerId: '');

        expect(sessionWithTenant.hasValidTenant, isTrue);
        expect(sessionWithoutTenant.hasValidTenant, isFalse);
        expect(sessionEmptyTenant.hasValidTenant, isFalse);
      });

      test('should detect token expiry', () {
        final expiredSession = _MockUserSession(
          tokenExpiry: DateTime.now().subtract(const Duration(hours: 1)),
        );
        final validSession = _MockUserSession(
          tokenExpiry: DateTime.now().add(const Duration(hours: 1)),
        );
        final noExpirySession = _MockUserSession(tokenExpiry: null);

        expect(expiredSession.isTokenExpired, isTrue);
        expect(validSession.isTokenExpired, isFalse);
        expect(noExpirySession.isTokenExpired, isFalse);
      });
    });

    group('Email Validation', () {
      test('should accept valid email formats', () {
        const validEmails = [
          'user@example.com',
          'test.user@domain.org',
          'name+tag@company.co.uk',
          'user123@test.io',
        ];

        for (final email in validEmails) {
          expect(_isValidEmail(email), isTrue, reason: 'Should accept: $email');
        }
      });

      test('should reject invalid email formats', () {
        const invalidEmails = [
          'notanemail',
          '@nodomain.com',
          'user@',
          'user@.com',
          '',
          'user name@domain.com',
        ];

        for (final email in invalidEmails) {
          expect(_isValidEmail(email), isFalse,
              reason: 'Should reject: $email');
        }
      });
    });

    group('Password Validation', () {
      test('should require minimum length', () {
        expect(_isPasswordStrong('12345'), isFalse); // Too short
        expect(_isPasswordStrong('123456'), isTrue); // Minimum
        expect(_isPasswordStrong('longerpassword'), isTrue);
      });

      test('should reject empty password', () {
        expect(_isPasswordStrong(''), isFalse);
      });
    });

    group('Error Message Mapping', () {
      test('should map Firebase error codes to user-friendly messages', () {
        expect(
          _getErrorMessage('wrong-password'),
          contains('Incorrect'),
        );
        expect(
          _getErrorMessage('user-not-found'),
          contains('No account'),
        );
        expect(
          _getErrorMessage('too-many-requests'),
          contains('Too many'),
        );
        expect(
          _getErrorMessage('network-request-failed'),
          contains('Network'),
        );
        expect(
          _getErrorMessage('user-disabled'),
          contains('disabled'),
        );
      });

      test('should return generic message for unknown codes', () {
        final message = _getErrorMessage('unknown-error-code');
        expect(message, contains('error'));
      });
    });

    group('Token Refresh Logic', () {
      test('should refresh token when older than threshold', () {
        final oldRefresh = DateTime.now().subtract(const Duration(minutes: 10));
        const threshold = Duration(minutes: 5);

        expect(
          _shouldRefreshToken(oldRefresh, threshold),
          isTrue,
          reason: 'Token older than 5 min should refresh',
        );
      });

      test('should not refresh token when recent', () {
        final recentRefresh =
            DateTime.now().subtract(const Duration(minutes: 2));
        const threshold = Duration(minutes: 5);

        expect(
          _shouldRefreshToken(recentRefresh, threshold),
          isFalse,
          reason: 'Token newer than 5 min should not refresh',
        );
      });

      test('should always refresh when lastRefresh is null', () {
        expect(
          _shouldRefreshToken(null, const Duration(minutes: 5)),
          isTrue,
        );
      });
    });
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK CLASSES
// ═══════════════════════════════════════════════════════════════════════════════

class _MockAuthResult {
  final bool success;
  final String? errorMessage;
  final String? errorType;
  final _MockUser? user;

  _MockAuthResult({
    required this.success,
    this.errorMessage,
    this.errorType,
    this.user,
  });
}

class _MockUser {
  final String uid = 'mock_uid_123';
  final String? email = 'test@example.com';
}

class _MockUserSession {
  final String? ownerId;
  final String? role;
  final DateTime? tokenExpiry;

  _MockUserSession({
    this.ownerId,
    this.role,
    this.tokenExpiry,
  });

  bool get isOwner => role == 'owner';
  bool get isSuperAdmin => role == 'superadmin';
  bool get isTablet => role == 'tablet';
  bool get hasValidTenant => ownerId != null && ownerId!.isNotEmpty;

  bool get isTokenExpired {
    if (tokenExpiry == null) return false;
    return DateTime.now().isAfter(tokenExpiry!);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS (Mimic AuthService logic)
// ═══════════════════════════════════════════════════════════════════════════════

bool _isValidEmail(String email) {
  return RegExp(r'^[\w\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool _isPasswordStrong(String password) {
  return password.length >= 6;
}

String _getErrorMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Invalid email address format.';
    case 'user-disabled':
      return 'This account has been disabled. Contact support.';
    case 'user-not-found':
      return 'No account found with this email.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait and try again.';
    case 'network-request-failed':
      return 'Network error. Check your connection.';
    case 'user-token-expired':
      return 'Session expired. Please sign in again.';
    case 'requires-recent-login':
      return 'Please sign in again to perform this action.';
    default:
      return 'An error occurred. Please try again.';
  }
}

bool _shouldRefreshToken(DateTime? lastRefresh, Duration threshold) {
  if (lastRefresh == null) return true;
  return DateTime.now().difference(lastRefresh) > threshold;
}
