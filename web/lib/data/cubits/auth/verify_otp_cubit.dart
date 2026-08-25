// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:immozen/data/repositories/auth_repository.dart';
import 'package:immozen/exports/main_export.dart';

abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpInProgress extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {
  final dynamic credential;
  final String? authId;
  final String? number;
  final String? otp;
  VerifyOtpSuccess({
    this.authId,
    this.number,
    this.otp,
    this.credential,
  });
}

class VerifyOtpFailure extends VerifyOtpState {
  final String errorMessage;

  VerifyOtpFailure(this.errorMessage);
}

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  final AuthRepository _authRepository = AuthRepository();

  VerifyOtpCubit() : super(VerifyOtpInitial());

  Future<void> verifyOTP({
    required String otp,
    String? verificationId,
    String? number,
  }) async {
    try {
      emit(VerifyOtpFailure('Phone OTP login is no longer supported'));
    } catch (e) {
      emit(VerifyOtpFailure(e.toString()));
    }
  }

  void setInitialState() {
    emit(VerifyOtpInitial());
  }
}
