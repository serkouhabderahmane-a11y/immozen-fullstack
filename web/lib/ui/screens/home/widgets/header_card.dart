import 'package:immozen/ui/screens/home/home_screen.dart';
import 'package:immozen/utils/Extensions/extensions.dart';
import 'package:immozen/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class TitleHeader extends StatelessWidget {
  const TitleHeader({
    required this.title,
    super.key,
    this.onSeeAll,
    this.enableShowAll,
  });
  final String title;
  final VoidCallback? onSeeAll;
  final bool? enableShowAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 20,
        bottom: 16,
        start: sidePadding,
        end: sidePadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title)
                .bold(weight: FontWeight.w700)
                .color(context.color.textColorDark)
                .size(context.font.large)
                .setMaxLines(lines: 1),
          ),
          if (enableShowAll ?? true)
            GestureDetector(
              onTap: () {
                onSeeAll?.call();
              },
              child: Text(UiUtils.translate(context, 'seeAll'))
                  .size(context.font.small)
                  .color(context.color.textLightColor)
                  .bold(weight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}
