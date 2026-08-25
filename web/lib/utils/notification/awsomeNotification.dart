// ignore_for_file: file_names

import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:immozen/ui/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';

class LocalAwsomeNotification {
  AwesomeNotifications notification = AwesomeNotifications();
  void init(BuildContext context) {
    requestPermission();

    notification.initialize(
      null,
      [
        NotificationChannel(
          channelKey: Constant.notificationChannel,
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel',
          importance: NotificationImportance.Max,
          ledColor: Colors.grey,
        ),
        NotificationChannel(
          channelKey: 'Chat Notification',
          channelName: 'Chat Notifications',
          channelDescription: 'Chat Notifications',
          importance: NotificationImportance.Max,
          ledColor: Colors.grey,
        ),
      ],
      channelGroups: [],
    );
    listenTap(context);
  }

  void listenTap(BuildContext context) {
    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    );
  }

  createNotification({
    required dynamic notificationData,
    required bool isLocked,
  }) async {
    try {
      final data = notificationData.data ?? {};
      final isChat = (data['type'] == 'chat');
      var chatId = 0;
      if (isChat) {
        chatId = int.parse(data['sender_id'] ?? '0') +
            int.parse(data['property_id'].toString());
      }

      await notification.createNotification(
        content: NotificationContent(
          id: isChat ? chatId : Random().nextInt(5000),
          title: data['title'],
          hideLargeIconOnExpand: true,
          summary: data['type'] == 'chat'
              ? "${data['username']}"
              : null,
          locked: isLocked,
          payload: Map<String, String>.from(data.map((k, v) => MapEntry(k, v.toString()))),

          body: data['body'],
          wakeUpScreen: true,

          notificationLayout: data['type'] == 'chat'
              ? NotificationLayout.MessagingGroup
              : NotificationLayout.Default,
          groupKey: data['id']?.toString(),
          channelKey: data['type'] == 'chat'
              ? 'Chat Notification'
              : Constant.notificationChannel,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestPermission() async {
    try {
      await notification.requestPermissionToSendNotifications(
        channelKey: Constant.notificationChannel,
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
        ],
      );
      await notification.requestPermissionToSendNotifications(
        channelKey: 'Chat Notification',
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
        ],
      );
    } catch (e) {
      // Notifications permission request failed silently
    }
  }
}

class NotificationController {
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    final payload = receivedAction.payload;

    if (payload?['type'] == 'chat') {
      final username = payload?['username'];
      final propertyTitleImage = payload?['property_title_image'];
      final propertyTitle = payload?['title'];
      final userProfile = payload?['user_profile'];
      final senderId = payload?['sender_id'];
      final propertyId = payload?['property_id'];
      Future.delayed(
        Duration.zero,
        () {
          Navigator.push(
            Constant.navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => LoadChatMessagesCubit(),
                    ),
                    BlocProvider(
                      create: (context) => DeleteMessageCubit(),
                    ),
                  ],
                  child: Builder(
                    builder: (context) {
                      return ChatScreen(
                        profilePicture: userProfile!,
                        userName: username ?? '',
                        propertyImage: propertyTitleImage ?? '',
                        proeprtyTitle: propertyTitle ?? '',
                        userId: senderId ?? '',
                        propertyId: propertyId ?? '',
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      final id = receivedAction.payload?['id'] ?? '';

      final property =
          await PropertyRepository().fetchPropertyFromPropertyId(id);

      Future.delayed(
        Duration.zero,
        () {
          HelperUtils.goToNextPage(
            Routes.propertyDetails,
            Constant.navigatorKey.currentContext!,
            false,
            args: {
              'propertyData': property.modelList[0],
              'propertiesList': property.modelList,
              'fromMyProperty': false,
            },
          );
        },
      );
    }
  }
}
