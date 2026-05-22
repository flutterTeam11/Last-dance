part of 'auth_cubit.dart';

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthSuccess extends AuthState {
  final String message;
  const AuthSuccess({required this.message});
}

final class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState({required this.message});
}

final class OtpSent extends AuthState {
  final String maskedEmail;
  const OtpSent({required this.maskedEmail});
}

final class PasswordResetEmailSent extends AuthState {
  const PasswordResetEmailSent();
}
