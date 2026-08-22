import 'dart:developer';

import 'package:immozen/exports/main_export.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

enum LoginType {
  google('0'),
  phone('1'),
  email('3'),
  apple('2');

  const LoginType(this.value);

  final String value;
}

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  static int? forceResendingToken;
  Future<Map<String, dynamic>> loginWithApi({
    required LoginType type,
    required String? phone,
    required String uid,
    String? email,
    String? name,
    String? password, // Add password as optional
  }) async {
    Map<String, String> parameters;

    if (type == LoginType.email) {
      // Use the new structure for email/password login
      parameters = {
        'type': type.name,
        'auth_id': email ?? "",
        'password': password ?? '',
      };
    } else {
      // Keep the original login logic for other types (phone, Google, etc.)
      parameters = <String, String>{
        Api.mobile: phone?.replaceAll(' ', '').replaceAll('+', '') ?? '',
        Api.authId: uid,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
        Api.type: type.value,
      };

      if (type == LoginType.phone) {
        parameters.remove('email');
      } else {
        parameters.remove('mobile');
      }
    }
    print(parameters);
    final response = await Api.post(
      url: Api.apiLogin,
      parameter: parameters,
      useAuthToken: false,
    );
    print(response);
    return {
      'token': response['token'],
      'data': response['data'],
    };
  }

  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    Function(dynamic e)? onError,
  }) async {
    if (AppSettings.otpServiceProvider == 'twilio') {
      await Api.get(
        url: Api.apiGetOtp,
        queryParameters: {
          'number': phoneNumber,
        },
      );
      onCodeSent.call(phoneNumber);
    } else if (AppSettings.otpServiceProvider == 'firebase') {
      print("444444444444444444444444444444");
      await FirebaseAuth.instance.verifyPhoneNumber(
        timeout: Duration(
          seconds: Constant.otpTimeOutSecond,
        ),
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          onError?.call(ApiException(e.code));
        },
        codeSent: (String verificationId, int? resendToken) {
          forceResendingToken = resendToken;
          onCodeSent.call(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        forceResendingToken: forceResendingToken,
      );
      print("555555555555555555555555555");
    }
  }

  Future<UserCredential> verifyFirebaseOTP({
    required String otpVerificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: otpVerificationId,
        smsCode: otp,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      throw ApiException(e);
    }
  }

  Future<dynamic> verifyTwilioOTP({
    required String otp,
    required String number,
  }) async {
    try {
      String? authId;
      final credential = await Api.get(
        url: Api.apiVerifyOtp,
        queryParameters: {
          'auth_id': authId,
          'number': number,
          'otp': otp,
        },
      );
      return credential;
    } catch (e) {
      throw ApiException(e);
    }
  }

  Future<void> beforeLogout() async {
    try {
      // Request notification permission (iOS only)
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // iOS: wait for APNS token to be ready
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            log('APNS token not ready. Retrying in 2 seconds...');
            await Future.delayed(Duration(seconds: 2));
            return beforeLogout(); // Retry
          }
        }

        // Get FCM token
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          log('Sending FCM token before logout: $token');

          await Api.post(
            url: Api.apiBeforeLogout,
            parameter: {
              Api.fcmId: token,
            },
          );
        } else {
          log('FCM token is null before logout');
        }
      } else {
        log('Notification permission denied on beforeLogout');
      }
    } catch (e) {
      log('Error in beforeLogout: $e');
    }
  }
}
