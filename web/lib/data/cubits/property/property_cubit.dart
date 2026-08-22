// ignore_for_file: invalid_return_type_for_catch_error

import 'package:immozen/data/model/property_model.dart';
// import 'package:google_maps_webservice/directions.dart';

import 'package:immozen/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PropertyState {}

class PropertyInitial extends PropertyState {}

class PropertyFetchProgress extends PropertyState {}

class PropertyFetchSuccess extends PropertyState {
  PropertyFetchSuccess(this.propertylist, this.total);
  List<PropertyModel> propertylist = [];
  int total = 0;
}

class PropertyFetchFailure extends PropertyState {
  PropertyFetchFailure(this.errmsg);
  final String errmsg;
}

class PropertyCubit extends Cubit<PropertyState> {
  PropertyCubit() : super(PropertyInitial());

  void fetchProperty(
    BuildContext context,
    Map<String, dynamic> mbodyparam, {
    bool fromUserlist = false,
  }) {
    emit(PropertyFetchProgress());
    fetchPropertyFromDb(
      context,
      mbodyparam,
      fromUserlist: fromUserlist,
    ).then((value) {
      emit(PropertyFetchSuccess(value['list'], value['total']));
    }).catchError((e, st) => emit(PropertyFetchFailure(st.toString())));
  }

  Future<Map> fetchPropertyFromDb(
    BuildContext context,
    Map<String, dynamic> bodyparam, {
    bool fromUserlist = false,
  }) async {
    final result = {};
    var propertylist = <PropertyModel>[];
    var mtotal = 0;
    final response = await Api.get(
      url: Api.apiGetProprty,
    );
    final List<Map<String, dynamic>> list = response['data'];
    mtotal = response['total'];
    result['total'] = mtotal;
    propertylist = list.map<PropertyModel>(PropertyModel.fromMap).toList();

    result['list'] = propertylist;
    return result;
  }
}
