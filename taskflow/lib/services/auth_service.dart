import 'dart:async';
import '../models/app_user.dart';

class AuthService {
  // Hard-coded failing credentials to demo error states
  static const _badEmail = 'fail@test.com';
  static const _badPassword = 'fail123';

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    _currentUser = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: email.split('@').first,
    );
    return _currentUser!;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (email == _badEmail || password == _badPassword) {
      throw AuthException('Invalid email or password. Try a different one.');
    }
    _currentUser = AppUser(
      id: 'user_demo',
      email: email,
      name: email.split('@').first,
    );
    return _currentUser!;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
