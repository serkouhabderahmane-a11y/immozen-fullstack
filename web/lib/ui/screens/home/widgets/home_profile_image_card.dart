import 'package:immozen/data/cubits/system/user_details.dart';
import 'package:immozen/utils/AppIcon.dart';
import 'package:immozen/utils/Extensions/extensions.dart';
import 'package:immozen/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CircularProfileImageWidget extends StatelessWidget {
  const CircularProfileImageWidget({super.key});
  Widget buildDefaultPersonSVG(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: context.color.tertiaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: UiUtils.getSvg(
          AppIcons.defaultPersonLogo,
          color: context.color.tertiaryColor,
          width: 40,
          height: 40,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        margin: const EdgeInsetsDirectional.only(end: 10),
        padding: const EdgeInsets.only(bottom: 5),
        child: FittedBox(
          fit: BoxFit.cover,
          child: GestureDetector(
            child: (context.watch<UserDetailsCubit>().state.user?.profile ?? '')
                    .trim()
                    .isEmpty
                ? FittedBox(
                    fit: BoxFit.none,
                    child: buildDefaultPersonSVG(
                      context,
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    width: 50,
                    height: 50,
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      context.watch<UserDetailsCubit>().state.user?.profile ??
                          '',
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      errorBuilder: (
                        BuildContext context,
                        Object exception,
                        StackTrace? stackTrace,
                      ) {
                        return FittedBox(
                          fit: BoxFit.none,
                          child: buildDefaultPersonSVG(context),
                        );
                      },
                      loadingBuilder: (
                        BuildContext context,
                        Widget? child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null) return child!;
                        return FittedBox(
                          fit: BoxFit.none,
                          child: buildDefaultPersonSVG(context),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
