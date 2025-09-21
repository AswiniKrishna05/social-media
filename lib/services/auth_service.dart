import '../models/user.dart';
import '../models/auth_state.dart';
import 'hive_service.dart';

/// Service class for handling authentication operations
class AuthService {
  // Mock users for demonstration (in a real app, this would be from a server)
  static const List<Map<String, String>> _mockUsers = [
    {
      'username': 'john_doe',
      'email': 'john@example.com',
      'password': 'password123',
    },
    {
      'username': 'jane_smith',
      'email': 'jane@example.com',
      'password': 'password123',
    },
    {
      'username': 'demo_user',
      'email': 'demo@example.com',
      'password': 'demo123',
    },
  ];

  /// Sign in with email and password
  static Future<AuthState> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Find user in mock data
      final userData = _mockUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => throw Exception('Invalid credentials'),
      );

      // Check if user exists in local storage
      User? existingUser = HiveService.getAllUsers()
          .where((user) => user.email == email)
          .firstOrNull;

      User user;
      if (existingUser != null) {
        user = existingUser;
      } else {
        // Create new user if not exists
        user = User.create(
          username: userData['username']!,
          email: userData['email']!,
        );
        await HiveService.saveUser(user);
      }

      // Save current user session
      await HiveService.saveCurrentUser(user.id);

      return AuthState.authenticated(user);
    } catch (e) {
      return AuthState.error(e.toString());
    }
  }

  /// Sign up with email, username, and password
  static Future<AuthState> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if user already exists
      final existingUser = HiveService.getAllUsers()
          .where((user) => user.email == email || user.username == username)
          .firstOrNull;

      if (existingUser != null) {
        if (existingUser.email == email) {
          throw Exception('Email already exists');
        } else {
          throw Exception('Username already exists');
        }
      }

      // Create new user
      final user = User.create(
        username: username,
        email: email,
      );

      // Save user to local storage
      await HiveService.saveUser(user);

      // Save current user session
      await HiveService.saveCurrentUser(user.id);

      return AuthState.authenticated(user);
    } catch (e) {
      return AuthState.error(e.toString());
    }
  }

  /// Sign out current user
  static Future<AuthState> signOut() async {
    try {
      await HiveService.clearCurrentUser();
      return const AuthState.unauthenticated();
    } catch (e) {
      return AuthState.error(e.toString());
    }
  }

  /// Get current user from local storage
  static User? getCurrentUser() {
    return HiveService.getCurrentUser();
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return HiveService.isUserLoggedIn();
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Validate username format
  static bool isValidUsername(String username) {
    return username.length >= 3 && RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }
}
