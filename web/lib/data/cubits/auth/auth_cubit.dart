import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:immozen/app/routes.dart';
import 'package:immozen/data/helper/custom_exception.dart';
import 'package:immozen/utils/Extensions/extensions.dart';
import 'package:immozen/utils/api.dart';
import 'package:immozen/utils/helper_utils.dart';
import 'package:immozen/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthProgress extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  Authenticated(this.isAuthenticated);
  bool isAuthenticated = false;
}

class AuthFailure extends AuthState {
  AuthFailure(this.errorMessage);
  final String errorMessage;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void checkIsAuthenticated() {
    if (HiveUtils.isUserAuthenticated()) {
      emit(Authenticated(true));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> updateFCM(BuildContext context) async {
    try {
      log('updateFCM called (FCM removed - no-op)');
    } catch (e) {
      log('Error in updateFCM: $e');
    }
  }

  Future<Map<String, dynamic>> updateUserData(
    BuildContext context, {
    String? name,
    String? email,
    String? address,
    File? fileUserimg,
    String? fcmToken,
    String? notification,
    double? latitude,
    double? longitude,
    String? city,
    String? state,
    String? phone,
    String? country,
  }) async {
    final parameters = <String, dynamic>{
      Api.name: name ?? '',
      Api.email: email ?? '',
      Api.address: address ?? '',
      Api.fcmId: fcmToken ?? '',
      'mobile': phone,
      Api.notification: notification,
      'city': city ?? HiveUtils.getCityName(),
      'state': state ?? HiveUtils.getStateName(),
      'country': country ?? HiveUtils.getCountryName(),
    };
    if (fileUserimg != null) {
      parameters['profile'] = await MultipartFile.fromFile(fileUserimg.path);
    }

    if (latitude != null && longitude != null) {
      parameters.addAll({'latitude': latitude, 'longitude': longitude});
    }

    final response = await Api.post(
      url: Api.apiUpdateProfile,
      parameter: parameters,
    );

    if (!response[Api.error]) {
      await HiveUtils.setUserData(response['data']);
      checkIsAuthenticated();
    } else {
      throw CustomException(response[Api.message]);
    }
    return response;
  }

  Future<void> getUserById(
    BuildContext context,
  ) async {
    final body = <String, String>{};

    var response = await HelperUtils.sendApiRequest(
      Api.apigetUserbyId,
      body,
      false,
      context,
    );

    Future.delayed(
      Duration.zero,
      () async {
        response = await HelperUtils.sendApiRequest(
          Api.apiUpdateProfile,
          body,
          true,
          context,
        );
      },
    );

    final getdata = json.decode(response);

    if (getdata != null) {
      if (!getdata[Api.error]) {
        checkIsAuthenticated();
      } else {
        throw CustomException(getdata[Api.message]);
      }
    } else {
      Future.delayed(
        Duration.zero,
        () {
          throw CustomException('nodatafound'.translate(context));
        },
      );
    }
  }

  Future<void> signOut(BuildContext context) async {
    if ((state as Authenticated).isAuthenticated) {
      HiveUtils.logoutUser(context, onLogout: () {
                    Navigator.pushReplacementNamed(context, Routes.login);
                  }, isRedirect: true);
      emit(Unauthenticated());
    }
  }
}
