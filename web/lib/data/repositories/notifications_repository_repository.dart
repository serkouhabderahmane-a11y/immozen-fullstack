import 'package:immozen/data/model/data_output.dart';
import 'package:immozen/data/model/notification_data.dart';
import 'package:immozen/utils/api.dart';
import 'package:immozen/utils/constant.dart';

class NotificationsRepository {
  Future<DataOutput<NotificationData>> fetchNotifications({
    required int offset,
  }) async {
    try {
      final parameters = <String, dynamic>{
        // Api.userid: HiveUtils.getUserId(),
        Api.offset: offset,
        Api.limit: Constant.loadLimit,
      };
      final response = await Api.get(
        url: Api.apiGetNotifications,
        queryParameters: parameters,
      );

      final modelList = (response['data'] as List).map((e) {
        return NotificationData.fromJson(e);
      }).toList();

      return DataOutput(
        total: 0,
        modelList: modelList,
      );
    } catch (e) {
      rethrow;
    }
  }
}
