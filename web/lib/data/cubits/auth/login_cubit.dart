// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:immozen/data/repositories/auth_repository.dart';
import 'package:immozen/utils/hive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginSuccess extends LoginState {
  final bool isProfileCompleted;
  LoginSuccess({
    required this.isProfileCompleted,
  });
}

class LoginFailure extends LoginState {
  final String errorMessage;
  LoginFailure(this.errorMessage);
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final AuthRepository _authRepository = AuthRepository();
  bool isProfileIsCompleted = false;

  Future<void> login({
    String? phoneNumber,
    required String uniqueId,
    required LoginType type,
    countryCode,
    String? email,
    String? name,
    String? password,
  }) async {
    try {
      emit(LoginInProgress());
      final result = await _authRepository.loginWithApi(
          type: type,
          email: email,
          name: name,
          phone: phoneNumber,
          uid: uniqueId,
          password: password);

      ///Storing data to local database {HIVE}
      await HiveUtils.setJWT(result['token']);

      if (result['data']['name'] == '' ||
          result['data']['email'] == '' ||
          result['data']['phone'] == '') {
        await HiveUtils.setProfileNotCompleted();
        isProfileIsCompleted = false;
        final data = result['data'];
        data['countryCode'] = countryCode;
        data['type'] = type.name;
        await HiveUtils.setUserData(data);
      } else {
        isProfileIsCompleted = true;
        final data = result['data'];
        data['countryCode'] = countryCode;
        data['type'] = type.name;

        await HiveUtils.setUserData(data);
      }

      emit(LoginSuccess(isProfileCompleted: isProfileIsCompleted));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
