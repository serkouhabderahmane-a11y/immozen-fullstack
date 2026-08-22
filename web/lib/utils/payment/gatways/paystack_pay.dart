import 'dart:developer';
import 'dart:io';

import 'package:immozen/app/app.dart';
import 'package:immozen/app/default_app_setting.dart';
import 'package:immozen/data/model/subscription_pacakage_model.dart';
import 'package:immozen/utils/constant.dart';
import 'package:immozen/utils/helper_utils.dart';
import 'package:immozen/utils/hive_utils.dart';
import 'package:immozen/utils/payment/lib/payment.dart';
import 'package:immozen/utils/payment/lib/purchase_package.dart';
import 'package:immozen/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
//import 'package:flutter_paystack/flutter_paystack.dart';

class Paystack extends Payment {
  SubscriptionPackageModel? _model;

  //PaystackPlugin paystackPlugin = PaystackPlugin();

  void init(String publicKey) {
    // paystackPlugin.initialize(publicKey: publicKey);
  }

  @override
  Future<void> onEvent(
    BuildContext context,
    covariant PaymentStatus currentStatus,
  ) async {
    if (currentStatus is Success) {
      await PurchasePackage().purchase(context);
    }
  }

  @override
  Future<void> pay(BuildContext context) async {
    if (_model == null) {
      log('Please setPackage');
    }
    isPaymentGatewayOpen = true;
    /*  final paystackCharge = Charge()
      ..amount = (_model!.price! * 100).toInt()
      ..email = HiveUtils.getUserDetails().email
      ..currency = Constant.paystackCurrency
      ..reference = generateReference(HiveUtils.getUserDetails().email!)
      ..putMetaData('username', HiveUtils.getUserDetails().name)
      ..putMetaData('package_id', _model!.id)
      ..putMetaData('user_id', HiveUtils.getUserId());

    final checkoutResponse = await paystackPlugin.checkout(
      context,
      logo: SizedBox(
        height: 50,
        width: 50,
        child: LoadAppSettings().svg(
          appSettings.placeholderLogo!,
        ),
      ),
      charge: paystackCharge,
      method: CheckoutMethod.card,
    );
    isPaymentGatewayOpen = false;
    if (checkoutResponse.status) {
      if (checkoutResponse.verify) {
        Future.delayed(
          Duration.zero,
          () async {
            emit(Success(message: 'Success'));
            // await _purchase(context);
          },
        );
      }
    } else {
      Future.delayed(
        Duration.zero,
        () {
          HelperUtils.showSnackBarMessage(
            context,
            UiUtils.translate(context, 'purchaseFailed'),
          );
        },
      );
    }*/
  }

  String generateReference(String email) {
    late String platform;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      platform = 'I';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      platform = 'A';
    }
    final reference =
        '${platform}_${email.split("@").first}_${DateTime.now().millisecondsSinceEpoch}';
    return reference;
  }

  @override
  Payment setPackage(SubscriptionPackageModel modal) {
    _model = modal;
    return this;
  }
}
