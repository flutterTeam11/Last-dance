import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required this._authRepository}) : super(AuthInitial());

  Future<void> signUp({required String email, required String password}) async {
    emit(AuthLoading());
    final result = await _authRepository.signUp(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => emit(AuthFailureState(message: failure.errMessage)),
      (_) => emit(OtpSent(maskedEmail: _maskEmail(email))),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    final result = await _authRepository.signIn(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => emit(AuthFailureState(message: failure.errMessage)),
      (_) => emit(AuthSuccess(message: 'Welcome back!')),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (failure) => emit(AuthFailureState(message: failure.errMessage)),
      (_) => emit(AuthSuccess(message: 'Welcome!')),
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    emit(AuthLoading());
    final result = await _authRepository.sendPasswordResetEmail(email: email);
    result.fold(
      (failure) => emit(AuthFailureState(message: failure.errMessage)),
      (_) => emit(PasswordResetEmailSent()),
    );
  }

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    emit(AuthLoading());
    final result = await _authRepository.confirmPasswordReset(
      code: code,
      newPassword: newPassword,
    );
    result.fold(
      (failure) => emit(AuthFailureState(message: failure.errMessage)),
      (_) => emit(AuthSuccess(message: 'Password updated!')),
    );
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final masked = name.length <= 2
        ? '${'*' * name.length}@${parts[1]}'
        : '${name.substring(0, 2)}${'*' * (name.length - 2)}@${parts[1]}';
    return masked;
  }
}
