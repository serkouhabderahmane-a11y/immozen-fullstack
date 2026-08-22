import 'dart:convert';

import 'package:immozen/data/helper/custom_exception.dart';
import 'package:immozen/data/model/property_model.dart';
import 'package:immozen/utils/api.dart';
import 'package:immozen/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TopPropertyState {}

class TopPropertyInitial extends TopPropertyState {}

class TopPropertyFetchProgress extends TopPropertyState {}

class TopPropertyFetchSuccess extends TopPropertyState {
  TopPropertyFetchSuccess(this.propertylist);
  List<PropertyModel> propertylist = [];
}

class TopPropertyFetchFailure extends TopPropertyState {
  TopPropertyFetchFailure(this.errmsg);
  final String errmsg;
}

class TopViewedPropertyCubit extends Cubit<TopPropertyState> {
  TopViewedPropertyCubit() : super(TopPropertyInitial());

  void fetchTopProperty(
    BuildContext context, {
    String? categoryId,
    bool fromUserlist = false,
  }) {
    emit(TopPropertyFetchProgress());
    fetchTopPropertyFromDb(context)
        .then((value) => emit(TopPropertyFetchSuccess(value)))
        .catchError((e) => emit(TopPropertyFetchFailure(e.toString())));
  }

  Future<List<PropertyModel>> fetchTopPropertyFromDb(
    BuildContext context,
  ) async {
    //String? propertyId,
    final propertylist = <PropertyModel>[];
    final body = <String, dynamic>{
      Api.topRated: '1',
      Api.offset: '0',
      Api.limit: '10',
    };

    final response = await HelperUtils.sendApiRequest(
      Api.apiGetProprty,
      body,
      true,
      context,
      passUserid: false,
    );
    final getdata = json.decode(response);
    print(getdata);

    if (getdata != null) {
      if (!getdata[Api.error]) {
      } else {
        throw CustomException(getdata[Api.message]);
      }
    } else {
      throw CustomException('nodatafound');
    }

    return propertylist;
  }
}
