import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);

  final AuthService _service;

  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _error;
  bool _loading = false;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void _setLoading(bool v) {
    _loading = v;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _loading = false;
    notifyListeners();
  }

  Future<bool> signUp({required String email, required String password}) async {
    _setLoading(true);
    try {
      _user = await _service.signUp(email: email, password: password);
      _status = AuthStatus.authenticated;
      _loading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      _user = await _service.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      _loading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _service.sendPasswordResetEmail(email);
      _loading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _setError('Could not send reset email. Please try again.');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
