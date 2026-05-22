part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess({required this.message});
}

final class AuthFailureState extends AuthState {
  final String message;
  AuthFailureState({required this.message});
}

final class OtpSent extends AuthState {
  final String maskedEmail;
  OtpSent({required this.maskedEmail});
}

final class PasswordResetEmailSent extends AuthState {}
