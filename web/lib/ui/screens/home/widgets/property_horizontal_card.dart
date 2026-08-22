// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:immozen/data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:immozen/ui/screens/widgets/like_button_widget.dart';
import 'package:immozen/ui/screens/widgets/promoted_widget.dart';
import 'package:immozen/utils/string_extenstion.dart';
import 'package:flutter/material.dart';

class PropertyHorizontalCard extends StatelessWidget {
  final PropertyModel property;
  final Advertisement? advertisement;
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

  const PropertyHorizontalCard({
    required this.property,
    this.advertisement,
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
  });

  @override
  Widget build(BuildContext context) {
    var rentPrice = property.price!
        .priceFormate(
          disabled: Constant.isNumberWithSuffix == true,
          context: context,
        )
        .formatAmount(prefix: true);

    if (property.rentduration != '' && property.rentduration != null) {
      rentPrice =
          ('$rentPrice / ') + (property.rentduration ?? '').translate(context);
    }

    return BlocProvider(
      create: (context) => AddToFavoriteCubitCubit(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.5),
        child: GestureDetector(
          onLongPress: () {
            HelperUtils.share(context, property.id!, property.slugId ?? '');
          },
          onTap: () {
            HelperUtils.goToNextPage(
              Routes.propertyDetails,
              context,
              false,
              args: {
                'propertyData': property,
                'propertiesList': properties,
                'fromMyProperty': false,
              },
            );
          },
          child: Container(
            height: addBottom == null ? 124 : (124 + (additionalHeight ?? 0)),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.5,
                color: context.color.borderColor,
              ),
              color: context.color.secondaryColor,
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
                              if (addBottom != null) const SizedBox(height: 5),
                              Row(
                                children: [
                                  if (addBottom != null)
                                    const SizedBox(width: 5),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: UiUtils.getImage(
                                            property.titleImage ?? '',
                                            height: 121,
                                            width: 100 +
                                                (additionalImageWidth ?? 0),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        // Text(property.promoted.toString()),
                                        if (property.promoted ?? false)
                                          PositionedDirectional(
                                            start: addBottom != null ? 10 : 5,
                                            top: addBottom != null ? 10 : 5,
                                            child: const PromotedCard(
                                              type: PromoteCardType.icon,
                                            ),
                                          ),

                                        PositionedDirectional(
                                          bottom: addBottom != null ? 12 : 6,
                                          start: addBottom != null ? 12 : 6,
                                          child: Container(
                                            height: 19,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              color: context
                                                  .color.secondaryColor
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
                                                    property.properyType!
                                                        .translate(context),
                                                  )
                                                      .color(
                                                        context.color
                                                            .textColorDark,
                                                      )
                                                      .bold()
                                                      .size(
                                                        context.font.smaller,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                bottom: 5,
                                right: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      UiUtils.imageType(
                                        property.category?.image ?? '',
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
                                          property.category?.category ?? '',
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
                                          margin: const EdgeInsets.only(top: 8),
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: context.color.secondaryColor,
                                            shape: BoxShape.circle,
                                            boxShadow: const [
                                              BoxShadow(
                                                color:
                                                    Color.fromARGB(12, 0, 0, 0),
                                                offset: Offset(0, 2),
                                                blurRadius: 15,
                                              ),
                                            ],
                                          ),
                                          child: LikeButtonWidget(
                                            propertyId: property.id!,
                                            isFavourite: property.isFavourite!,
                                            onLikeChanged: onLikeChange,
                                          ),
                                        ),
                                      if (showLikeButton == false &&
                                          statusButton == null)
                                        Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          width: 32,
                                          height: 32,
                                          child: const SizedBox(
                                            height: 32,
                                            width: 32,
                                          ),
                                        ),
                                      if (statusButton != null)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 3,
                                            horizontal: 3,
                                          ),
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(top: 8),
                                            decoration: BoxDecoration(
                                              color: statusButton!.color,
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                  if (property.properyType
                                          .toString()
                                          .toLowerCase() ==
                                      'rent') ...[
                                    Text(
                                      rentPrice,
                                    )
                                        .size(context.font.large)
                                        .color(context.color.tertiaryColor)
                                        .bold(weight: FontWeight.w700)
                                        .setMaxLines(lines: 1),
                                  ] else ...[
                                    Text(
                                      property.price!
                                          .priceFormate(
                                            disabled:
                                                Constant.isNumberWithSuffix ==
                                                    false,
                                            context: context,
                                          )
                                          .formatAmount(
                                            prefix: true,
                                          ),
                                    )
                                        .setMaxLines(lines: 1)
                                        .size(context.font.large)
                                        .color(context.color.tertiaryColor)
                                        .bold(weight: FontWeight.w700),
                                  ],
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    property.title!.firstUpperCase(),
                                  )
                                      .setMaxLines(lines: 1)
                                      .size(context.font.large)
                                      .color(context.color.textColorDark),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  if (property.city != '')
                                    Row(
                                      children: [
                                        UiUtils.getSvg(
                                          AppIcons.location,
                                        ),
                                        Expanded(
                                          child: Text(
                                            property.city?.trim() ?? '',
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
    );
  }
}

class MyAdvertisementPropertyHorizontalCard extends StatelessWidget {
  final Advertisement? advertisement;
  final List<Widget>? addBottom;
  final double? additionalHeight;
  final StatusButton? statusButton;
  final Function(FavoriteType type)? onLikeChange;
  final bool? useRow;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;

  const MyAdvertisementPropertyHorizontalCard({
    required this.advertisement,
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
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: GestureDetector(
        onLongPress: () {
          HelperUtils.share(
              context, advertisement!.id!, advertisement!.slugId ?? '');
        },
        onTap: () {},
        child: Container(
          height: addBottom == null ? 124 : (124 + (additionalHeight ?? 0)),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.5,
              color: context.color.borderColor,
            ),
            color: context.color.secondaryColor,
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
                            if (addBottom != null) const SizedBox(height: 5),
                            Row(
                              children: [
                                if (addBottom != null) const SizedBox(width: 5),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: UiUtils.getImage(
                                          advertisement!.titleImage ?? '',
                                          height: 121,
                                          width:
                                              100 + (additionalImageWidth ?? 0),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      PositionedDirectional(
                                        bottom: addBottom != null ? 12 : 6,
                                        start: addBottom != null ? 12 : 6,
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
                                                  advertisement!.propertyType!
                                                      .translate(context),
                                                )
                                                    .color(
                                                      context
                                                          .color.textColorDark,
                                                    )
                                                    .bold()
                                                    .size(
                                                      context.font.smaller,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 12,
                              bottom: 5,
                              right: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    UiUtils.imageType(
                                      advertisement!.category?.image ?? '',
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
                                        advertisement!.category?.category ?? '',
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
                                    if (statusButton != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 3,
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          decoration: BoxDecoration(
                                            color: statusButton!.color,
                                            borderRadius:
                                                BorderRadius.circular(4),
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
                                Text(
                                  advertisement!.price!
                                      .priceFormate(
                                        disabled: Constant.isNumberWithSuffix ==
                                            false,
                                        context: context,
                                      )
                                      .formatAmount(
                                        prefix: true,
                                      ),
                                )
                                    .setMaxLines(lines: 1)
                                    .size(context.font.large)
                                    .color(context.color.tertiaryColor)
                                    .bold(weight: FontWeight.w700),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  advertisement!.title!.firstUpperCase(),
                                )
                                    .setMaxLines(lines: 1)
                                    .size(context.font.large)
                                    .color(context.color.textColorDark),
                                const SizedBox(
                                  height: 5,
                                ),
                                if (advertisement!.city != '')
                                  Row(
                                    children: [
                                      UiUtils.getSvg(
                                        AppIcons.location,
                                      ),
                                      Expanded(
                                        child: Text(
                                          advertisement!.city?.trim() ?? '',
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
