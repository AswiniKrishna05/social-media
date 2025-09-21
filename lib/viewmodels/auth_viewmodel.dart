import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/auth_state.dart';
import '../services/auth_service.dart';

/// ViewModel for handling authentication state and operations
class AuthViewModel extends ChangeNotifier {
  AuthState _authState = const AuthState.initial();
  bool _isLoading = false;

  // Getters
  AuthState get authState => _authState;
  bool get isLoading => _isLoading;
  User? get currentUser => _authState.user;
  bool get isAuthenticated => _authState.isAuthenticated;
  String? get errorMessage => _authState.errorMessage;

  /// Initialize authentication state from local storage
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      final user = AuthService.getCurrentUser();
      if (user != null) {
        _authState = AuthState.authenticated(user);
      } else {
        _authState = const AuthState.unauthenticated();
      }
    } catch (e) {
      _authState = AuthState.error('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _authState = const AuthState.loading();

    try {
      final result = await AuthService.signIn(
        email: email,
        password: password,
      );
      _authState = result;
    } catch (e) {
      _authState = AuthState.error('Sign in failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up with email, username, and password
  Future<void> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _authState = const AuthState.loading();

    try {
      final result = await AuthService.signUp(
        email: email,
        username: username,
        password: password,
      );
      _authState = result;
    } catch (e) {
      _authState = AuthState.error('Sign up failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _setLoading(true);

    try {
      final result = await AuthService.signOut();
      _authState = result;
    } catch (e) {
      _authState = AuthState.error('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error message
  void clearError() {
    if (_authState.hasError) {
      _authState = _authState.copyWith(errorMessage: null);
      notifyListeners();
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    return AuthService.isValidEmail(email);
  }

  /// Validate password strength
  bool isValidPassword(String password) {
    return AuthService.isValidPassword(password);
  }

  /// Validate username format
  bool isValidUsername(String username) {
    return AuthService.isValidUsername(username);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

}
