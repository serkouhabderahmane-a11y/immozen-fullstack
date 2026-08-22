import 'dart:ui';

import 'package:immozen/data/cubits/favorite/add_to_favorite_cubit.dart';
import 'package:immozen/data/model/property_model.dart';
import 'package:immozen/ui/screens/widgets/like_button_widget.dart';
import 'package:immozen/ui/screens/widgets/promoted_widget.dart';
import 'package:immozen/utils/AppIcon.dart';
import 'package:immozen/utils/Extensions/extensions.dart';
import 'package:immozen/utils/constant.dart';
import 'package:immozen/utils/helper_utils.dart';
import 'package:immozen/utils/string_extenstion.dart';
import 'package:immozen/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class PropertyCardBig extends StatelessWidget {
  const PropertyCardBig({
    required this.property,
    super.key,
    this.onLikeChange,
    this.isFirst,
    this.showEndPadding,
    this.showLikeButton,
  });

  final PropertyModel property;
  final bool? isFirst;
  final bool? showEndPadding;
  final bool? showLikeButton;
  final Function(FavoriteType type)? onLikeChange;

  @override
  Widget build(BuildContext context) {
    var rentPrice = property.price!
        .priceFormate(
          disabled: Constant.isNumberWithSuffix == false,
          context: context,
        )
        .formatAmount(prefix: true);
    if (property.rentduration != '' && property.rentduration != null) {
      rentPrice =
          ('$rentPrice / ') + (property.rentduration ?? '').translate(context);
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: (isFirst ?? false) ? 0 : 5.0,
        end: (showEndPadding ?? true) ? 5.0 : 0,
      ),
      child: GestureDetector(
        onLongPress: () {
          HelperUtils.share(context, property.id!, property.slugId ?? '');
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: context.color.secondaryColor,
            border: Border.all(
              width: 1.5,
              color: context.color.borderColor,
            ),
          ),
          height: 272,
          width: 250,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 147,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: UiUtils.getImage(
                            property.titleImage!,
                            height: 147,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            blurHash: property.titleimagehash,
                          ),
                        ),
                        PositionedDirectional(
                          start: 10,
                          bottom: 10,
                          child: Container(
                            height: 24,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: context.color.secondaryColor.withOpacity(
                                0.7,
                              ),
                              borderRadius: BorderRadius.circular(
                                4,
                              ),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Center(
                                  child: Text(
                                    property.properyType!
                                        .toLowerCase()
                                        .translate(context),
                                  )
                                      .color(
                                        context.color.textColorDark,
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        bottom: 5,
                        left: 12,
                        right: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              UiUtils.imageType(
                                property.category!.image!,
                                width: 18,
                                height: 18,
                                color: Constant.adaptThemeColorSvg
                                    ? context.color.tertiaryColor
                                    : null,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(property.category?.category ?? '')
                                  .size(
                                    context.font.small,
                                  )
                                  .bold(
                                    weight: FontWeight.w400,
                                  )
                                  .color(
                                    context.color.textLightColor,
                                  ),
                            ],
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          if (property.properyType.toString().toLowerCase() ==
                              'rent') ...[
                            Text(rentPrice)
                                .size(
                                  context.font.large,
                                )
                                .color(
                                  context.color.tertiaryColor,
                                )
                                .bold(
                                  weight: FontWeight.w700,
                                )
                                .setMaxLines(lines: 1),
                          ] else ...[
                            Text(
                              property.price!
                                  .priceFormate(
                                    disabled:
                                        Constant.isNumberWithSuffix == false,
                                    context: context,
                                  )
                                  .formatAmount(prefix: true),
                            )
                                .size(context.font.large)
                                .color(context.color.tertiaryColor)
                                .bold(
                                  weight: FontWeight.w700,
                                )
                                .setMaxLines(lines: 1),
                          ],
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            property.title ?? '',
                          )
                              .setMaxLines(lines: 1)
                              .size(context.font.large)
                              .color(context.color.textColorDark),
                          if (property.city != '') ...[
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                UiUtils.getSvg(
                                  AppIcons.location,
                                  color: context.color.textLightColor,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(property.city!)
                                      .color(context.color.textLightColor)
                                      .setMaxLines(lines: 1),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (showLikeButton ?? true)
                PositionedDirectional(
                  end: 25,
                  top: 128,
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
                    child: LikeButtonWidget(
                      propertyId: property.id!,
                      isFavourite: property.isFavourite!,
                      onLikeChanged: onLikeChange,
                    ),
                  ),
                ),
              PositionedDirectional(
                start: 10,
                top: 10,
                child: Row(
                  children: [
                    Visibility(
                      visible: property.promoted ?? false,
                      child: const PromotedCard(type: PromoteCardType.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
