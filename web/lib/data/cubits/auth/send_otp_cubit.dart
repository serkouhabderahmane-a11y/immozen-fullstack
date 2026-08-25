// ignore_for_file: public_member_api_docs, sort_constructors_first

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

  Future<void> sendFirebaseOTP({required String phoneNumber}) async {
    emit(SendOtpFailure('Phone OTP login is no longer supported'));
  }

  Future<void> sendTwilioOTP({required String phoneNumber}) async {
    emit(SendOtpFailure('Phone OTP login is no longer supported'));
  }

  void setToInitial() {
    emit(SendOtpInitial());
  }
}
