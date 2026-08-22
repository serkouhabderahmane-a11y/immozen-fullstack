import 'package:immozen/app/routes.dart';
import 'package:immozen/ui/screens/home/home_screen.dart';
import 'package:immozen/utils/AppIcon.dart';
import 'package:immozen/utils/Extensions/extensions.dart';
import 'package:immozen/utils/responsiveSize.dart';
import 'package:immozen/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildSearchIcon() {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: UiUtils.getSvg(
          AppIcons.search,
          color: context.color.tertiaryColor,
        ),
      );
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: sidePadding, vertical: 15),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.searchScreenRoute,
                arguments: {'autoFocus': true, 'openFilterScreen': false},
              );
            },
            child: AbsorbPointer(
              child: Container(
                width: 285.rw(
                  context,
                ),
                height: 50.rh(
                  context,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.5,
                    color: context.color.borderColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: context.color.secondaryColor,
                ),
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    border: InputBorder.none, //OutlineInputBorder()
                    fillColor: Theme.of(context).colorScheme.secondaryColor,
                    hintText: UiUtils.translate(context, 'searchHintLbl'),
                    prefixIcon: buildSearchIcon(),
                    prefixIconConstraints:
                        const BoxConstraints(minHeight: 5, minWidth: 5),
                  ),
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                  },
                  onTap: () {
                    //change prefix icon color to primary
                  },
                ),
              ),
            ),
          ),
          /*const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.propertyMapScreen);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              width: 50.rw(context),
              height: 50.rh(context),
              decoration: BoxDecoration(
                border:
                    Border.all(width: 1.5, color: context.color.borderColor),
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: UiUtils.getSvg(
                AppIcons.propertyMap,
                color: context.color.tertiaryColor,
              ),
            ),
          ),*/
        ],
      ),
    );
  }
}
