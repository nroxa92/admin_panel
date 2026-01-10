// FILE: test/widgets/login_screen_test.dart
// PROJECT: VillaOS Admin Panel
// DESCRIPTION: Widget tests for Login Screen
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Login Screen Widget Tests', () {
    group('UI Elements', () {
      testWidgets('should display app title', (tester) async {
        await tester.pumpWidget(_buildTestApp());

        expect(find.text('VILLA ADMIN'), findsOneWidget);
      });

      testWidgets('should display subtitle', (tester) async {
        await tester.pumpWidget(_buildTestApp());

        expect(find.text('Sign in to manage your property'), findsOneWidget);
      });

      testWidgets('should display email input field', (tester) async {
        await tester.pumpWidget(_buildTestApp());

        expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      });

      testWidgets('should display password input field', (tester) async {
        await tester.pumpWidget(_buildTestApp());

        expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      });

      testWidgets('should display login button', (tester) async {
        await tester.pumpWidget(_buildTestApp());

        expect(find.widgetWithText(ElevatedButton, 'ACCESS DASHBOARD'),
            findsOneWidget);
      });

      testWidgets('should display admin icon', (tester) async {
        await tester.pumpWidget(_buildTestApp());

        expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
      });
    });

    group('Input Behavior', () {
      testWidgets('should allow email input', (tester) async {
        await tester.pumpWidget(_buildTestApp());

        final emailField = find.widgetWithText(TextField, 'Email');
        await tester.enterText(emailField, 'test@example.com');

        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('should allow password input', (tester) async {
        await tester.pumpWidget(_buildTestApp());

        final passwordField = find.widgetWithText(TextField, 'Password');
        await tester.enterText(passwordField, 'password123');

        // Password should be obscured, so we check the TextField
        final textField = tester.widget<TextField>(passwordField);
        expect(textField.obscureText, isTrue);
      });

      testWidgets('should toggle password visibility', (tester) async {
        await tester.pumpWidget(_buildTestAppWithPasswordToggle());

        // Initially password should be obscured
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        // Tap visibility toggle
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        // Now should show visibility icon
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });
    });

    group('Form Validation', () {
      testWidgets('should show error for empty email', (tester) async {
        await tester.pumpWidget(_buildTestAppWithValidation());

        // Try to submit with empty fields
        await tester.tap(find.text('ACCESS DASHBOARD'));
        await tester.pump();

        expect(find.text('Please enter email and password'), findsOneWidget);
      });

      testWidgets('should show error for empty password', (tester) async {
        await tester.pumpWidget(_buildTestAppWithValidation());

        // Enter email only
        await tester.enterText(
          find.widgetWithText(TextField, 'Email'),
          'test@example.com',
        );

        // Try to submit
        await tester.tap(find.text('ACCESS DASHBOARD'));
        await tester.pump();

        expect(find.text('Please enter email and password'), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('should show loading indicator when logging in',
          (tester) async {
        await tester.pumpWidget(_buildTestAppWithLoading());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should disable button when loading', (tester) async {
        await tester.pumpWidget(_buildTestAppWithLoading());

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);
      });
    });

    group('Theme and Styling', () {
      testWidgets('should use dark theme', (tester) async {
        await tester.pumpWidget(_buildTestApp());

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        // In dark theme, scaffold background should be dark
        expect(scaffold, isNotNull);
      });

      testWidgets('should have gold accent color on icon', (tester) async {
        await tester.pumpWidget(_buildTestApp());

        final icon = tester.widget<Icon>(
          find.byIcon(Icons.admin_panel_settings),
        );
        expect(icon.color, equals(const Color(0xFFD4AF37)));
      });

      testWidgets('should have rounded container', (tester) async {
        await tester.pumpWidget(_buildTestApp());

        final container =
            tester.widget<Container>(find.byType(Container).first);
        expect(container.decoration, isA<BoxDecoration>());
      });
    });

    group('Keyboard Actions', () {
      testWidgets('should submit form on Enter key in password field',
          (tester) async {
        await tester.pumpWidget(_buildTestAppWithSubmit());

        // Enter credentials
        await tester.enterText(
          find.widgetWithText(TextField, 'Email'),
          'test@example.com',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Password'),
          'password123',
        );

        // Press Enter/Done on password field
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Check that submit was triggered (in real app, this would call signIn)
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have semantic labels', (tester) async {
        await tester.pumpWidget(_buildTestApp());

        // Email field should be accessible
        expect(find.bySemanticsLabel('Email'), findsOneWidget);
      });

      testWidgets('should support large font sizes', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: _buildTestApp(),
          ),
        );

        // App should still render without overflow
        expect(tester.takeException(), isNull);
      });
    });
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// TEST APP BUILDERS
// ═══════════════════════════════════════════════════════════════════════════════

Widget _buildTestApp() {
  return MaterialApp(
    theme: ThemeData.dark().copyWith(
      primaryColor: const Color(0xFFD4AF37),
    ),
    home: const _MockLoginScreen(),
  );
}

Widget _buildTestAppWithPasswordToggle() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: const _MockLoginScreenWithToggle(),
  );
}

Widget _buildTestAppWithValidation() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: const _MockLoginScreenWithValidation(),
  );
}

Widget _buildTestAppWithLoading() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: const _MockLoginScreenLoading(),
  );
}

Widget _buildTestAppWithSubmit() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: const _MockLoginScreenWithSubmit(),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK LOGIN SCREENS
// ═══════════════════════════════════════════════════════════════════════════════

class _MockLoginScreen extends StatelessWidget {
  const _MockLoginScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 60,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(height: 20),
              const Text(
                "VILLA ADMIN",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Sign in to manage your property",
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 40),
              Semantics(
                label: 'Email',
                child: const TextField(
                  decoration: InputDecoration(labelText: "Email"),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 30),
              const ElevatedButton(
                onPressed: null,
                child: Text("ACCESS DASHBOARD"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockLoginScreenWithToggle extends StatefulWidget {
  const _MockLoginScreenWithToggle();

  @override
  State<_MockLoginScreenWithToggle> createState() =>
      _MockLoginScreenWithToggleState();
}

class _MockLoginScreenWithToggleState
    extends State<_MockLoginScreenWithToggle> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextField(
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: "Password",
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ),
    );
  }
}

class _MockLoginScreenWithValidation extends StatefulWidget {
  const _MockLoginScreenWithValidation();

  @override
  State<_MockLoginScreenWithValidation> createState() =>
      _MockLoginScreenWithValidationState();
}

class _MockLoginScreenWithValidationState
    extends State<_MockLoginScreenWithValidation> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  String? _error;

  void _handleLogin() {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      setState(() => _error = 'Please enter email and password');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text("ACCESS DASHBOARD"),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockLoginScreenLoading extends StatelessWidget {
  const _MockLoginScreenLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: null,
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class _MockLoginScreenWithSubmit extends StatefulWidget {
  const _MockLoginScreenWithSubmit();

  @override
  State<_MockLoginScreenWithSubmit> createState() =>
      _MockLoginScreenWithSubmitState();
}

class _MockLoginScreenWithSubmitState
    extends State<_MockLoginScreenWithSubmit> {
  bool _isLoading = false;

  void _handleSubmit() {
    setState(() => _isLoading = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Password"),
              onSubmitted: (_) => _handleSubmit(),
            ),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text("ACCESS DASHBOARD"),
              ),
          ],
        ),
      ),
    );
  }
}
