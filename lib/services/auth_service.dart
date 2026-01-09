// FILE: lib/services/auth_service.dart
// PROJECT: VillaOS Admin Panel
// VERSION: 2.1.0 - Phase 5 Enterprise Security
// STATUS: PRODUCTION READY
// ═══════════════════════════════════════════════════════════════════════════════
// DESCRIPTION: Enterprise-grade authentication service with:
//   • Singleton pattern for consistent state
//   • JWT token management with refresh
//   • Custom claims access (ownerId, role)
//   • Session management and validation
//   • Password operations (reset, change)
//   • Re-authentication for sensitive operations
//   • Comprehensive error handling
//   • Localized error messages
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

/// Authentication error types for granular error handling
enum AuthErrorType {
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  weakPassword,
  operationNotAllowed,
  tooManyRequests,
  networkError,
  tokenExpired,
  sessionExpired,
  requiresRecentLogin,
  unknown,
}

/// Authentication result wrapper
class AuthResult {
  final bool success;
  final String? errorMessage;
  final AuthErrorType? errorType;
  final User? user;

  const AuthResult._({
    required this.success,
    this.errorMessage,
    this.errorType,
    this.user,
  });

  factory AuthResult.success(User? user) => AuthResult._(
        success: true,
        user: user,
      );

  factory AuthResult.failure(String message, AuthErrorType type) =>
      AuthResult._(
        success: false,
        errorMessage: message,
        errorType: type,
      );
}

/// User session data including custom claims
class UserSession {
  final String uid;
  final String email;
  final String? displayName;
  final String? ownerId;
  final String? role;
  final DateTime? tokenExpiry;
  final bool emailVerified;

  const UserSession({
    required this.uid,
    required this.email,
    this.displayName,
    this.ownerId,
    this.role,
    this.tokenExpiry,
    this.emailVerified = false,
  });

  bool get isOwner => role == 'owner';
  bool get isSuperAdmin => role == 'superadmin';
  bool get isTablet => role == 'tablet';
  bool get hasValidTenant => ownerId != null && ownerId!.isNotEmpty;

  bool get isTokenExpired {
    if (tokenExpiry == null) return false;
    return DateTime.now().isAfter(tokenExpiry!);
  }

  @override
  String toString() =>
      'UserSession(uid: $uid, email: $email, ownerId: $ownerId, role: $role)';
}

/// Enterprise-grade authentication service
class AuthService {
  // ═══════════════════════════════════════════════════════════════════════════
  // SINGLETON PATTERN
  // ═══════════════════════════════════════════════════════════════════════════

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE FIELDS
  // ═══════════════════════════════════════════════════════════════════════════

  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserSession? _cachedSession;
  DateTime? _lastTokenRefresh;
  Timer? _tokenRefreshTimer;

  // Token refresh interval (45 minutes - tokens expire at 60 min)
  static const Duration _tokenRefreshInterval = Duration(minutes: 45);

  // Session validity check interval
  static const Duration _sessionCheckInterval = Duration(minutes: 5);

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream of ID token changes (includes custom claims updates)
  Stream<User?> get idTokenChanges => _auth.idTokenChanges();

  /// Current Firebase user (nullable)
  User? get currentUser => _auth.currentUser;

  /// Check if user is currently signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Get current user's email
  String? get currentEmail => _auth.currentUser?.email;

  /// Get current user's UID
  String? get currentUid => _auth.currentUser?.uid;

  /// Get cached session (call refreshSession() first for fresh data)
  UserSession? get session => _cachedSession;

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTHENTICATION METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sign in with email and password
  /// Returns [AuthResult] with success status and optional error details
  Future<AuthResult> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      // Refresh session data after successful login
      await refreshSession();

      // Start token refresh timer
      _startTokenRefreshTimer();

      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        _getLocalizedErrorMessage(e.code),
        _mapFirebaseErrorToType(e.code),
      );
    } catch (e) {
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
        AuthErrorType.unknown,
      );
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _stopTokenRefreshTimer();
    _cachedSession = null;
    _lastTokenRefresh = null;
    await _auth.signOut();
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        _getLocalizedErrorMessage(e.code),
        _mapFirebaseErrorToType(e.code),
      );
    } catch (e) {
      return AuthResult.failure(
        'Failed to send password reset email.',
        AuthErrorType.unknown,
      );
    }
  }

  /// Change password (requires recent login)
  Future<AuthResult> changePassword(
      String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return AuthResult.failure(
        'No user signed in.',
        AuthErrorType.userNotFound,
      );
    }

    try {
      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        _getLocalizedErrorMessage(e.code),
        _mapFirebaseErrorToType(e.code),
      );
    } catch (e) {
      return AuthResult.failure(
        'Failed to change password.',
        AuthErrorType.unknown,
      );
    }
  }

  /// Re-authenticate user (for sensitive operations)
  Future<AuthResult> reauthenticate(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return AuthResult.failure(
        'No user signed in.',
        AuthErrorType.userNotFound,
      );
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        _getLocalizedErrorMessage(e.code),
        _mapFirebaseErrorToType(e.code),
      );
    } catch (e) {
      return AuthResult.failure(
        'Re-authentication failed.',
        AuthErrorType.unknown,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOKEN & SESSION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get fresh ID token (for API calls)
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      return null;
    }
  }

  /// Get ID token result with claims
  Future<IdTokenResult?> getIdTokenResult({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      return await user.getIdTokenResult(forceRefresh);
    } catch (e) {
      return null;
    }
  }

  /// Refresh and cache session data (including custom claims)
  Future<UserSession?> refreshSession() async {
    final user = _auth.currentUser;
    if (user == null) {
      _cachedSession = null;
      return null;
    }

    try {
      // Force token refresh to get latest claims
      final tokenResult = await user.getIdTokenResult(true);
      final claims = tokenResult.claims ?? {};

      _cachedSession = UserSession(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        ownerId: claims['ownerId'] as String?,
        role: claims['role'] as String?,
        tokenExpiry: tokenResult.expirationTime,
        emailVerified: user.emailVerified,
      );

      _lastTokenRefresh = DateTime.now();

      return _cachedSession;
    } catch (e) {
      return null;
    }
  }

  /// Get owner ID from custom claims
  Future<String?> getOwnerId() async {
    // Return cached if recent
    if (_cachedSession != null && !_shouldRefreshToken()) {
      return _cachedSession!.ownerId;
    }

    final session = await refreshSession();
    return session?.ownerId;
  }

  /// Get user role from custom claims
  Future<String?> getRole() async {
    if (_cachedSession != null && !_shouldRefreshToken()) {
      return _cachedSession!.role;
    }

    final session = await refreshSession();
    return session?.role;
  }

  /// Check if current user is super admin
  Future<bool> isSuperAdmin() async {
    final role = await getRole();
    return role == 'superadmin';
  }

  /// Check if current user is owner
  Future<bool> isOwner() async {
    final role = await getRole();
    return role == 'owner';
  }

  /// Validate current session is still valid
  Future<bool> validateSession() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Reload user to check if account is still active
      await user.reload();

      // Check token validity
      final token = await user.getIdToken();
      return token != null;
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  bool _shouldRefreshToken() {
    if (_lastTokenRefresh == null) return true;
    return DateTime.now().difference(_lastTokenRefresh!) >
        _sessionCheckInterval;
  }

  void _startTokenRefreshTimer() {
    _stopTokenRefreshTimer();
    _tokenRefreshTimer = Timer.periodic(_tokenRefreshInterval, (_) async {
      await refreshSession();
    });
  }

  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  /// Map Firebase error codes to AuthErrorType
  AuthErrorType _mapFirebaseErrorToType(String code) {
    switch (code) {
      case 'invalid-email':
        return AuthErrorType.invalidEmail;
      case 'user-disabled':
        return AuthErrorType.userDisabled;
      case 'user-not-found':
        return AuthErrorType.userNotFound;
      case 'wrong-password':
        return AuthErrorType.wrongPassword;
      case 'email-already-in-use':
        return AuthErrorType.emailAlreadyInUse;
      case 'weak-password':
        return AuthErrorType.weakPassword;
      case 'operation-not-allowed':
        return AuthErrorType.operationNotAllowed;
      case 'too-many-requests':
        return AuthErrorType.tooManyRequests;
      case 'network-request-failed':
        return AuthErrorType.networkError;
      case 'user-token-expired':
        return AuthErrorType.tokenExpired;
      case 'requires-recent-login':
        return AuthErrorType.requiresRecentLogin;
      default:
        return AuthErrorType.unknown;
    }
  }

  /// Get localized error message for Firebase error codes
  String _getLocalizedErrorMessage(String code) {
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
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'user-token-expired':
        return 'Session expired. Please sign in again.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check and try again.';
      case 'account-exists-with-different-credential':
        return 'Account exists with different sign-in method.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Dispose resources (call when app closes)
  void dispose() {
    _stopTokenRefreshTimer();
    _cachedSession = null;
  }
}
