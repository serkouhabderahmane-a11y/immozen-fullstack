import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

import 'package:immozen/data/model/data_output.dart';
import 'package:immozen/data/model/subscription_pacakage_model.dart';
import 'package:immozen/data/model/subscription_package_limit.dart';
import 'package:immozen/utils/api.dart';

enum SubscriptionLimitType { advertisement, property, isPremium }

class SubscriptionRepository {
  Future<DataOutput<SubscriptionPackageModel>> getSubscriptionPackages({
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.getPackage,
      queryParameters: {
        'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        // "current_user": HiveUtils.getUserId()
      },
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<SubscriptionPackageModel>(SubscriptionPackageModel.fromJson)
        .toList();

    return DataOutput(total: modelList.length, modelList: modelList);
  }

  Future<SubcriptionPackageLimit> getPackageLimit(
    SubscriptionLimitType limitType,
  ) async {
    final response = await Api.get(
      url: Api.getLimitsOfPackage,
      queryParameters: {'package_type': limitType.name},
    );
    return SubcriptionPackageLimit.fromMap(response);
  }

  Future<void> subscribeToPackage(
    int packageId,
    bool isPackageAvailable,
  ) async {
    try {
      final parameters = <String, dynamic>{
        Api.packageId: packageId,
        // Api.userid: HiveUtils.getUserId(),
        if (isPackageAvailable) 'flag': 1,
      };

      await Api.post(
        url: Api.userPurchasePackage,
        parameter: parameters,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> assignFreePackage(int packageId) async {
    await Api.post(
      url: Api.assignPackage,
      parameter: {'package_id': packageId, 'in_app': false},
    );
  }

  Future<void> assignPackage({
    required String packageId,
    required String productId,
  }) async {
    try {
      await Api.post(
        url: Api.assignPackage,
        parameter: {
          'package_id': packageId,
          'product_id': productId,
          'in_app': true,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
