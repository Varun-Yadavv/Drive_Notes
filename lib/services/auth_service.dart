import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _emailKey = 'email';
  static const String _expiryKey = 'expiry';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive.appdata',
    ],
  );

  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Sign in with Google and request Drive permissions
  static Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('Sign-in canceled by user');
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      await _secureStorage.write(key: _tokenKey, value: googleAuth.accessToken);
      await _secureStorage.write(key: _emailKey, value: googleUser.email);

      final expiryTime = DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch.toString();
      await _secureStorage.write(key: _expiryKey, value: expiryTime);


      return true;
    } catch (e) {
      debugPrint('Sign-in error: $e');
      return false;
    }
  }

  // Check if user is signed in and token is valid
  static Future<bool> isSignedIn() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) return false;

      final expiryString = await _secureStorage.read(key: _expiryKey);
      if (expiryString != null) {
        final expiry = int.parse(expiryString);
        if (DateTime.now().millisecondsSinceEpoch > expiry) {
          return await _refreshToken();
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error checking sign-in status: $e');
      return false;
    }
  }

  static Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      debugPrint('Unexpected error during sign-out: $e');
      return false;
    }
  }

  // Returns an authenticated Dio client
  static Future<Dio?> getAuthenticatedDio() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) return null;

    final dio = Dio(BaseOptions(
      baseUrl: 'https://www.googleapis.com',
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ));

    return dio;
  }

  // Refresh token (if needed)
  static Future<bool> _refreshToken() async {
    try {
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (!isSignedIn) return false;

      final currentUser = _googleSignIn.currentUser;
      if (currentUser == null) return false;

      final googleAuth = await currentUser.authentication;
      await _secureStorage.write(key: _tokenKey, value: googleAuth.accessToken);

      final expiryTime = DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch.toString();
      await _secureStorage.write(key: _expiryKey, value: expiryTime);

      return true;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }
}
