import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/utils/logger.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(firebaseAuth: FirebaseAuth.instance);
});

class AuthRepository {
  AuthRepository({required FirebaseAuth firebaseAuth}) : _auth = firebaseAuth;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('Email sign-in attempt for ${email.trim()}');
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e, s) {
      Logger.error('Email sign-in failed', e, s);
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      Logger.info('Email sign-up attempt for ${email.trim()}');
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e, s) {
      Logger.error('Email sign-up failed', e, s);
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Logger.info('Password reset email sent for ${email.trim()}');
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e, s) {
      Logger.error('Password reset failed', e, s);
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      Logger.info('Google sign-in attempt started');
      final account = await GoogleSignIn.instance.authenticate();
      final googleAuth = account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message:
              'Google did not return an ID token. Add your Android SHA-1 in '
              'Firebase Console and download an updated google-services.json.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      Logger.info('Google sign-in successful for ${account.email}');
      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e, s) {
      Logger.error('Google sign-in failed', e, s);
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Google sign-in was cancelled',
        );
      }
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: e.description ?? 'Google sign-in failed',
      );
    } on FirebaseAuthException catch (e, s) {
      Logger.error('Firebase credential failed', e, s);
      rethrow;
    }
  }

  Future<void> signOut() async {
    Logger.info('Signing out user');
    await Future.wait([
      _auth.signOut(),
      GoogleSignIn.instance.signOut(),
    ]);
  }
}
