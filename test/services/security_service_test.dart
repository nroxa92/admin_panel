// FILE: test/services/security_service_test.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 3.0.0 - Phase 3 Unit Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:villa_admin/services/security_service.dart';

void main() {
  group('SecurityService', () {
    late SecurityService securityService;

    setUp(() {
      securityService = SecurityService();
    });

    group('Input Sanitization', () {
      test('should remove HTML tags', () {
        const input = '<script>alert("xss")</script>Hello';
        final result = securityService.sanitizeInput(input);
        expect(result, equals('alert("xss")Hello'));
      });

      test('should remove angle brackets', () {
        const input = 'Test <value> here';
        final result = securityService.sanitizeInput(input);
        expect(result, equals('Test value here'));
      });

      test('should remove quotes', () {
        const input = "Test 'single' and \"double\" quotes";
        final result = securityService.sanitizeInput(input);
        expect(result, equals('Test single and double quotes'));
      });

      test('should trim whitespace', () {
        const input = '  Hello World  ';
        final result = securityService.sanitizeInput(input);
        expect(result, equals('Hello World'));
      });

      test('should handle empty string', () {
        final result = securityService.sanitizeInput('');
        expect(result, equals(''));
      });

      test('should handle string with only whitespace', () {
        final result = securityService.sanitizeInput('   ');
        expect(result, equals(''));
      });
    });

    group('PIN Validation', () {
      test('should accept valid 4-digit PIN', () {
        expect(securityService.isValidPinFormat('1234'), isTrue);
      });

      test('should accept valid 6-digit PIN', () {
        expect(securityService.isValidPinFormat('123456'), isTrue);
      });

      test('should reject 3-digit PIN', () {
        expect(securityService.isValidPinFormat('123'), isFalse);
      });

      test('should reject 7-digit PIN', () {
        expect(securityService.isValidPinFormat('1234567'), isFalse);
      });

      test('should reject PIN with letters', () {
        expect(securityService.isValidPinFormat('12ab'), isFalse);
      });

      test('should reject empty PIN', () {
        expect(securityService.isValidPinFormat(''), isFalse);
      });

      test('should reject PIN with special characters', () {
        expect(securityService.isValidPinFormat('12-34'), isFalse);
      });
    });

    group('Weak PIN Detection', () {
      test('should detect all same digits as weak', () {
        expect(securityService.isWeakPin('0000'), isTrue);
        expect(securityService.isWeakPin('1111'), isTrue);
        expect(securityService.isWeakPin('9999'), isTrue);
      });

      test('should detect sequential numbers as weak', () {
        expect(securityService.isWeakPin('1234'), isTrue);
        expect(securityService.isWeakPin('4321'), isTrue);
        expect(securityService.isWeakPin('0123'), isTrue);
      });

      test('should detect common patterns as weak', () {
        expect(securityService.isWeakPin('1212'), isTrue);
        expect(securityService.isWeakPin('2020'), isTrue);
        expect(securityService.isWeakPin('1122'), isTrue);
      });

      test('should not flag strong PIN as weak', () {
        expect(securityService.isWeakPin('7392'), isFalse);
        expect(securityService.isWeakPin('5847'), isFalse);
        expect(securityService.isWeakPin('9163'), isFalse);
      });
    });

    group('Email Validation', () {
      test('should accept valid email', () {
        expect(securityService.isValidEmail('test@example.com'), isTrue);
        expect(securityService.isValidEmail('user.name@domain.org'), isTrue);
        expect(
            securityService.isValidEmail('user-name@sub.domain.com'), isTrue);
      });

      test('should reject invalid email without @', () {
        expect(securityService.isValidEmail('testexample.com'), isFalse);
      });

      test('should reject invalid email without domain', () {
        expect(securityService.isValidEmail('test@'), isFalse);
      });

      test('should reject invalid email without TLD', () {
        expect(securityService.isValidEmail('test@example'), isFalse);
      });

      test('should reject empty email', () {
        expect(securityService.isValidEmail(''), isFalse);
      });

      test('should reject email with spaces', () {
        expect(securityService.isValidEmail('test @example.com'), isFalse);
      });
    });
  });

  group('PinLockStatus', () {
    test('should create locked status correctly', () {
      const status = PinLockStatus(
        isLocked: true,
        remainingTime: Duration(minutes: 15),
        attemptsRemaining: 0,
        message: 'Locked',
      );

      expect(status.isLocked, isTrue);
      expect(status.attemptsRemaining, equals(0));
      expect(status.remainingTime.inMinutes, equals(15));
    });

    test('should create unlocked status correctly', () {
      const status = PinLockStatus(
        isLocked: false,
        remainingTime: Duration.zero,
        attemptsRemaining: 5,
      );

      expect(status.isLocked, isFalse);
      expect(status.attemptsRemaining, equals(5));
      expect(status.message, isNull);
    });
  });

  group('SecurityAuditLog', () {
    test('should log events without throwing', () {
      expect(
        () => SecurityAuditLog.log(SecurityEvent.loginSuccess),
        returnsNormally,
      );
    });

    test('should log events with data without throwing', () {
      expect(
        () => SecurityAuditLog.log(
          SecurityEvent.pinEntryFailed,
          data: {'attempt': 1},
        ),
        returnsNormally,
      );
    });
  });
}
