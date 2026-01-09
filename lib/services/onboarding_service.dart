// FILE: lib/services/onboarding_service.dart
// PROJECT: VillaOS - Phase 5 Enterprise Hardening
// FEATURE: Enhanced User Onboarding
// STATUS: PRODUCTION READY

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Onboarding Service - Guides new users through setup
class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  static const String _onboardingKey = 'vls_onboarding_state';
  static const String _onboardingVersion = '2.0';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _progressController = StreamController<OnboardingProgress>.broadcast();

  OnboardingState _currentState = OnboardingState.notStarted;
  final Map<OnboardingStep, bool> _completedSteps = {};
  bool _isInitialized = false;

  Stream<OnboardingProgress> get progressStream => _progressController.stream;
  OnboardingState get currentState => _currentState;
  bool get isComplete => _currentState == OnboardingState.completed;
  int get completedStepCount => _completedSteps.values.where((v) => v).length;
  int get totalSteps => OnboardingStep.values.length;
  double get progressPercent => completedStepCount / totalSteps;

  static const List<OnboardingStepInfo> steps = [
    OnboardingStepInfo(
      step: OnboardingStep.welcome,
      title: 'Welcome to VillaOS',
      description: 'Your property management system is ready!',
      icon: 'celebration',
      isRequired: true,
    ),
    OnboardingStepInfo(
      step: OnboardingStep.createUnit,
      title: 'Create Your First Unit',
      description: 'Add a villa, apartment, or room to manage',
      icon: 'home',
      isRequired: true,
    ),
    OnboardingStepInfo(
      step: OnboardingStep.setupHouseRules,
      title: 'Set House Rules',
      description: 'Configure rules guests must accept',
      icon: 'rule',
      isRequired: true,
    ),
    OnboardingStepInfo(
      step: OnboardingStep.addBooking,
      title: 'Add First Booking',
      description: 'Create a test or real booking',
      icon: 'calendar_today',
      isRequired: false,
    ),
    OnboardingStepInfo(
      step: OnboardingStep.configureTablet,
      title: 'Configure Tablet',
      description: 'Set up guest check-in tablet',
      icon: 'tablet',
      isRequired: false,
    ),
    OnboardingStepInfo(
      step: OnboardingStep.inviteCleaner,
      title: 'Add Cleaning Staff',
      description: 'Set up cleaner PIN access',
      icon: 'cleaning_services',
      isRequired: false,
    ),
    OnboardingStepInfo(
      step: OnboardingStep.customizeBranding,
      title: 'Customize Branding',
      description: 'Set your colors and preferences',
      icon: 'palette',
      isRequired: false,
    ),
    OnboardingStepInfo(
      step: OnboardingStep.complete,
      title: 'All Set!',
      description: 'Your system is ready to use',
      icon: 'check_circle',
      isRequired: true,
    ),
  ];

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadState();
    _isInitialized = true;
    debugPrint(
        '✅ OnboardingService: Initialized ($completedStepCount/$totalSteps steps)');
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_onboardingKey);

      if (stateJson != null) {
        final parts = stateJson.split('|');
        if (parts.length >= 2 && parts[0] == _onboardingVersion) {
          final completedIndices =
              parts[1].split(',').where((s) => s.isNotEmpty);
          for (final index in completedIndices) {
            final i = int.tryParse(index);
            if (i != null && i < OnboardingStep.values.length) {
              _completedSteps[OnboardingStep.values[i]] = true;
            }
          }
        }
      }

      _updateState();
    } catch (e) {
      debugPrint('❌ OnboardingService: Failed to load state: $e');
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedIndices = _completedSteps.entries
          .where((e) => e.value)
          .map((e) => OnboardingStep.values.indexOf(e.key).toString())
          .join(',');

      await prefs.setString(
          _onboardingKey, '$_onboardingVersion|$completedIndices');
    } catch (e) {
      debugPrint('❌ OnboardingService: Failed to save state: $e');
    }
  }

  Future<void> completeStep(OnboardingStep step) async {
    _completedSteps[step] = true;
    _updateState();
    await _saveState();
    await _syncToFirestore();

    debugPrint('✅ OnboardingService: Completed step ${step.name}');
  }

  bool isStepComplete(OnboardingStep step) {
    return _completedSteps[step] ?? false;
  }

  OnboardingStep? getNextStep() {
    for (final stepInfo in steps) {
      if (!isStepComplete(stepInfo.step)) {
        return stepInfo.step;
      }
    }
    return null;
  }

  OnboardingStepInfo? getStepInfo(OnboardingStep step) {
    return steps.firstWhere(
      (s) => s.step == step,
      orElse: () => steps.first,
    );
  }

  bool areRequiredStepsComplete() {
    return steps
        .where((s) => s.isRequired)
        .every((s) => isStepComplete(s.step));
  }

  void _updateState() {
    if (_completedSteps.isEmpty) {
      _currentState = OnboardingState.notStarted;
    } else if (areRequiredStepsComplete()) {
      _currentState = OnboardingState.completed;
    } else {
      _currentState = OnboardingState.inProgress;
    }

    _progressController.add(OnboardingProgress(
      state: _currentState,
      completedSteps: completedStepCount,
      totalSteps: totalSteps,
      nextStep: getNextStep(),
      percent: progressPercent,
    ));
  }

  Future<void> autoDetectProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final tokenResult = await user.getIdTokenResult();
      final tenantId = tokenResult.claims?['ownerId'] as String?;
      if (tenantId == null) return;

      final units = await _firestore
          .collection('units')
          .where('ownerId', isEqualTo: tenantId)
          .limit(1)
          .get();

      if (units.docs.isNotEmpty) {
        await completeStep(OnboardingStep.welcome);
        await completeStep(OnboardingStep.createUnit);
      }

      final settings =
          await _firestore.collection('settings').doc(tenantId).get();

      if (settings.exists) {
        final data = settings.data();
        if (data?['houseRules'] != null) {
          await completeStep(OnboardingStep.setupHouseRules);
        }
        if (data?['primaryColor'] != null || data?['language'] != null) {
          await completeStep(OnboardingStep.customizeBranding);
        }
      }

      final bookings = await _firestore
          .collection('bookings')
          .where('ownerId', isEqualTo: tenantId)
          .limit(1)
          .get();

      if (bookings.docs.isNotEmpty) {
        await completeStep(OnboardingStep.addBooking);
      }

      final tablets = await _firestore
          .collection('tablets')
          .where('ownerId', isEqualTo: tenantId)
          .limit(1)
          .get();

      if (tablets.docs.isNotEmpty) {
        await completeStep(OnboardingStep.configureTablet);
      }

      if (areRequiredStepsComplete()) {
        await completeStep(OnboardingStep.complete);
      }

      debugPrint(
          '🔍 OnboardingService: Auto-detected $completedStepCount completed steps');
    } catch (e) {
      debugPrint('❌ OnboardingService: Auto-detect failed: $e');
    }
  }

  Future<void> _syncToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final tokenResult = await user.getIdTokenResult();
      final tenantId = tokenResult.claims?['ownerId'] as String?;
      if (tenantId == null) return;

      await _firestore.collection('settings').doc(tenantId).set({
        'onboarding': {
          'version': _onboardingVersion,
          'state': _currentState.name,
          'completedSteps': _completedSteps.entries
              .where((e) => e.value)
              .map((e) => e.key.name)
              .toList(),
          'progress': progressPercent,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ OnboardingService: Firestore sync failed: $e');
    }
  }

  Future<void> skipOnboarding() async {
    for (final stepInfo in steps) {
      if (stepInfo.isRequired) {
        _completedSteps[stepInfo.step] = true;
      }
    }
    _completedSteps[OnboardingStep.complete] = true;

    _updateState();
    await _saveState();
    await _syncToFirestore();

    debugPrint('⏭️ OnboardingService: Skipped remaining steps');
  }

  Future<void> resetOnboarding() async {
    _completedSteps.clear();
    _currentState = OnboardingState.notStarted;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);

    _updateState();
    debugPrint('🔄 OnboardingService: Reset complete');
  }

  void dispose() {
    _progressController.close();
  }
}

// =====================================================
// DATA MODELS
// =====================================================

enum OnboardingState { notStarted, inProgress, completed }

enum OnboardingStep {
  welcome,
  createUnit,
  setupHouseRules,
  addBooking,
  configureTablet,
  inviteCleaner,
  customizeBranding,
  complete,
}

class OnboardingStepInfo {
  final OnboardingStep step;
  final String title;
  final String description;
  final String icon;
  final bool isRequired;

  const OnboardingStepInfo({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.isRequired,
  });
}

class OnboardingProgress {
  final OnboardingState state;
  final int completedSteps;
  final int totalSteps;
  final OnboardingStep? nextStep;
  final double percent;

  OnboardingProgress({
    required this.state,
    required this.completedSteps,
    required this.totalSteps,
    this.nextStep,
    required this.percent,
  });
}
