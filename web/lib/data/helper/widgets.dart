import 'package:immozen/utils/Extensions/extensions.dart';
import 'package:immozen/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Widgets {
  static bool isLoaderShowing = false;
  static Future<void> showLoader(BuildContext context) async {
    if (isLoaderShowing == true) return;

    isLoaderShowing = true;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.black.withOpacity(0),
          ),
          child: SafeArea(
            child: WillPopScope(
              child: Center(
                child: UiUtils.progress(
                  normalProgressColor: context.color.tertiaryColor,
                ),
              ),
              onWillPop: () {
                return Future(
                  () => false,
                );
              },
            ),
          ),
        );
      },
    );
  }

  static void hideLoder(BuildContext context) {
    if (!isLoaderShowing) return;
    isLoaderShowing = false;
    Navigator.of(context).pop();
  }

  static Center noDataFound(String errorMsg) {
    return Center(child: Text(errorMsg));
  }
}
