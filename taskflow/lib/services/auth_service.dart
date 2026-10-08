import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';

const String _webClientId =
    '88516661803-cpckpdqopf2lvk33gkomqt2fm1pg7dtr.apps.googleusercontent.com';

class AuthService {
  AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn =
          googleSignIn ??
          (kIsWeb ? GoogleSignIn(clientId: _webClientId) : GoogleSignIn());

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapFirebaseUser(user);
  }

  Stream<AppUser?> get authStateChanges => _auth.authStateChanges().map(
    (u) => u == null ? null : _mapFirebaseUser(u),
  );

  AppUser _mapFirebaseUser(User user) =>
      AppUser(id: user.uid, email: user.email ?? '', name: user.displayName);

  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('Could not create account');
      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('Could not sign in');
      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // On Web: Use Firebase Auth's native popup to bypass origin-mismatch on localhost
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        provider.setCustomParameters({'prompt': 'select_account'});
        final result = await _auth.signInWithPopup(provider);
        final user = result.user;
        if (user == null) return null;
        return _mapFirebaseUser(user);
      } else {
        // On Android / iOS: Use native Google Play Services sign-in with SHA-1
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          // User aborted the prompt
          return null;
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final result = await _auth.signInWithCredential(credential);
        final user = result.user;
        if (user == null) throw const AuthException('Google sign in failed');
        return _mapFirebaseUser(user);
      }
    } on FirebaseAuthException catch (e) {
      // Gracefully handle user cancelling the popup
      if (e.code == 'popup-closed-by-user' || e.code == 'canceled') {
        return null;
      }
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      final str = e.toString().toLowerCase();
      if (str.contains('popup_closed') ||
          str.contains('canceled') ||
          str.contains('cancelled')) {
        return null;
      }
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  Future<void> signOut() async {
    if (kIsWeb) {
      await _auth.signOut();
    } else {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'No user found for that email address.',
      'wrong-password' => 'Incorrect password provided.',
      'invalid-credential' => 'Invalid email or password.',
      'email-already-in-use' => 'An account already exists for that email.',
      'invalid-email' => 'The email address is invalid.',
      'weak-password' => 'The password provided is too weak.',
      'network-request-failed' =>
        'Network error. Please check your connection.',
      _ => e.message ?? 'An unexpected authentication error occurred.',
    };
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
