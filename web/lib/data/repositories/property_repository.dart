import 'package:immozen/data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import 'package:immozen/data/helper/filter.dart';
import 'package:immozen/data/model/data_output.dart';
import 'package:immozen/data/model/property_model.dart';
import 'package:immozen/utils/api.dart';
import 'package:immozen/utils/constant.dart';
import 'package:immozen/utils/hive_utils.dart';

class PropertyRepository {
  ///This method will add property
  Future createProperty({
    required Map<String, dynamic> parameters,
  }) async {
    var api = Api.apiPostProperty;
    if (parameters['action_type'] == '0') {
      api = Api.apiUpdateProperty;

      if (parameters.containsKey('gallery_images')) {
        if ((parameters['gallery_images'] as List).isEmpty) {
          parameters.remove('gallery_images');
        }
      }
      if (parameters.containsKey('documents')) {
        if ((parameters['documents'] as List).isEmpty) {
          parameters.remove('documents');
        }
      }

      if (parameters['title_image'] == null ||
          parameters['title_image'] == '') {
        parameters.remove('title_image');
      }
      // if (parameters['meta_image'] != null || parameters['meta_image'] != '') {
      //   parameters.remove('meta_image');
      // }
    }

    return Api.post(url: api, parameter: parameters);
  }

  /// it will get all proerpties
  Future<DataOutput<PropertyModel>> fetchProperty({
    required int offset,
  }) async {
    final parameters = <String, dynamic>{
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      'current_user': HiveUtils.getUserId(),
    };

    final response = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<PropertyModel>> fetchRecentProperties({
    required int offset,
  }) async {
    final parameters = <String, dynamic>{
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      'current_user': HiveUtils.getUserId(),
    };

    final response = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<PropertyModel>> fetchPropertyFromPropertyId(
    dynamic id,
  ) async {
    final parameters = <String, dynamic>{
      Api.id: id,
      'current_user': HiveUtils.getUserId(),
    };

    final response = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<void> deleteProperty(
    int id,
  ) async {
    await Api.post(
      url: Api.apiUpdateProperty,
      parameter: {Api.id: id, Api.actionType: '1'},
    );
  }

  Future<DataOutput<PropertyModel>> fetchTopRatedProperty() async {
    final parameters = <String, dynamic>{
      Api.topRated: '1',
      'current_user': HiveUtils.getUserId(),
    };

    final response = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  ///fetch most viewed properties
  Future<DataOutput<PropertyModel>> fetchMostViewedProperty({
    required int offset,
    required bool sendCityName,
  }) async {
    final parameters = <String, dynamic>{
      Api.topRated: '1',
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      'current_user': HiveUtils.getUserId(),
    };
    try {
      final response = await Api.get(
        url: Api.apiGetProprty,
        queryParameters: parameters,
      );

      final modelList = (response['data'] as List)
          .cast<Map<String, dynamic>>()
          .map<PropertyModel>(PropertyModel.fromMap)
          .toList();
      return DataOutput(total: response['total'] ?? 0, modelList: modelList);
    } catch (e) {
      rethrow;
    }
  }

  ///fetch advertised properties
  Future<DataOutput<PropertyModel>> fetchPromotedProperty({
    required int offset,
    required bool sendCityName,
  }) async {
    ///
    final parameters = <String, dynamic>{
      Api.promoted: true,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      'current_user': HiveUtils.getUserId(),
    };

    final response = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();

    return DataOutput(
      total: response['total'] ?? 0,
      modelList: modelList,
    );
  }

  Future<DataOutput<PropertyModel>> fetchNearByProperty({
    required int offset,
  }) async {
    try {
      if (HiveUtils.getCityName() == null ||
          HiveUtils.getCityName().toString().isEmpty) {
        return Future.value(
          DataOutput(
            total: 0,
            modelList: [],
          ),
        );
      }
      final result = await Api.get(
        url: Api.apiGetProprty,
        queryParameters: {
          'city': HiveUtils.getCityName(),
          Api.offset: offset,
          'limit': Constant.loadLimit,
          'current_user': HiveUtils.getUserId(),
        },
      );

      final dataList = (result['data'] as List).map((e) {
        return PropertyModel.fromMap(e);
      }).toList();

      return DataOutput<PropertyModel>(
        total: result['total'] ?? 0,
        modelList: dataList,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<DataOutput<PropertyModel>> fetchMostLikeProperty({
    required int offset,
    required bool sendCityName,
  }) async {
    final parameters = <String, dynamic>{
      'most_liked': 1,
      'limit': Constant.loadLimit,
      'offset': offset,
      'current_user': HiveUtils.getUserId(),
    };
    if (sendCityName) {
      // if (HiveUtils.getCityName() != null) {
      //   if (!Constant.isDemoModeOn) {
      //     parameters['city'] = HiveUtils.getCityName();
      //   }
      // }
    }
    final response = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List).map((e) {
      return PropertyModel.fromMap(e);
    }).toList();
    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<Advertisement>> fetchMyPromotedProeprties({
    required int offset,
  }) async {
    final parameters = <String, dynamic>{
      'is_promoted': 1,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      // "current_user": HiveUtils.getUserId()
    };

    final response = await Api.get(
      url: Api.getAddedProperties,
      queryParameters: parameters,
    );
    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<Advertisement>(Advertisement.fromMap)
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  ///Search property
  Future<DataOutput<PropertyModel>> searchProperty(
    String searchQuery, {
    required int offset,
    FilterApply? filter,
  }) async {
    final parameters = <String, dynamic>{
      Api.search: searchQuery,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      'current_user': HiveUtils.getUserId(),
      ...filter?.getFilter() ?? {},
    };

    final response = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  ///to get my properties which i had added to sell or rent
  Future<DataOutput<PropertyModel>> fetchMyProperties({
    required int offset,
    required String type,
  }) async {
    try {
      final propertyType = _findPropertyType(type.toLowerCase());

      final parameters = <String, dynamic>{
        Api.offset: offset,
        Api.limit: Constant.loadLimit,
        // Api.userid: HiveUtils.getUserId(),
        Api.propertyType: propertyType,
        // "current_user": HiveUtils.getUserId()
      };
      final response = await Api.get(
        url: Api.getAddedProperties,
        queryParameters: parameters,
      );
      final modelList = (response['data'] as List)
          .cast<Map<String, dynamic>>()
          .map<PropertyModel>(PropertyModel.fromMap)
          .toList();

      return DataOutput(total: response['total'] ?? 0, modelList: modelList);
    } catch (e) {
      rethrow;
    }
  }

  String? _findPropertyType(String type) {
    if (type == 'sell' || type == 'sold' || type == 'Sold') {
      return '0';
    } else if (type == 'rent' || type == 'rented' || type == 'Rented') {
      return '1';
    }
    return null;
  }

  Future<DataOutput<PropertyModel>> fetchProperyFromCategoryId({
    required int id,
    required int offset,
    FilterApply? filter,
    bool? showPropertyType,
  }) async {
    final parameters = <String, dynamic>{
      Api.categoryId: id,
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      'current_user': HiveUtils.getUserId(),
      ...filter?.getFilter() ?? {},
    };

    final response = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();
    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<void> setProeprtyView(String propertyId) async {
    await Api.post(
      url: Api.setPropertyView,
      parameter: {Api.propertyId: propertyId},
    );
  }

  Future updatePropertyStatus({
    required dynamic propertyId,
    required dynamic status,
  }) async {
    await Api.post(
      url: Api.updatePropertyStatus,
      parameter: {'status': status, 'property_id': propertyId},
    );
  }

  Future<PropertyModel> fetchBySlug(String slug) async {
    final result = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: {'slug_id': slug},
    );

    return PropertyModel.fromMap(result['data'][0]);
  }

  Future<DataOutput<PropertyModel>> fetchPropertiesFromCityName(
    String cityName, {
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: {
        'city': cityName,
        Api.limit: Constant.loadLimit,
        Api.offset: offset,
        'current_user': HiveUtils.getUserId(),
      },
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();
    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<PropertyModel>> fetchAllProperties({
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.apiGetProprty,
      queryParameters: {
        Api.limit: Constant.loadLimit,
        Api.offset: offset,
      },
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<PropertyModel>(PropertyModel.fromMap)
        .toList();
    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }
}
