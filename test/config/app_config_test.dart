// FILE: test/config/app_config_test.dart
// PROJECT: Vesta Lumina System (VLS)
// VERSION: 3.0.0 - Phase 3 Unit Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:villa_admin/config/app_config.dart';

void main() {
  group('AppConfig', () {
    group('Primary Admin Check', () {
      test('should identify primary admin email', () {
        expect(
          AppConfig.isPrimaryAdmin('vestaluminasystem@gmail.com'),
          isTrue,
        );
      });

      test('should identify primary admin email case-insensitive', () {
        expect(
          AppConfig.isPrimaryAdmin('VESTALUMINASYSTEM@GMAIL.COM'),
          isTrue,
        );
        expect(
          AppConfig.isPrimaryAdmin('VestaLuminaSystem@Gmail.Com'),
          isTrue,
        );
      });

      test('should reject non-primary admin email', () {
        expect(
          AppConfig.isPrimaryAdmin('other@gmail.com'),
          isFalse,
        );
      });

      test('should handle null email', () {
        expect(
          AppConfig.isPrimaryAdmin(null),
          isFalse,
        );
      });

      test('should handle empty email', () {
        expect(
          AppConfig.isPrimaryAdmin(''),
          isFalse,
        );
      });
    });

    group('Constants', () {
      test('should have valid app name', () {
        expect(AppConfig.appName, isNotEmpty);
        expect(AppConfig.appName, equals('VLS Admin Panel'));
      });

      test('should have valid app version', () {
        expect(AppConfig.appVersion, isNotEmpty);
        expect(AppConfig.appVersion, matches(RegExp(r'^\d+\.\d+\.\d+$')));
      });

      test('should have valid Firebase project ID', () {
        expect(AppConfig.firebaseProjectId, isNotEmpty);
        expect(AppConfig.firebaseProjectId, equals('vls-admin'));
      });

      test('should have valid functions region', () {
        expect(AppConfig.functionsRegion, isNotEmpty);
        expect(AppConfig.functionsRegion, equals('europe-west3'));
      });
    });

    group('Security Settings', () {
      test('should have reasonable max PIN attempts', () {
        expect(AppConfig.maxPinAttempts, greaterThan(0));
        expect(AppConfig.maxPinAttempts, lessThanOrEqualTo(10));
      });

      test('should have reasonable lockout duration', () {
        expect(AppConfig.pinLockoutMinutes, greaterThan(0));
        expect(AppConfig.pinLockoutMinutes, lessThanOrEqualTo(60));
      });

      test('should have reasonable session timeout', () {
        expect(AppConfig.sessionTimeoutMinutes, greaterThan(0));
        expect(AppConfig.sessionTimeoutMinutes, lessThanOrEqualTo(120));
      });

      test('should have valid PIN length range', () {
        expect(AppConfig.minPinLength, greaterThan(0));
        expect(AppConfig.maxPinLength, greaterThan(AppConfig.minPinLength));
        expect(AppConfig.maxPinLength, lessThanOrEqualTo(8));
      });
    });

    group('Supported Languages', () {
      test('should have at least one supported language', () {
        expect(AppConfig.supportedLanguages, isNotEmpty);
      });

      test('should include English', () {
        expect(AppConfig.supportedLanguages, contains('en'));
      });

      test('should include Croatian', () {
        expect(AppConfig.supportedLanguages, contains('hr'));
      });

      test('should have valid default language', () {
        expect(AppConfig.defaultLanguage, isNotEmpty);
        expect(
          AppConfig.supportedLanguages,
          contains(AppConfig.defaultLanguage),
        );
      });
    });

    group('Business Rules', () {
      test('should have valid default check-in time', () {
        expect(AppConfig.defaultCheckInTime, isNotEmpty);
        expect(
          AppConfig.defaultCheckInTime,
          matches(RegExp(r'^\d{2}:\d{2}$')),
        );
      });

      test('should have valid default check-out time', () {
        expect(AppConfig.defaultCheckOutTime, isNotEmpty);
        expect(
          AppConfig.defaultCheckOutTime,
          matches(RegExp(r'^\d{2}:\d{2}$')),
        );
      });
    });

    group('UI Settings', () {
      test('should have valid animation duration', () {
        expect(AppConfig.animationDuration.inMilliseconds, greaterThan(0));
        expect(AppConfig.animationDuration.inMilliseconds,
            lessThanOrEqualTo(1000));
      });

      test('should have valid snackbar duration', () {
        expect(AppConfig.snackbarDuration.inSeconds, greaterThan(0));
        expect(AppConfig.snackbarDuration.inSeconds, lessThanOrEqualTo(10));
      });
    });

    group('Backup Settings', () {
      test('should have valid backup retention days', () {
        expect(AppConfig.backupRetentionDays, greaterThan(0));
        expect(AppConfig.backupRetentionDays, lessThanOrEqualTo(365));
      });

      test('should have backup collections defined', () {
        expect(AppConfig.backupCollections, isNotEmpty);
        expect(AppConfig.backupCollections, contains('tenant_links'));
        expect(AppConfig.backupCollections, contains('settings'));
      });
    });
  });
}
