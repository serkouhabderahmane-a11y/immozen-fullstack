import 'package:immozen/utils/AppIcon.dart';
import 'package:immozen/utils/Extensions/extensions.dart';
import 'package:immozen/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key, this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: SizedBox(
          height: context.screenHeight,
          width: context.screenWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                // width: 100,
                // height: 150,
                child: UiUtils.getSvg(AppIcons.no_internet),
              ),
              const SizedBox(
                height: 20,
              ),
              Text('noInternet'.translate(context))
                  .size(context.font.extraLarge)
                  .color(context.color.tertiaryColor)
                  .bold(weight: FontWeight.w600),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: context.screenWidth * 0.8,
                child: Text(
                  UiUtils.translate(context, 'noInternetErrorMsg'),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              TextButton(
                onPressed: onRetry,
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(
                    context.color.tertiaryColor.withOpacity(0.2),
                  ),
                ),
                child: Text(UiUtils.translate(context, 'retry'))
                    .color(context.color.tertiaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
