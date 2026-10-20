import 'package:firebase_auth/firebase_auth.dart';

String errorMessage(Object? error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'Incorrect email or password.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
        case 'network-request-failed':
          return 'No internet connection.';
        default:
          return error.message ?? 'Login failed.';
      }
    }
    return error?.toString() ?? 'Something went wrong.';
  }