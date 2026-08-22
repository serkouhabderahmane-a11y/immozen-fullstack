import 'package:dio/dio.dart';
import 'package:immozen/data/model/project_model.dart';
import 'package:immozen/exports/main_export.dart';

class ProjectRepository {
  Future<Map<String, dynamic>?> createProject(Map projectPayload) async {
    try {
      final multipartedData = _multipartImages(projectPayload);
      // multipartedData['image']=multipartedData['main_image'];
      final images = projectPayload['gallery_images'];
      multipartedData.remove('gallery_images');
      var galleryImages = <String, dynamic>{};
      if (images != null) {
        galleryImages =
            (images as MultiValue).value.fold({}, (previousValue, element) {
          if (element.value is! String) {
            previousValue.addAll({
              'gallery_images[${previousValue.length}]':
                  MultipartFile.fromFileSync((element.value as File).path),
            });
          }

          return previousValue;
        });
      }

      multipartedData.addAll(galleryImages);
      final map = await Api.post(
        url: Api.postProject,
        parameter: multipartedData,
      );
      return map;
    } catch (e) {
      return null;
      // throw e;
    }
  }

  Future<DataOutput<ProjectModel>> getMyProjects({
    required int offset,
  }) async {
    final result = await Api.get(
      url: Api.getProjects,
      queryParameters: {'userid': HiveUtils.getUserId(), 'offset': offset},
    );
    final list = (result['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ProjectModel>(ProjectModel.fromMap)
        .toList();
    print('HERE IN GET PROJECTS:$list');

    return DataOutput(total: result['total'] ?? 0, modelList: list);
  }

  Future<DataOutput<ProjectModel>> getProjects({
    int? offset,
  }) async {
    final result = await Api.get(
      url: Api.getProjects,
      queryParameters: {'offset': offset},
    );
    final list = (result['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ProjectModel>(ProjectModel.fromMap)
        .toList();

    return DataOutput(total: result['total'] ?? 0, modelList: list);
  }

  Map<String, dynamic> _multipartImages(Map data) {
    return data.map((key, value) {
      if (value is FileValue) {
        return MapEntry(key, MultipartFile.fromFileSync(value.value.path));
      }
      if (value is MultiValue && key != 'gallery_images') {
        final images = value.value.map((image) {
          if (image is FileValue) {
            return MultipartFile.fromFileSync(image.value.path);
          }
        }).toList();
        return MapEntry(key, images);
      }
      if (value is List<File>) {
        final files =
            value.map((e) => MultipartFile.fromFileSync(e.path)).toList();
        return MapEntry(key, files);
      }
      if (value is Map) {
        final v = _multipartImages(value);
        return MapEntry(key, v);
      }
      if (value is List) {
        final list = value.map((e) {
          if (e is Map) {
            return _multipartImages(e);
          }
          return {};
        }).toList();
        return MapEntry(key, list);
      }

      return MapEntry(key, value);
    });
  }

  Future<DataOutput<ProjectModel>> fetchProjectFromProjectId(dynamic id) async {
    final parameters = <String, dynamic>{
      Api.id: id,
      'current_user': HiveUtils.getUserId(),
    };

    final response = await Api.get(
      url: Api.getProjects,
      queryParameters: parameters,
    );

    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<ProjectModel>(ProjectModel.fromMap)
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }
}
