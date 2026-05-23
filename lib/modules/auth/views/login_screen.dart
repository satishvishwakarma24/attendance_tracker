import 'package:attendance_tracker/modules/auth/views/widgets/google_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '/config/constant/app_config.dart';
import '/config/routes/routes_name.dart';
import '/core/theme/app_theme.dart';
import '/core/utils/logger.dart';
import '/data/repositories/auth_repository.dart';
import '/data/repositories/user_repository.dart';
import '/modules/auth/views/widgets/signin_form.dart';
import '../../common/widgets/module_responsive.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _authErrorMessage(FirebaseAuthException e) {
    final message = e.message ?? '';
    if (message.contains('CONFIGURATION_NOT_FOUND')) {
      return 'Firebase Android setup is incomplete. Add your debug SHA-1 in '
          'Firebase Console and replace google-services.json, then rebuild.';
    }

    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'sign-in-cancelled':
        return 'Google sign-in was cancelled.';
      case 'google-sign-in-failed':
        return e.message ?? 'Google sign-in failed.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'unknown':
        return message.isNotEmpty ? message : 'Authentication failed.';
      default:
        return message.isNotEmpty ? message : 'Authentication failed.';
    }
  }

  String _googleSignInErrorMessage(GoogleSignInException e) {
    if (e.code == GoogleSignInExceptionCode.clientConfigurationError) {
      return 'Google Sign-In is not configured. Set AppConfig.googleWebClientId '
          'to your Firebase Web client ID.';
    }
    return e.description ?? 'Google sign-in failed.';
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 14.sp, color: colors.onPrimary),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? colors.error : colors.primary,
      ),
    );
  }

  Future<void> _afterAuth(User user) async {
    await ref.read(userRepositoryProvider).ensureUserDocument(user);
    if (!mounted) return;
    context.go(RoutesName.dashboard);
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = ref.read(authRepositoryProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final cred = _isSignUp
          ? await auth.signUpWithEmail(email: email, password: password)
          : await auth.signInWithEmail(email: email, password: password);
      final user = cred.user;
      if (user != null) {
        await _afterAuth(user);
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(_authErrorMessage(e), isError: true);
    } catch (e, s) {
      Logger.error('Email auth failed', e, s);
      _showSnack('Something went wrong. Try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final cred = await ref.read(authRepositoryProvider).signInWithGoogle();
      final user = cred.user;
      if (user != null) {
        await _afterAuth(user);
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(_authErrorMessage(e), isError: true);
    } on GoogleSignInException catch (e, s) {
      Logger.error('Google sign-in failed', e, s);
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return;
      }
      _showSnack(_googleSignInErrorMessage(e), isError: true);
    } catch (e, s) {
      Logger.error('Google sign-in failed', e, s);
      _showSnack('Google sign-in failed.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: ModuleResponsive.screenPaddingWide,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    color: colors.onPrimary,
                    size: 36.sp,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppConfig.appName,
                textAlign: TextAlign.center,
                style: text.headlineMedium?.copyWith(fontSize: 28.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                'Sign in to access your geofenced workspace',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 32.h),
              SignInForm(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                isLoading: _isLoading,
                isSignUp: _isSignUp,
                onSubmit: _handleEmailAuth,
              ),
              SizedBox(height: 24.h),
              GoogleSignInButton(
                isEnabled: !_isLoading,
                onPressed: _handleGoogleSignIn,
              ),
              SizedBox(height: 32.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: text.bodyMedium?.copyWith(fontSize: 14.sp),
                  ),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp ? 'Sign In' : 'Sign Up',
                      style: text.labelLarge?.copyWith(
                        fontSize: 14.sp,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
