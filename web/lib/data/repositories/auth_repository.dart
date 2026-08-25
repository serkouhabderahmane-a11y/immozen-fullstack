import 'dart:developer';

import 'package:immozen/exports/main_export.dart';

enum LoginType {
  google('0'),
  phone('1'),
  email('3'),
  apple('2');

  const LoginType(this.value);

  final String value;
}

class AuthRepository {
  Future<Map<String, dynamic>> loginWithApi({
    required LoginType type,
    required String? phone,
    required String uid,
    String? email,
    String? name,
    String? password,
  }) async {
    Map<String, String> parameters;

    if (type == LoginType.email) {
      parameters = {
        'type': '3',
        'auth_id': email ?? "",
        'password': password ?? '',
      };
    } else {
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
    log('Login parameters: $parameters');
    final response = await Api.post(
      url: Api.apiLogin,
      parameter: parameters,
      useAuthToken: false,
    );
    log('Login response: $response');
    return {
      'token': response['token'],
      'data': response['data'],
    };
  }

  Future<void> beforeLogout() async {
    try {
      log('beforeLogout called (FCM removed - no-op)');
    } catch (e) {
      log('Error in beforeLogout: $e');
    }
  }
}
