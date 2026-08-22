import 'package:immozen/exports/main_export.dart';
import 'package:immozen/ui/screens/chat/chat_audio/widgets/chat_widget.dart';
import 'package:immozen/ui/screens/chat/chat_audio/widgets/record_button.dart';
import 'package:immozen/ui/screens/chat_new/message_types/registerar.dart';
import 'package:immozen/ui/screens/chat_new/model.dart';
import 'package:immozen/ui/screens/widgets/animated_routes/transparant_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

int totalMessageCount = 0;

ValueNotifier<bool> showDeletebutton = ValueNotifier<bool>(false);

ValueNotifier<int> selectedMessageid = ValueNotifier<int>(-5);
ValueNotifier<int> selectedRecieverId = ValueNotifier<int>(-5);

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.profilePicture,
    required this.userName,
    required this.propertyImage,
    required this.proeprtyTitle,
    required this.userId,
    required this.propertyId,
    super.key,
    this.from,
  });
  final String? from;
  final String profilePicture;
  final String userName;
  final String propertyImage;
  final String proeprtyTitle;
  final String userId; //for which we are messageing
  final String propertyId;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _recordButtonAnimation = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 500,
    ),
  );
  TextEditingController controller = TextEditingController();
  PlatformFile? messageAttachment;
  bool isFetchedFirstTime = false;
  double scrollPositionWhenLoadMore = 0;
  late Stream<PermissionStatus> notificationStream = notificationPermission();
  late StreamSubscription notificationStreamSubsctription;
  bool isNotificationPermissionGranted = true;
  ValueNotifier<bool> showRecordButton = ValueNotifier(true);
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(
      () {
        ContextMenuController.removeAny();
        if (_pageScrollController.offset >=
            _pageScrollController.position.maxScrollExtent) {
          if (context.read<LoadChatMessagesCubit>().hasMoreChat()) {
            context.read<LoadChatMessagesCubit>().loadMore();
          }
        }
      },
    );
  @override
  void initState() {
    Permission.storage.request();

    context.read<LoadChatMessagesCubit>().load(
          userId: int.parse(
            widget.userId,
          ),
          propertyId: int.parse(
            widget.propertyId,
          ),
        );

    currentlyChatPropertyId = widget.propertyId;
    currentlyChatingWith = widget.userId;
    notificationStreamSubsctription =
        notificationStream.listen((PermissionStatus permissionStatus) {
      isNotificationPermissionGranted = permissionStatus.isGranted;
      if (mounted) {
        // setState(() {});
      }
    });
    controller.addListener(() {
      if (controller.text.isNotEmpty) {
        showRecordButton.value = false;
      } else {
        showRecordButton.value = true;
      }
    });
    super.initState();
  }

  Stream<PermissionStatus> notificationPermission() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      yield* Permission.notification.request().asStream();
    }
  }

  @override
  void dispose() {
    showRecordButton.dispose();
    _recordButtonAnimation.dispose();

    notificationStreamSubsctription.cancel();
    super.dispose();
  }

  List<String> supportedImageTypes = [
    'jpeg',
    'jpg',
    'png',
    'gif',
    'webp',
    'animated_webp',
  ];

  String getSendMessageType(
    String? audio,
    dynamic attachment,
    String? message,
  ) {
    if (audio != null) {
      return 'audio';
    } else {
      if (attachment != null && (message != null)) {
        return 'file_and_text';
      } else if (attachment != null && message == null) {
        return 'file';
      } else {
        return 'text';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const chatBackground = 'assets/chat_background/doodle.png';
    var attachmentMIME = '';
    if (messageAttachment != null) {
      attachmentMIME =
          messageAttachment?.path?.split('.').last.toLowerCase() ?? '';
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop();
        currentlyChatingWith = '';
        showDeletebutton.value = false;
        ChatMessageHandler.flush();
        currentlyChatPropertyId = '';
        await notificationStreamSubsctription.cancel();
        ChatMessageHandlerOLD.flushMessages();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: context.color.backgroundColor,
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (messageAttachment != null) ...[
                    if (supportedImageTypes.contains(attachmentMIME)) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          border: Border.all(
                            color: context.color.borderColor,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: GestureDetector(
                                  onTap: () {
                                    UiUtils.showFullScreenImage(
                                      context,
                                      provider: FileImage(
                                        File(
                                          messageAttachment?.path ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.file(
                                    File(
                                      messageAttachment?.path ?? '',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(messageAttachment?.name ?? ''),
                                Text(
                                  HelperUtils.getFileSizeString(
                                    bytes: messageAttachment!.size,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ColoredBox(
                        color: context.color.secondaryColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: AttachmentMessage(
                            url: messageAttachment!.path!,
                            isSentByMe: true,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                  BottomAppBar(
                    padding: const EdgeInsetsDirectional.all(10),
                    elevation: 5,
                    color: context.color.secondaryColor,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            cursorColor: context.color.tertiaryColor,
                            onTap: () {
                              showDeletebutton.value = false;
                            },
                            textInputAction: TextInputAction.newline,
                            minLines: 1,
                            maxLines: null,
                            decoration: InputDecoration(
                              suffixIconColor: context.color.textLightColor,
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  if (messageAttachment == null) {
                                    final pickedAttachment =
                                        await FilePicker.platform.pickFiles();

                                    messageAttachment =
                                        pickedAttachment?.files.first;
                                    showRecordButton.value = false;
                                    setState(() {});
                                  } else {
                                    messageAttachment = null;
                                    showRecordButton.value = true;
                                    setState(() {});
                                  }
                                },
                                icon: messageAttachment != null
                                    ? const Icon(Icons.close)
                                    : Transform.rotate(
                                        angle: -3.14 / 5.0,
                                        child: const Icon(
                                          Icons.attachment,
                                        ),
                                      ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: context.color.tertiaryColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: context.color.tertiaryColor,
                                ),
                              ),
                              hintText: UiUtils.translate(
                                context,
                                'writeHere',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 9.5,
                        ),
                        ValueListenableBuilder(
                          valueListenable: showRecordButton,
                          builder: (context, bool show, Widget? child) {
                            if (show == true) {
                              return RecordButton(
                                controller: _recordButtonAnimation,
                                callback: (path) {
                                  final chatMessageModel = ChatMessageModel(
                                    message: controller.text,
                                    isSentByMe: true,
                                    audio: path,
                                    senderId: HiveUtils.getUserId().toString(),
                                    id: DateTime.now().toString(),
                                    propertyId: widget.propertyId,
                                    receiverId: widget.userId,
                                    chatMessageType: getSendMessageType(
                                      path,
                                      messageAttachment,
                                      controller.text,
                                    ),
                                    date: DateTime.now().toString(),
                                    isSentNow: true,
                                  );
                                  ChatMessageHandler.add(
                                    chatMessageModel,
                                  );
                                  _pageScrollController.jumpTo(
                                    _pageScrollController.offset - 10,
                                  );
                                  //This is adding Chat widget in stream with BlocProvider ,
                                  // because we will need to do api process to store chat message to server,
                                  // when it will be added to list it's initState method will be called
                                  totalMessageCount++;

                                  setState(() {});
                                },
                                isSending: false,
                              );
                            }
                            return GestureDetector(
                              onTap: () {
                                showDeletebutton.value = false;

                                //if file is selected then user can send message without text
                                if (controller.text.trim().isEmpty &&
                                    messageAttachment == null) return;
                                //This is adding Chat widget in stream with BlocProvider ,
                                // because we will need to do api process to store chat message to server,
                                // when it will be added to list it's initState method will be called
                                if (Constant.isDemoModeOn) {
                                  HelperUtils.showSnackBarMessage(
                                    context,
                                    UiUtils.translate(
                                      context,
                                      'thisActionNotValidDemo',
                                    ),
                                  );
                                  return;
                                }
                                final chatMessageModel = ChatMessageModel(
                                  message: controller.text,
                                  isSentByMe: true,
                                  file: messageAttachment?.path,
                                  senderId: HiveUtils.getUserId().toString(),
                                  id: DateTime.now().toString(),
                                  propertyId: widget.propertyId,
                                  receiverId: widget.userId,
                                  chatMessageType: getSendMessageType(
                                    null,
                                    messageAttachment,
                                    controller.text.isEmpty
                                        ? null
                                        : controller.text,
                                  ),
                                  date: DateTime.now().toString(),
                                  isSentNow: true,
                                );
                                ChatMessageHandler.add(chatMessageModel);
                                controller.text = '';
                                messageAttachment = null;
                                totalMessageCount++;
                                messageAttachment = null;
                                if (mounted) setState(() {});
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: context.color.tertiaryColor,
                                child: Icon(
                                  Icons.send,
                                  color: context.color.buttonColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: false,
            automaticallyImplyLeading: false,
            leading: FittedBox(
              fit: BoxFit.none,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: UiUtils.getSvg(
                    AppIcons.arrowLeft,
                    matchTextDirection: true,
                    fit: BoxFit.none,
                    color: context.color.tertiaryColor,
                  ),
                ),
              ),
            ),
            leadingWidth: 24,
            backgroundColor: context.color.secondaryColor,
            elevation: 0,
            iconTheme: IconThemeData(color: context.color.tertiaryColor),
            bottom: isNotificationPermissionGranted
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(25),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Container(
                        width: context.screenWidth,
                        color: const Color.fromARGB(255, 151, 151, 151),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('turnOnNotification'.translate(context)),
                        ),
                      ),
                    ),
                  ),
            actions: [
              ValueListenableBuilder(
                valueListenable: showDeletebutton,
                builder: (context, value, child) {
                  if (value == false) return const SizedBox.shrink();
                  return IconButton(
                    onPressed: () {
                      UiUtils.showBlurredDialoge(
                        context,
                        dialoge: BlurredDialogBox(
                          onAccept: () async {
                            await context.read<DeleteMessageCubit>().delete(
                                  selectedMessageid.value,
                                  receiverId: selectedRecieverId.value,
                                );
                            showDeletebutton.value = false;
                          },
                          title: 'areYouSure'.translate(context),
                          content: Text(
                            'msgWillNotRecover'.translate(context),
                          ),
                        ),
                      );
                    },
                    icon: SvgPicture.asset(
                      AppIcons.delete,
                      colorFilter: ColorFilter.mode(
                        context.color.tertiaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  );
                },
              ),
              if (widget.from != 'property')
                FittedBox(
                  fit: BoxFit.none,
                  child: GestureDetector(
                    onTap: () async {
                      unawaited(Widgets.showLoader(context));
                      try {
                        final fetch = PropertyRepository();
                        final dataOutput =
                            await fetch.fetchPropertyFromPropertyId(
                          widget.propertyId,
                        );
                        Future.delayed(
                          Duration.zero,
                          () {
                            Widgets.hideLoder(context);

                            HelperUtils.goToNextPage(
                              Routes.propertyDetails,
                              context,
                              false,
                              args: {
                                'propertyData': dataOutput.modelList[0],
                                'propertiesList': dataOutput.modelList,
                                'fromMyProperty': false,
                              },
                            );
                          },
                        );
                      } catch (e) {
                        Widgets.hideLoder(context);
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.network(
                          widget.propertyImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                width: 18,
              ),
            ],
            title: FittedBox(
              fit: BoxFit.none,
              child: Row(
                children: [
                  if (widget.profilePicture.isEmpty)
                    CircleAvatar(
                      backgroundColor: context.color.tertiaryColor,
                      child: LoadAppSettings().svg(
                        appSettings.placeholderLogo!,
                        color: context.color.buttonColor,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          TransparantRoute(
                            barrierDismiss: true,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  color: const Color.fromARGB(69, 0, 0, 0),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: CustomImageHeroAnimation(
                        type: CImageType.Network,
                        image: widget.profilePicture,
                        child: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            widget.profilePicture,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: context.screenWidth * 0.35,
                        child: Text(widget.userName)
                            .color(context.color.textColorDark)
                            .size(context.font.normal),
                      ),
                      SizedBox(
                        width: context.screenWidth * 0.35,
                        child: Text(widget.proeprtyTitle)
                            .size(context.font.small)
                            .color(context.color.textColorDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: Stack(
            children: [
              Image.asset(
                chatBackground,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
              BlocListener<DeleteMessageCubit, DeleteMessageState>(
                listener: (context, state) {
                  if (state is DeleteMessageSuccess) {
                    ChatMessageHandlerOLD.removeMessage(state.id);
                    showDeletebutton.value = false;
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    showDeletebutton.value = false;
                  },
                  child: BlocConsumer<LoadChatMessagesCubit,
                      LoadChatMessagesState>(
                    listener: (context, state) {
                      if (state is LoadChatMessagesSuccess) {
                        ChatMessageHandler.fillMessages(state.messages);

                        // ChatMessageHandlerOLD.loadMessages(
                        //     state.messages, context);
                        totalMessageCount = state.messages.length;
                        isFetchedFirstTime = true;
                        setState(() {});
                      }
                      if (state is LoadChatMessagesFailed) {}
                    },
                    builder: (context, state) {
                      return Stack(
                        children: [
                          Column(
                            children: [
                              if (state is LoadChatMessagesSuccess) ...{
                                if (state.isLoadingMore) ...{
                                  Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: UiUtils.progress(),
                                    ),
                                  ),
                                },
                              },
                              Expanded(
                                child: StreamBuilder(
                                  stream: ChatMessageHandler.listenMessages(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.active) {
                                      return SizedBox(
                                        height: context.screenHeight,
                                        child: ListView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          reverse: true,
                                          shrinkWrap: true,
                                          controller: _pageScrollController,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final messageList = snapshot.data!;
                                            final messageLength =
                                                messageList.length;
                                            final isSentByMe =
                                                messageList[index].isSentByMe;
                                            final message =
                                                messageList[index].message;
                                            final timeAgo =
                                                message?.timeAgo ?? '';
                                            final date = message?.date ?? '';
                                            Widget? dateChip;
                                            if (index == messageLength - 1 ||
                                                (index > 0 &&
                                                    timeAgo !=
                                                        messageList[index - 1]
                                                            .message
                                                            ?.timeAgo)) {
                                              dateChip =
                                                  getDateChip(timeAgo, context);
                                            }
                                            // Optimize time chip
                                            final timeChip = Container(
                                              alignment: isSentByMe
                                                  ? AlignmentDirectional
                                                      .centerEnd
                                                  : AlignmentDirectional
                                                      .centerStart,
                                              child: timeFormat(date, context),
                                            );
                                            return MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                  create: (context) =>
                                                      SendMessageCubit(),
                                                ),
                                                BlocProvider(
                                                  create: (context) =>
                                                      DeleteMessageCubit(),
                                                ),
                                              ],
                                              child: Column(
                                                children: [
                                                  if (timeAgo != '' &&
                                                      dateChip != null)
                                                    dateChip,
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10,
                                                    ),
                                                    child: RenderMessage(
                                                      key: Key(
                                                        messageList[index].id,
                                                      ),
                                                      message:
                                                          messageList[index],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .only(
                                                      start:
                                                          isSentByMe ? 0 : 10,
                                                      end: isSentByMe ? 10 : 0,
                                                      bottom: 10,
                                                    ),
                                                    child: timeChip,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          itemCount: snapshot.data!.length,
                                        ),
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (state is LoadChatMessagesInProgress)
                            Center(
                              child: UiUtils.progress(),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget getDateChip(String date, BuildContext context) {
  return Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          Divider(color: context.color.inverseSurface.withOpacity(0.1)),
          Container(
            padding: const EdgeInsets.only(bottom: 3),
            width: context.screenWidth * 0.4,
            decoration: BoxDecoration(
              color: context.color.brightness == Brightness.light
                  ? Colors.grey.shade200
                  : Colors.grey.shade900,
              border: Border.all(
                color: context.color.inverseSurface.withOpacity(0.1),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              date,
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
    ],
  );
}

// DateFormat('EEE, d MMM yyyy HH:mm:ss')
Widget timeFormat(String time, BuildContext context) {
  if (time.isEmpty) {
    return const SizedBox.shrink(); // Return empty widget if time is empty
  }
  try {
    final messageTime = DateTime.parse(time).toLocal(); // Convert to local time
    final now = DateTime.now();
    final diffInSeconds = now.difference(messageTime).inSeconds;

    String formattedTime;
    if (diffInSeconds < 1) {
      formattedTime = '1s ago';
    } else if (diffInSeconds < 60) {
      formattedTime = '${diffInSeconds}s ago';
    } else if (diffInSeconds < 3600) {
      formattedTime = '${(diffInSeconds / 60).floor()}m ago';
    } else if (diffInSeconds < 86400) {
      formattedTime = '${(diffInSeconds / 3600).floor()}h ago';
    } else {
      formattedTime = DateFormat('h:mm a').format(messageTime);
    }

    return Text(formattedTime).size(context.font.smaller);
  } catch (e) {
    if (kDebugMode) {
      print('Error parsing date: $e');
    }
    return const SizedBox.shrink(); // Return empty widget if parsing fails
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class ChatInfoWidget extends StatelessWidget {
  const ChatInfoWidget({
    required this.propertyTitleImage,
    required this.propertyTitle,
    required this.propertyId,
    super.key,
  });
  final String propertyTitleImage;
  final String propertyTitle;
  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.color.tertiaryColor),
      ),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: context.screenHeight * 0.46,
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              width: context.screenWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GestureDetector(
                      onTap: () {
                        UiUtils.showFullScreenImage(
                          context,
                          provider:
                              CachedNetworkImageProvider(propertyTitleImage),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: propertyTitleImage,
                        width: context.screenWidth,
                        fit: BoxFit.cover,
                        height: context.screenHeight * 0.3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(propertyTitle)
                          .setMaxLines(
                            lines: 2,
                          )
                          .size(
                            context.font.larger.rf(
                              context,
                            ),
                          ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: FittedBox(
                      fit: BoxFit.none,
                      child: UiUtils.buildButton(
                        context,
                        onPressed: () async {
                          try {
                            unawaited(Widgets.showLoader(context));
                            final fetch = PropertyRepository();
                            final dataOutput =
                                await fetch.fetchPropertyFromPropertyId(
                              propertyId,
                            );
                            Future.delayed(
                              Duration.zero,
                              () {
                                Widgets.hideLoder(context);
                                HelperUtils.goToNextPage(
                                  Routes.propertyDetails,
                                  context,
                                  false,
                                  args: {
                                    'propertyData': dataOutput.modelList[0],
                                    'propertiesList': dataOutput.modelList,
                                    'fromMyProperty': false,
                                  },
                                );
                              },
                            );
                          } catch (e) {
                            Widgets.hideLoder(context);
                          }
                        },
                        buttonTitle: UiUtils.translate(context, 'viewProperty'),
                        width: context.screenWidth * 0.5,
                        fontSize: context.font.normal,
                        height: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
