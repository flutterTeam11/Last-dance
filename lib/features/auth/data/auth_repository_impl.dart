import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graduatio_project/core/error/failure.dart';
import 'package:graduatio_project/core/utils/local_storage_service.dart';

import 'package:graduatio_project/features/auth/domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  final LocalStorageService _localStorage;

  AuthRepositoryImpl({
    required this._firebaseAuth,
    required this._googleSignIn,
    required this._firestore,
    required this._localStorage,
  });

  @override
  Future<Either<AuthFailure, void>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firebaseAuth.currentUser?.sendEmailVerification();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthFailure.fromGenericError(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final result = await _onAuthSuccess();
      if (result.isLeft()) return result;
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthFailure.fromGenericError(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Left(AuthFailure(errMessage: 'Google sign-in was cancelled.'));
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
      final result = await _onAuthSuccess();
      if (result.isLeft()) return result;
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthFailure.fromGenericError(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthFailure.fromGenericError(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthFailure.fromGenericError(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> ensureUserDocExists() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Left(AuthFailure(errMessage: 'No user logged in.'));
      }
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          'uid': user.uid,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure.fromGenericError(e));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final localFlag = await _localStorage.getIsLoggedIn();
      if (!localFlag) return false;
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        await _localStorage.setLoggedIn(false);
        return false;
      }
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  Future<Either<AuthFailure, void>> _onAuthSuccess() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return Left(AuthFailure(errMessage: 'Authentication failed.'));
    }
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await _localStorage.setLoggedIn(true);
    return const Right(null);
  }
}
