import 'package:immozen/data/model/subscription_package_limit.dart';
import 'package:immozen/data/repositories/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsInitial
    extends GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsInProgress
    extends GetSubscriptionPackageLimitsState {}

class GetSubscriptionPackageLimitsSuccess
    extends GetSubscriptionPackageLimitsState {
  GetSubscriptionPackageLimitsSuccess(this.packageLimit);
  final SubcriptionPackageLimit packageLimit;
}

class GetSubsctiptionPackageLimitsFailure
    extends GetSubscriptionPackageLimitsState {
  GetSubsctiptionPackageLimitsFailure(this.errorMessage);
  final String errorMessage;
}

class GetSubsctiptionPackageLimitsCubit
    extends Cubit<GetSubscriptionPackageLimitsState> {
  GetSubsctiptionPackageLimitsCubit()
      : super(GetSubscriptionPackageLimitsInitial());
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();

  Future<void> getLimits(SubscriptionLimitType type) async {
    try {
      emit(GetSubscriptionPackageLimitsInProgress());
      final subscriptionPackageLimit =
          await _subscriptionRepository.getPackageLimit(
        type,
      );
      emit(GetSubscriptionPackageLimitsSuccess(subscriptionPackageLimit));
    } catch (error) {
      emit(GetSubsctiptionPackageLimitsFailure(error.toString()));
    }
  }
}
