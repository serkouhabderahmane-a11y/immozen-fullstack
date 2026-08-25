abstract class MLoginState {}

class MProgress extends MLoginState {}

class MVerificationPending extends MLoginState {
  MVerificationPending();
}

class MSuccess extends MLoginState {
  MSuccess(this.credentials, {required this.type});
  final String type;
  final dynamic credentials;
}

class MFail extends MLoginState {
  MFail(this.error);
  final dynamic error;
}
