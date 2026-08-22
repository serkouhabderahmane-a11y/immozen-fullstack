import 'dart:convert';

import 'package:immozen/data/helper/custom_exception.dart';
import 'package:immozen/utils/Extensions/extensions.dart';
import 'package:immozen/utils/api.dart';
import 'package:immozen/utils/helper_utils.dart';
import 'package:immozen/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EnquiryState {}

class EnquiryInitial extends EnquiryState {}

class EnquirySetProgress extends EnquiryState {}

class EnquirySetSuccess extends EnquiryState {
  EnquirySetSuccess(this.msg);
  String msg = '';
}

class EnquirySetFailure extends EnquiryState {
  EnquirySetFailure(this.errmsg);
  final String errmsg;
}

class EnquiryCubit extends Cubit<EnquiryState> {
  EnquiryCubit() : super(EnquiryInitial());

  void setEnquiry(
    BuildContext context, {
    String? actionType,
    String? propertyId,
    String? status,
  }) {
    emit(EnquirySetProgress());
    setEnquiryFromDb(context, actionType!, propertyId!, status!)
        .then((value) => emit(EnquirySetSuccess(value)))
        .catchError((e) => emit(EnquirySetFailure(e.toString())));
  }

  Future<String> setEnquiryFromDb(
    BuildContext context,
    String actionType,
    String propertyId,
    String status,
  ) async {
    if (actionType == '0') {
    } else {
      // ApiParams.id: '',
      // ApiParams.enqStatus: ''
    }
    final body = <String, String>{
      //Add
      Api.actionType: actionType,
      Api.propertyId: propertyId,
      Api.customerId: HiveUtils.getUserId().toString(),
    };

    final response = await HelperUtils.sendApiRequest(
      Api.apiSetPropertyEnquiry,
      body,
      true,
      context,
      passUserid: false,
    );
    final getdata = json.decode(response);
    if (getdata != null) {
    } else {
      Future.delayed(
        Duration.zero,
        () {
          throw CustomException('nodatafound'.translate(context));
        },
      );
    }
    return getdata[Api.message];
  }
}
