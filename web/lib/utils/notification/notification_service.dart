// ignore_for_file: file_names

import 'dart:developer';

import 'package:immozen/data/model/chat/chated_user_model.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:immozen/ui/screens/chat/chat_screen.dart';
import 'package:immozen/ui/screens/chat_new/message_types/registerar.dart';
import 'package:immozen/ui/screens/chat_new/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

String currentlyChatingWith = '';
String currentlyChatPropertyId = '';

class NotificationService {
  static FirebaseMessaging messagingInstance = FirebaseMessaging.instance;

  static LocalAwsomeNotification localNotification = LocalAwsomeNotification();

  static late StreamSubscription<RemoteMessage> foregroundStream;
  static late StreamSubscription<RemoteMessage> onMessageOpen;
  static requestPermission() async {}

Future<void> updateFCM() async {
  try {
    // Request permission for iOS
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // For iOS: wait for APNS token to be available
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          log('APNS token not available. Retrying in 2 seconds...');
          await Future.delayed(Duration(seconds: 2));
          return updateFCM(); // Retry
        }
      }

      // Get FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        log('FCM Token: $token');

        // Send token to server
        // await Api.post(
        //   parameter: {Api.fcmId: token},
        //   useAuthToken: true,
        // );

      } else {
        log('FCM token is null');
      }
    } else {
      log('Notification permission not granted');
    }
  } catch (e) {
    log('Error in updateFCM: $e');
  }
}

  static handleNotification(RemoteMessage? message, [BuildContext? context]) {
    final notificationType = message?.data['type'] ?? '';

    log('@notificaiton data is ${message?.data}');

    if (notificationType == 'chat') {
      final senderId = message?.data['sender_id'] ?? '';
      final username = message!.data['username'];
      final propertyTitleImage = message.data['property_title_image'];
      final propertyTitle = message.data['title'];
      final userProfile = message.data['user_profile'];
      final propertyId = message.data['property_id'];

      (context!).read<GetChatListCubit>().addNewChat(
            ChatedUser(
              fcmId: '',
              firebaseId: '',
              name: username,
              profile: userProfile,
              propertyId:
                  (propertyId is int) ? propertyId : int.parse(propertyId),
              title: propertyTitle,
              userId: (senderId is int) ? senderId : int.parse(senderId),
              titleImage: propertyTitleImage,
            ),
          );

      ///Checking if this is user we are chatiing with
      if (senderId == currentlyChatingWith &&
          propertyId == currentlyChatPropertyId) {
        final chatMessageModel = ChatMessageModel.fromJson(message.data)
          ..setIsSentByMe(false)
          ..setIsSentNow(false);
        ChatMessageHandler.add(chatMessageModel);
        totalMessageCount++;
      } else {
        localNotification.createNotification(
          isLocked: false,
          notificationData: message,
        );
      }
    } else if (notificationType == 'delete_message') {
      ChatMessageHandlerOLD.removeMessage(
        int.parse(
          message!.data['message_id'],
        ),
      );
    } else {
      localNotification.createNotification(
        isLocked: false,
        notificationData: message!,
      );
    }
  }

  static void init(context) {
    requestPermission();
    registerListeners(context);
  }

  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    if (message.notification == null) {
      handleNotification(
        message,
      );
    }
  }

  static forgroundNotificationHandler(BuildContext context) async {
    foregroundStream =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleNotification(message, context);
    });
  }

  static terminatedStateNotificationHandler(BuildContext context) {
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message == null) {
          return;
        }
        if (message.notification == null) {
          handleNotification(message, context);
        }
      },
    );
  }

  static void onTapNotificationHandler(context) {
    onMessageOpen = FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) async {
      if (message.data['type'] == 'chat') {
        final username = message.data['title'];
        final propertyTitleImage = message.data['property_title_image'];
        final propertyTitle = message.data['property_title'];
        final userProfile = message.data['user_profile'];
        final senderId = message.data['sender_id'];
        final propertyId = message.data['property_id'];
        Future.delayed(
          Duration.zero,
          () {
            Navigator.push(
              Constant.navigatorKey.currentContext!,
              MaterialPageRoute(
                builder: (context) {
                  return BlocProvider(
                    create: (context) {
                      return LoadChatMessagesCubit();
                    },
                    child: Builder(
                      builder: (context) {
                        return ChatScreen(
                          profilePicture: userProfile ?? '',
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
        final String id = message.data['id'] ?? '';
        final property =
            await PropertyRepository().fetchPropertyFromPropertyId(id);
        Future.delayed(Duration.zero, () {
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
        });
      }
    }
            // if (message.data["screen"] == "profile") {
            //   Navigator.pushNamed(context, profileRoute);
            // }

            );
  }

  static Future<void> registerListeners(context) async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await forgroundNotificationHandler(context);
    await terminatedStateNotificationHandler(context);
    onTapNotificationHandler(context);
  }

  static void disposeListeners() {
    onMessageOpen.cancel();
    foregroundStream.cancel();
  }
}
