import 'dart:developer';

import 'package:immozen/app/routes.dart';
import 'package:immozen/utils/Extensions/extensions.dart';
import 'package:immozen/utils/hive_utils.dart';
import 'package:flutter/material.dart';

class GuestChecker {
  static final ValueNotifier<bool?> _isGuest =
      ValueNotifier(HiveUtils.isGuest());
  static BuildContext? _context;

  static void set(String from, {required bool isGuest}) {
    _isGuest.value = isGuest;
  }

  static void setContext(BuildContext context) {
    _context = context;
  }

  static void check({required Function() onNotGuest}) {
    if (_context == null) {
      log('please set context');
    }

    if (_isGuest.value == true) {
      _loginBox();
    } else {
      onNotGuest.call();
    }
  }

  static bool get value {
    return _isGuest.value ?? false;
  }

  static ValueNotifier<bool?> listen() {
    return _isGuest;
  }

  static Widget updateUI({
    required Function(bool? isGuest) onChangeStatus,
  }) {
    return ValueListenableBuilder<bool?>(
      valueListenable: _isGuest,
      builder: (context, value, c) {
        return onChangeStatus.call(value);
      },
    );
  }

  static _loginBox() {
    showModalBottomSheet(
      context: _context!,
      backgroundColor: _context?.color.primaryColor.darken(-5),
      enableDrag: false,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('loginIsRequired'.translate(context))
                  .size(context.font.larger),
              const SizedBox(
                height: 5,
              ),
              Text('tapOnLogin'.translate(context)).size(context.font.small),
              const SizedBox(
                height: 10,
              ),
              MaterialButton(
                elevation: 0,
                color: _context?.color.tertiaryColor,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    Routes.login,
                    arguments: {'popToCurrent': true},
                  );
                },
                child: Text('loginNow'.translate(context)).color(
                  _context?.color.buttonColor ?? Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
