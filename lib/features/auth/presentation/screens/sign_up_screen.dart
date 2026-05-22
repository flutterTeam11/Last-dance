import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../cubit/auth_cubit.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/social_sign_in_button.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onContinue(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      showSnakBar(context, 'Passwords do not match.', isError: true);
      return;
    }
    context.read<AuthCubit>().signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          showSnakBar(context, state.message, isError: true);
        } else if (state is OtpSent) {
          context.push('/sign-in');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Join the mission to save lives\none tap at the time',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 28.h),
                  Row(
                    children: [
                      Expanded(
                        child: AuthTextField(
                          controller: _firstNameController,
                          hint: 'First Name',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AuthTextField(
                          controller: _lastNameController,
                          hint: 'Last Name',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  AuthTextField(
                    controller: _emailController,
                    hint: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 14.h),
                  AuthTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                  ),
                  SizedBox(height: 14.h),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    hint: 'Confirm Password',
                    obscureText: true,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 28.h),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return GradientButton(
                        text: state is AuthLoading ? 'Loading...' : 'continue',
                        onPressed: state is AuthLoading
                            ? () {}
                            : () => _onContinue(context),
                        width: double.infinity,
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  const _OrDivider(),
                  SizedBox(height: 16.h),
                  SocialSignInButton(
                    assetPath: 'assets/icons/google.svg',
                    label: 'Continue with Google',
                    onPressed: () =>
                        context.read<AuthCubit>().signInWithGoogle(),
                  ),
                  SizedBox(height: 12.h),
                  SocialSignInButton(
                    assetPath: 'assets/icons/apple.svg',
                    label: 'Continue with Apple',
                    onPressed: () {},
                  ),
                  SizedBox(height: 28.h),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => context.go('/sign-in'),
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text('or', style: Theme.of(context).textTheme.bodyMedium),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
