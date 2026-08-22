import 'package:immozen/data/model/subscription_pacakage_model.dart';
import 'package:immozen/ui/screens/subscription/widget/subscripton_feature_line.dart';
import 'package:immozen/utils/AppIcon.dart';
import 'package:immozen/utils/extensions/extensions.dart';
import 'package:immozen/utils/responsiveSize.dart';
import 'package:immozen/utils/ui_utils.dart';
import 'package:flutter/material.dart';

abstract class Limit<T> {
  abstract final T value;
}

class StringLimit extends Limit {
  StringLimit(this.value);
  @override
  final String value;
}

class IntLimit extends Limit {
  IntLimit(this.value);
  @override
  final int value;
}

class NotAvailable extends Limit {
  NotAvailable();
  @override
  void value;
}

class PackageLimit {
  PackageLimit(this.limit);
  final dynamic limit;

  Limit get(context) {
    if (limit is int) {
      return IntLimit(limit);
    } else {
      if (isAvailable(context, limit)) {
        if (isUnLimited(context, limit)) {
          return StringLimit('unlimited'.translate(context));
        } else {
          //Will not execute but added
          return StringLimit(limit);
        }
      } else {
        return NotAvailable();
      }
    }
  }

  bool isUnLimited(BuildContext context, String value) {
    if (value == 'unlimited') {
      return true;
    }
    return false;
  }

  bool isAvailable(BuildContext context, String? value) {
    if (value == 'not_available' || value == null) {
      return false;
    }
    return true;
  }
}

class SubscriptionPackageTile extends StatelessWidget {
  const SubscriptionPackageTile({
    required this.onTap,
    required this.package,
    super.key,
  });
  final SubscriptionPackageModel package;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.tertiaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              SizedBox(
                width: context.screenWidth,
                child: UiUtils.getSvg(
                  AppIcons.headerCurve,
                  color: context.color.tertiaryColor,
                  fit: BoxFit.fitWidth,
                ),
              ),
              PositionedDirectional(
                start: 10.rw(context),
                top: 8.rh(context),
                child: Text(package.name ?? '')
                    .size(context.font.larger)
                    .color(context.color.secondaryColor)
                    .bold(weight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SubscriptionFeatureLine(
            limit: PackageLimit(package.advertisementLimit),
            isTime: false,
            title: UiUtils.translate(context, 'adLimitIs'),
          ),
          SizedBox(
            height: 5.rh(context),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubscriptionFeatureLine(
                    limit: PackageLimit(package.propertyLimit),
                    isTime: false,
                    title: UiUtils.translate(context, 'propertyLimit'),
                  ),
                  SizedBox(
                    height: 5.rh(context),
                  ),
                  SubscriptionFeatureLine(
                    limit: null,
                    isTime: true,
                    timeLimit:
                        "${package.duration} ${UiUtils.translate(context, "days")}",
                    title: UiUtils.translate(context, 'validity'),
                  ),
                  // SubscriptionFeatureLine(),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 15),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.color.secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 39.rh(context),
                    constraints: BoxConstraints(
                      minWidth: 80.rw(context),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        package.price == 0
                            ? 'Free'.translate(context)
                            : '${package.price}'.formatAmount(prefix: true),
                        style: const TextStyle(fontFamily: 'ROBOTO'),
                      )
                          .color(context.color.tertiaryColor)
                          .bold()
                          .size(context.font.large),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: UiUtils.buildButton(
              context,
              onPressed: onTap,
              radius: 9,
              height: 33.rh(context),
              buttonTitle: UiUtils.translate(context, 'subscribe'),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewOnlyPackageCard extends StatelessWidget {
  const ViewOnlyPackageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 60,
        child: Center(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: context.color.tertiaryColor,
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    color: context.color.tertiaryColor,
                  ),
                ),
                Text('Unlocked Private Properties'.translate(context))
                    .bold(weight: FontWeight.w500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
