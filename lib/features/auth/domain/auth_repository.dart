import 'package:dartz/dartz.dart';
import 'package:graduatio_project/core/error/failure.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, void>> signUp({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, void>> signIn({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, void>> signInWithGoogle();

  Future<Either<AuthFailure, void>> sendPasswordResetEmail({
    required String email,
  });

  Future<Either<AuthFailure, void>> confirmPasswordReset({
    required String code,
    required String newPassword,
  });
}
