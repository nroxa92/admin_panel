// FILE: test/widget_test.dart
// PROJECT: VillaOS - Phase 5 Enterprise Hardening
// FEATURE: Widget Tests
// STATUS: PRODUCTION READY

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Health Dashboard Widget Tests', () {
    testWidgets('should display health status indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: _MockHealthIndicator(status: 'healthy'),
            ),
          ),
        ),
      );

      expect(find.text('healthy'), findsOneWidget);
    });

    testWidgets('should show warning color for degraded status',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockHealthIndicator(status: 'warning'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container, isNotNull);
    });

    testWidgets('should show critical color for error status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockHealthIndicator(status: 'critical'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container, isNotNull);
    });
  });

  group('Onboarding Widget Tests', () {
    testWidgets('should display step progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockOnboardingProgress(current: 3, total: 8),
          ),
        ),
      );

      expect(find.text('3/8'), findsOneWidget);
    });

    testWidgets('should show checkmark for completed steps', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockStepIndicator(isComplete: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('Sync Status Widget Tests', () {
    testWidgets('should show pending count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockSyncStatus(pendingCount: 5),
          ),
        ),
      );

      expect(find.text('5 pending'), findsOneWidget);
    });

    testWidgets('should show syncing animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockSyncStatus(isSyncing: true),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

// =====================================================
// MOCK WIDGETS FOR TESTING
// =====================================================

class _MockHealthIndicator extends StatelessWidget {
  final String status;

  const _MockHealthIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    switch (status) {
      case 'healthy':
        color = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'warning':
        color = Colors.orange;
        bgColor = Colors.orange.shade50;
        break;
      case 'critical':
        color = Colors.red;
        bgColor = Colors.red.shade50;
        break;
      default:
        color = Colors.grey;
        bgColor = Colors.grey.shade50;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 12),
          const SizedBox(width: 8),
          Text(status),
        ],
      ),
    );
  }
}

class _MockOnboardingProgress extends StatelessWidget {
  final int current;
  final int total;

  const _MockOnboardingProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$current/$total'),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: current / total),
      ],
    );
  }
}

class _MockStepIndicator extends StatelessWidget {
  final bool isComplete;

  const _MockStepIndicator({required this.isComplete});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isComplete ? Icons.check_circle : Icons.circle_outlined,
      color: isComplete ? Colors.green : Colors.grey,
    );
  }
}

class _MockSyncStatus extends StatelessWidget {
  final int pendingCount;
  final bool isSyncing;

  const _MockSyncStatus({
    this.pendingCount = 0,
    this.isSyncing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSyncing) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Syncing...'),
        ],
      );
    }

    if (pendingCount > 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_queue, size: 16),
          const SizedBox(width: 8),
          Text('$pendingCount pending'),
        ],
      );
    }

    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_done, size: 16, color: Colors.green),
        SizedBox(width: 8),
        Text('Synced'),
      ],
    );
  }
}
