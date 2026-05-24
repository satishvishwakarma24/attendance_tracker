import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import '../../../common/widgets/module_responsive.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.isSignUp,
    required this.onSubmit,
    this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool isSignUp;
  final VoidCallback onSubmit;
  final VoidCallback? onForgotPassword;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Email Address',
            style: text.labelLarge?.copyWith(fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            style: text.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: colors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'example@company.com',
              prefixIcon: const Icon(Icons.email_outlined),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              }
              if (!RegExp(r'^.+@.+\..+$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          Text(
            'Password',
            style: text.labelLarge?.copyWith(fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            style: text.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: colors.onSurface,
            ),
            onFieldSubmitted: (_) {
              if (!widget.isLoading) widget.onSubmit();
            },
            decoration: InputDecoration(
              hintText: 'Enter account password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  size: 22.sp,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          // if (!widget.isSignUp && widget.onForgotPassword != null) ...[
          //   Align(
          //     alignment: Alignment.centerRight,
          //     child: TextButton(
          //       onPressed: widget.isLoading ? null : widget.onForgotPassword,
          //       child: Text(
          //         'Forgot password?',
          //         style: text.labelLarge?.copyWith(
          //           fontSize: 13.sp,
          //           color: colors.primary,
          //         ),
          //       ),
          //     ),
          //   ),
          //   SizedBox(height: 8.h),
          // ],
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onSubmit,
            style: context.appTheme.elevatedButtonTheme.style?.copyWith(
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(vertical: 16.h),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            child: widget.isLoading
                ? SizedBox(
                    height: 20.w,
                    width: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.onPrimary,
                    ),
                  )
                : Text(
                    widget.isSignUp ? 'Create Account' : 'Sign In',
                    style: text.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      color: colors.onPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
