// FILE: test/all_tests.dart
// PROJECT: VillaOS Admin Panel
// DESCRIPTION: Main test runner - executes all test suites
// ═══════════════════════════════════════════════════════════════════════════════
//
// RUN ALL TESTS:
//   flutter test
//
// RUN SPECIFIC TEST FILE:
//   flutter test test/services/auth_service_test.dart
//
// RUN WITH COVERAGE:
//   flutter test --coverage
//   genhtml coverage/lcov.info -o coverage/html
//   open coverage/html/index.html
//
// ═══════════════════════════════════════════════════════════════════════════════

// Import all test files
import 'services/auth_service_test.dart' as auth_service_tests;
import 'services/revenue_service_test.dart' as revenue_service_tests;
import 'services/cache_service_test.dart' as cache_service_tests;
import 'models/booking_model_test.dart' as booking_model_tests;
import 'models/unit_model_test.dart' as unit_model_tests;
import 'widgets/login_screen_test.dart' as login_screen_tests;
import 'integration/auth_flow_test.dart' as auth_flow_tests;

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICE TESTS
  // ═══════════════════════════════════════════════════════════════════════════
  auth_service_tests.main();
  revenue_service_tests.main();
  cache_service_tests.main();

  // ═══════════════════════════════════════════════════════════════════════════
  // MODEL TESTS
  // ═══════════════════════════════════════════════════════════════════════════
  booking_model_tests.main();
  unit_model_tests.main();

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET TESTS
  // ═══════════════════════════════════════════════════════════════════════════
  login_screen_tests.main();

  // ═══════════════════════════════════════════════════════════════════════════
  // INTEGRATION TESTS
  // ═══════════════════════════════════════════════════════════════════════════
  auth_flow_tests.main();
}
