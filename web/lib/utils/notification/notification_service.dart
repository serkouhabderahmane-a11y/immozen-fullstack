// ignore_for_file: file_names

import 'dart:developer';

import 'package:immozen/data/model/chat/chated_user_model.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:immozen/ui/screens/chat/chat_screen.dart';
import 'package:immozen/ui/screens/chat_new/message_types/registerar.dart';
import 'package:immozen/ui/screens/chat_new/model.dart';
import 'package:flutter/material.dart';

String currentlyChatingWith = '';
String currentlyChatPropertyId = '';

class NotificationService {
  static LocalAwsomeNotification localNotification = LocalAwsomeNotification();

  static requestPermission() async {}

  static handleNotification(Map<String, dynamic>? data, [BuildContext? context]) {
    if (data == null) return;
    final notificationType = data['type'] ?? '';

    log('@notification data is $data');

    if (notificationType == 'chat') {
      final senderId = data['sender_id'] ?? '';
      final username = data['username'] ?? '';
      final propertyTitleImage = data['property_title_image'] ?? '';
      final propertyTitle = data['title'] ?? '';
      final userProfile = data['user_profile'] ?? '';
      final propertyId = data['property_id'] ?? '';

      if (context != null) {
        context.read<GetChatListCubit>().addNewChat(
              ChatedUser(
                fcmId: '',
                firebaseId: '',
                name: username,
                profile: userProfile,
                propertyId:
                    (propertyId is int) ? propertyId : int.parse(propertyId.toString()),
                title: propertyTitle,
                userId: (senderId is int) ? senderId : int.parse(senderId.toString()),
                titleImage: propertyTitleImage,
              ),
            );
      }

      if (senderId == currentlyChatingWith &&
          propertyId == currentlyChatPropertyId) {
        final chatMessageModel = ChatMessageModel.fromJson(data)
          ..setIsSentByMe(false)
          ..setIsSentNow(false);
        ChatMessageHandler.add(chatMessageModel);
        totalMessageCount++;
      }
    } else if (notificationType == 'delete_message') {
      ChatMessageHandlerOLD.removeMessage(
        int.parse(
          data['message_id'].toString(),
        ),
      );
    }
  }

  static void init(context) {
    requestPermission();
    registerListeners(context);
  }

  static Future<void> onBackgroundMessageHandler(dynamic message) async {
    log('onBackgroundMessageHandler called (Firebase removed)');
  }

  static registerListeners(context) async {
    log('Notification listeners registered (Firebase Messaging removed - push notifications disabled)');
  }

  static void disposeListeners() {
    log('Notification listeners disposed');
  }
}
