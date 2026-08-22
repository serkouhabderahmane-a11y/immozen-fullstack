// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:immozen/data/model/agent/agents_properties_models/properties_data.dart';
import 'package:immozen/data/model/system_settings_model.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:immozen/ui/screens/widgets/like_button_widget.dart';
import 'package:immozen/ui/screens/widgets/promoted_widget.dart';
import 'package:immozen/utils/string_extenstion.dart';
import 'package:flutter/material.dart';

class PropertyCard extends StatelessWidget {
  final PropertiesData a;
  final List<PropertyModel>? properties;
  final List<Widget>? addBottom;
  final double? additionalHeight;
  final StatusButton? statusButton;
  final Function(FavoriteType type)? onLikeChange;
  final bool? useRow;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;
  final VoidCallback? onTap;

  const PropertyCard({
    required this.a,
    this.properties,
    super.key,
    this.useRow,
    this.addBottom,
    this.additionalHeight,
    this.onLikeChange,
    this.statusButton,
    this.showDeleteButton,
    this.onDeleteTap,
    this.showLikeButton,
    this.additionalImageWidth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rentPrice = a.price
        .priceFormate(
          // disabled: Constant.isNumberWithSuffix == false,
          context: context,
        )
        .formatAmount(prefix: true);

    return BlocProvider(
      create: (context) => AddToFavoriteCubitCubit(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.5),
        child: Padding(
          padding: const EdgeInsets.only(right: 18, left: 18),
          child: GestureDetector(
            onLongPress: () {
              HelperUtils.share(context, a.id, a.slugId);
            },
            onTap: onTap,
            child: Container(
              height: addBottom == null ? 124 : (124 + (additionalHeight ?? 0)),
              decoration: BoxDecoration(
                border:
                    Border.all(width: 1.5, color: context.color.borderColor),
                color: context.color.backgroundColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Stack(
                                    children: [
                                      UiUtils.getImage(
                                        a.titleImage,
                                        height: statusButton != null ? 90 : 120,
                                        width:
                                            100 + (additionalImageWidth ?? 0),
                                        fit: BoxFit.cover,
                                      ),
                                      // Text(a.promoted.toString()),
                                      if (a.promoted)
                                        const PositionedDirectional(
                                          start: 5,
                                          top: 5,
                                          child: PromotedCard(
                                            type: PromoteCardType.icon,
                                          ),
                                        ),

                                      PositionedDirectional(
                                        bottom: 6,
                                        start: 6,
                                        child: Container(
                                          height: 19,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            color: context.color.secondaryColor
                                                .withOpacity(0.7),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 2,
                                              sigmaY: 3,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  a.propertyType
                                                      .translate(context),
                                                )
                                                    .color(
                                                      context
                                                          .color.textColorDark,
                                                    )
                                                    .bold()
                                                    .size(context.font.smaller),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (statusButton != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                      horizontal: 3,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: statusButton!.color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      width: 80,
                                      height: 120 - 90 - 8,
                                      child: Center(
                                        child: Text(statusButton!.lable)
                                            .size(context.font.small)
                                            .bold()
                                            .color(
                                              statusButton?.textColor ??
                                                  Colors.black,
                                            ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 5,
                                  left: 12,
                                  bottom: 5,
                                  right: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        UiUtils.imageType(
                                          a.category.image,
                                          width: 18,
                                          height: 18,
                                          color: Constant.adaptThemeColorSvg
                                              ? context.color.tertiaryColor
                                              : null,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: Text(
                                            a.category.category,
                                          )
                                              .setMaxLines(lines: 1)
                                              .size(
                                                context.font.small.rf(context),
                                              )
                                              .bold(
                                                weight: FontWeight.w400,
                                              )
                                              .color(
                                                context.color.textLightColor,
                                              ),
                                        ),
                                        if (showLikeButton ?? true)
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color:
                                                  context.color.secondaryColor,
                                              shape: BoxShape.circle,
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color.fromARGB(
                                                    12,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                  offset: Offset(0, 2),
                                                  blurRadius: 15,
                                                ),
                                              ],
                                            ),
                                            child: LikeButtonWidget(
                                              color: context.color.brightness ==
                                                      Brightness.light
                                                  ? Colors.grey.shade100
                                                  : Colors.grey.shade900,
                                              propertyId: a.id,
                                              isFavourite: a.isFavourite,
                                              onLikeChanged: onLikeChange,
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (a.propertyType.toLowerCase() ==
                                        'rent') ...[
                                      Text(
                                        rentPrice,
                                      )
                                          .size(context.font.large)
                                          .color(context.color.tertiaryColor)
                                          .bold(weight: FontWeight.w700)
                                          .setMaxLines(lines: 1),
                                    ] else ...[
                                      if (SystemSetting.numberWithSuffix
                                              .toString() ==
                                          '0')
                                        Text(
                                          a.price
                                              .priceFormate(
                                                disabled: Constant
                                                        .isNumberWithSuffix ==
                                                    false,
                                                context: context,
                                              )
                                              .formatAmount(
                                                prefix: true,
                                              ),
                                        )
                                            .setMaxLines(lines: 1)
                                            .size(context.font.large)
                                            .color(
                                              context.color.tertiaryColor,
                                            )
                                            .bold(weight: FontWeight.w700)
                                      else
                                        Text(
                                          a.price
                                              .priceFormate(
                                                disabled: Constant
                                                        .isNumberWithSuffix ==
                                                    true,
                                                context: context,
                                              )
                                              .formatAmount(),
                                        )
                                            .setMaxLines(lines: 1)
                                            .size(context.font.large)
                                            .color(context.color.tertiaryColor)
                                            .bold(weight: FontWeight.w700),
                                    ],
                                    Text(
                                      a.title.firstUpperCase(),
                                    )
                                        .setMaxLines(lines: 1)
                                        .size(context.font.large)
                                        .color(context.color.textColorDark),
                                    if (a.city != '')
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: context.color.textLightColor,
                                          ),
                                          Expanded(
                                            child: Text(
                                              a.city.trim(),
                                            ).setMaxLines(lines: 1).color(
                                                  context.color.textLightColor,
                                                ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (useRow == false || useRow == null) ...addBottom ?? [],

                      if (useRow == true) ...{Row(children: addBottom ?? [])},

                      // ...addBottom ?? []
                    ],
                  ),
                  if (showDeleteButton ?? false)
                    PositionedDirectional(
                      top: 32 * 2,
                      end: 12,
                      child: InkWell(
                        onTap: () {
                          onDeleteTap?.call();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: context.color.secondaryColor,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(33, 0, 0, 0),
                                offset: Offset(0, 2),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: FittedBox(
                              fit: BoxFit.none,
                              child: SvgPicture.asset(
                                AppIcons.bin,
                                colorFilter: ColorFilter.mode(
                                  context.color.tertiaryColor,
                                  BlendMode.srcIn,
                                ),
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatusButton {
  final String lable;
  final Color color;
  final Color? textColor;

  StatusButton({
    required this.lable,
    required this.color,
    this.textColor,
  });
}
