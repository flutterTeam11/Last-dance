import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*
 * CustomException class
 * represents a custom exception with an error message
 */
class CustomFailure {
  final String errMessage;
  CustomFailure({required this.errMessage});
}

/*
 * ServerFailure class
 * extends CustomFailure
 * includes factory constructors to create instances from DioException and HTTP response
 */

class ServerFailure extends CustomFailure {
  ServerFailure({required super.errMessage});
  factory ServerFailure.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure(errMessage: 'Connection timeout with API');
      case DioExceptionType.sendTimeout:
        return ServerFailure(errMessage: 'Failed to send request to API');
      case DioExceptionType.receiveTimeout:
        return ServerFailure(errMessage: 'Failed to receive response from API');
      case DioExceptionType.badCertificate:
        return ServerFailure(errMessage: 'Bad certificate received');
      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final data = dioException.response?.data;
        if (statusCode != null && data != null) {
          return ServerFailure.fromResponse(statusCode, data);
        }
        return ServerFailure(
          errMessage: 'Invalid response received. Please try again.',
        );
      case DioExceptionType.cancel:
        return ServerFailure(
          errMessage: 'Request was cancelled. Please try again.',
        );
      case DioExceptionType.connectionError:
        return ServerFailure(
          errMessage: 'Internet connection failed. Please try again.',
        );
      case DioExceptionType.unknown:
        return ServerFailure(errMessage: 'Unexpected error. Please try again.');
      // ignore: unreachable_switch_default
      default:
        return ServerFailure(
          errMessage: 'An error occurred. Please try again.',
        );
    }
  }
  factory ServerFailure.fromResponse(
    int statusCode,
    Map<String, dynamic> responseData,
  ) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      final errorMessage = _safeGet(
        responseData,
        'error.message',
        'Authentication failed. Please check your credentials.',
      );
      return ServerFailure(errMessage: errorMessage);
    } else if (statusCode == 404) {
      return ServerFailure(
        errMessage: 'The requested resource was not found. Please try later.',
      );
    } else if (statusCode == 500) {
      return ServerFailure(
        errMessage: 'Server error occurred. Please try later.',
      );
    } else {
      return ServerFailure(errMessage: 'Unexpected error. Please try again.');
    }
  }

  static String _safeGet(
    Map<String, dynamic> data,
    String path,
    String defaultValue,
  ) {
    try {
      final parts = path.split('.');
      dynamic result = data;
      for (var part in parts) {
        if (result is Map<String, dynamic>) {
          result = result[part];
        } else {
          return defaultValue;
        }
      }
      return result?.toString() ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
}

/*
 * AuthFailure class
 * extends CustomFailure
 * includes factory constructors to handle FirebaseAuthException with specific error codes
 * maps Firebase auth errors to clear, user-friendly messages
 */
class AuthFailure extends CustomFailure {
  AuthFailure({required super.errMessage});

  factory AuthFailure.fromFirebaseAuthException(
    FirebaseAuthException authException,
  ) {
    final code = authException.code.toLowerCase().trim();

    switch (code) {
      case 'user-not-found':
        return AuthFailure(
          errMessage: 'No account found with this email. Please sign up first.',
        );
      case 'wrong-password':
        return AuthFailure(errMessage: 'Incorrect password. Please try again.');
      case 'invalid-email':
        return AuthFailure(
          errMessage: 'Invalid email address. Please check and try again.',
        );
      case 'user-disabled':
        return AuthFailure(
          errMessage:
              'This account has been disabled. Contact support for help.',
        );
      case 'too-many-requests':
        return AuthFailure(
          errMessage: 'Too many login attempts. Please try again later.',
        );
      case 'operation-not-allowed':
        return AuthFailure(
          errMessage: 'This operation is not allowed. Please contact support.',
        );
      case 'email-already-in-use':
        return AuthFailure(
          errMessage: 'Email already in use. Please use a different email.',
        );
      case 'weak-password':
        return AuthFailure(
          errMessage: 'Password is too weak. Please use a stronger password.',
        );
      case 'requires-recent-login':
        return AuthFailure(errMessage: 'Please log in again to continue.');
      case 'account-exists-with-different-credential':
        return AuthFailure(
          errMessage: 'An account already exists with this email.',
        );
      case 'invalid-credential':
        return AuthFailure(
          errMessage:
              'Invalid credentials provided. Please check and try again.',
        );
      case 'network-request-failed':
        return AuthFailure(
          errMessage: 'Network error. Please check your internet connection.',
        );
      case 'session-cookie-expired':
        return AuthFailure(errMessage: 'Session expired. Please log in again.');
      case 'uid-already-exists':
        return AuthFailure(
          errMessage: 'User ID already exists. Please try again.',
        );
      default:
        return AuthFailure(
          errMessage:
              'Authentication failed. ${authException.message ?? 'Please try again.'}',
        );
    }
  }

  factory AuthFailure.fromGenericError(dynamic error) {
    return AuthFailure(
      errMessage: error.toString().isNotEmpty
          ? error.toString()
          : 'Authentication error occurred. Please try again.',
    );
  }
}
