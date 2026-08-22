import 'package:dio/dio.dart';
import 'package:immozen/data/model/chat/chated_user_model.dart';
import 'package:immozen/data/model/data_output.dart';
import 'package:immozen/ui/screens/chat_new/message_types/blueprint.dart';
import 'package:immozen/ui/screens/chat_new/message_types/registerar.dart';
import 'package:immozen/ui/screens/chat_new/model.dart';
import 'package:immozen/utils/api.dart';
import 'package:immozen/utils/constant.dart';
import 'package:immozen/utils/hive_utils.dart';
import 'package:flutter/material.dart';

class ChatRepository {
  BuildContext? _setContext;

  void setContext(BuildContext context) {
    _setContext = context;
  }

  Future<DataOutput<ChatedUser>> fetchChatList(int pageNumber) async {
    final response = await Api.get(
      url: Api.getChatList,
      queryParameters: {
        'page': pageNumber,
        'per_page': Constant.loadLimit,
      },
    );

    final modelList = (response['data'] as List).map((e) {
      return ChatedUser.fromJson(e, context: _setContext);
    }).toList();

    return DataOutput(total: response['total_page'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<Message>> getMessages({
    required int page,
    required int userId,
    required int propertyId,
  }) async {
    final response = await Api.get(
      url: Api.getMessages,
      queryParameters: {
        'user_id': userId,
        'property_id': propertyId,
        'page': page,
        'per_page': Constant.minChatMessages,
      },
    );
    final modelList = (response['data']['data'] as List).map(
      (result) {
        //Creating model
        final chatMessageModel = ChatMessageModel.fromJson(result);
        chatMessageModel
          ..setIsSentByMe(
            HiveUtils.getUserId() == chatMessageModel.senderId.toString(),
          )
          ..setIsSentNow(false)
          ..date = result['created_at'];
        //Creating message widget
        final message = filterMessageType(chatMessageModel)
          ..isSentByMe = chatMessageModel.isSentByMe ?? false
          ..isSentNow = chatMessageModel.isSentNow ?? false
          ..message = chatMessageModel;

        return message;
      },
    ).toList();

    return DataOutput(total: response['total_page'] ?? 0, modelList: modelList);
  }

  Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required String recieverId,
    required String? message,
    required String proeprtyId,
    MultipartFile? audio,
    MultipartFile? attachment,
  }) async {
    final parameters = <String, dynamic>{
      'sender_id': senderId,
      'receiver_id': recieverId,
      'message': message,
      'property_id': proeprtyId,
      'file': attachment,
      'audio': audio,
    };

    if (attachment == null) {
      parameters.remove('file');
    }
    if (audio == null) {
      parameters.remove('audio');
    }
    final map = await Api.post(
      url: Api.sendMessage,
      parameter: parameters,
    );
    return map;
  }
}
