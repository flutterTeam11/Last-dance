import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../cubit/auth_cubit.dart';
import 'widgets/auth_text_field.dart';

class NewPasswordScreen extends StatelessWidget {
  final String oobCode;
  const NewPasswordScreen({super.key, required this.oobCode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: _NewPasswordView(oobCode: oobCode),
    );
  }
}

class _NewPasswordView extends StatefulWidget {
  final String oobCode;
  const _NewPasswordView({required this.oobCode});

  @override
  State<_NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<_NewPasswordView> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onContinue(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      showSnakBar(context, 'Passwords do not match.', isError: true);
      return;
    }
    context.read<AuthCubit>().confirmPasswordReset(
      code: widget.oobCode,
      newPassword: _newPasswordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          showSnakBar(context, state.message, isError: true);
        } else if (state is AuthSuccess) {
          showSnakBar(context, 'Password updated successfully!');
          context.go('/sign-in');
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
                    'Create a new Password',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Your new password must be different from\nprevious used passwords',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 28.h),
                  AuthTextField(
                    controller: _newPasswordController,
                    hint: 'New Password',
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
                  SizedBox(height: 200.h),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
