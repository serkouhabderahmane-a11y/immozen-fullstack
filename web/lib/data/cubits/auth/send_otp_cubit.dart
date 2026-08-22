// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:immozen/data/repositories/auth_repository.dart';

import 'package:immozen/exports/main_export.dart';

String verificationID = '';

abstract class SendOtpState {}

class SendOtpInitial extends SendOtpState {}

class SendOtpInProgress extends SendOtpState {}

class SendOtpSuccess extends SendOtpState {
  final String verificationId;
  SendOtpSuccess({
    required this.verificationId,
  });
}

class SendOtpFailure extends SendOtpState {
  final String errorMessage;

  SendOtpFailure(this.errorMessage);
}

class SendOtpCubit extends Cubit<SendOtpState> {
  SendOtpCubit() : super(SendOtpInitial());

  final AuthRepository _authRepository = AuthRepository();
  Future<void> sendFirebaseOTP({required String phoneNumber}) async {
    emit(SendOtpInProgress()); print("22222222222222222222222222222");
    await _authRepository.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        verificationID = verificationId;
        emit(SendOtpSuccess(verificationId: verificationId));
      },
      onError: (e) {
        emit(SendOtpFailure(e.toString()));
      },
    ); print("3333333333333333333333333333333333333333333333");
  }

  Future<void> sendTwilioOTP({required String phoneNumber}) async {
    emit(SendOtpInProgress());

    await _authRepository.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        verificationID = verificationId;
        emit(SendOtpSuccess(verificationId: verificationId));
      },
      onError: (e) {
        emit(SendOtpFailure(e.toString()));
      },
    );
  }

  void setToInitial() {
    emit(SendOtpInitial());
  }
}
