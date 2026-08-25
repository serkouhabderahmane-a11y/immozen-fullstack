import 'dart:developer';

import 'package:immozen/utils/Login/lib/payloads.dart';
import 'package:immozen/utils/login/lib/login_status.dart';
import 'package:flutter/material.dart';

abstract class LoginSystem {
  BuildContext? context;
  setContext(BuildContext context) {
    this.context = context;
  }

  List<Function(MLoginState fn)> listeners = [];

  void onEvent(MLoginState state);

  void emit(MLoginState state) {
    for (final i in listeners) {
      i.call(state);
    }
    onEvent(state);
  }

  Future<void> requestVerification() async {
    emit(MVerificationPending());
  }

  LoginPayload? payload;

  Future<void> setPayload(LoginPayload payload) async {
    this.payload = payload;
  }

  void init() {}

  Future<dynamic> login();
}

class MAuthentication {
  MAuthentication(this.system, {this.payload});
  LoginPayload? payload;
  final LoginSystem system;

  void init() {
    system.init();
  }

  Future<dynamic>? login() async {
    system.payload = payload;
    final credential = await system.login();
    return credential;
  }
}

class MMultiAuthentication {
  MMultiAuthentication(
    this.systems, {
    this.payload,
  });
  MultiLoginPayload? payload;
  Map<String, LoginSystem> systems;
  String? _selectedLoginSystem;
  void setContext(BuildContext context) {
    for (final element in systems.values) {
      element.setContext(context);
    }
  }

  void init() {
    for (final loginSystem in systems.values) {
      loginSystem.init();
    }
  }

  void requestVerification() {
    systems.forEach((String key, LoginSystem value) async {
      LoginSystem? selectedSystem;
      if (_selectedLoginSystem == key) {
        selectedSystem = systems[key];
        selectedSystem?.payload = payload?.payloads[key];
        await selectedSystem?.requestVerification();
      }
    });
  }

  Future<void> setActive(String key) async {
    _selectedLoginSystem = key;
  }

  void listen(Function(MLoginState state) fn) {
    systems.forEach((String key, LoginSystem value) async {
      systems[key]?.listeners.add(fn);
    });
  }

  Future<dynamic>? login() async {
    if (_selectedLoginSystem == '' || _selectedLoginSystem == null) {
      log('Please select login system using setActive method');
    }
    LoginSystem? selectedSystem;

    systems.forEach((String key, LoginSystem value) async {
      if (_selectedLoginSystem == key) {
        systems[key]?.payload = payload?.payloads[key];
        selectedSystem = systems[key];
      }
    });

    dynamic credential;
    if (selectedSystem != null) {
      credential = await selectedSystem?.login();
    }

    return credential;
  }
}
