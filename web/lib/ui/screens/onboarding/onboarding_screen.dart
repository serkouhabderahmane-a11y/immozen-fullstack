import 'package:immozen/app/routes.dart';
import 'package:immozen/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:immozen/data/model/system_settings_model.dart';
import 'package:immozen/utils/Extensions/extensions.dart';
import 'package:immozen/utils/Lottie/lottieEditor.dart';
import 'package:immozen/utils/hive_keys.dart';
import 'package:immozen/utils/responsiveSize.dart';
import 'package:immozen/utils/ui_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPageIndex = 0;
  int previousePageIndex = 0;
  double changedOnPageScroll = 0.5;
  double currentSwipe = 0;
  late int totalPages;

  final LottieEditor _onBoardingOne = LottieEditor();
  final LottieEditor _onBoardingTwo = LottieEditor();
  final LottieEditor _onBoardingThree = LottieEditor();

  dynamic onBoardingOneData;
  dynamic onBoardingTwoData;
  dynamic onBoardingThreeData;

  @override
  void initState() {
    _onBoardingOne.openAndLoad('assets/lottie/onbo_a.json');
    _onBoardingTwo.openAndLoad('assets/lottie/onbo_b.json');
    _onBoardingThree.openAndLoad('assets/lottie/onbo_c.json');

    Future.delayed(
      Duration.zero,
      () {
        _onBoardingOne.changeWholeLottieFileColor(context.color.tertiaryColor);
        _onBoardingTwo.changeWholeLottieFileColor(context.color.tertiaryColor);
        _onBoardingThree
            .changeWholeLottieFileColor(context.color.tertiaryColor);

        onBoardingOneData = _onBoardingOne.convertToUint8List();
        onBoardingTwoData = _onBoardingTwo.convertToUint8List();
        onBoardingThreeData = _onBoardingThree.convertToUint8List();
        setState(() {});
      },
    );

    Future.delayed(Duration.zero, () {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final slidersList = [
      {
        'lottie': onBoardingOneData,
        'title': "Welcome to Immozen",
        'description': UiUtils.translate(context, 'onboarding_1_description'),
        'button': 'next_button.svg',
      },
      {
        'lottie': onBoardingTwoData,
        'title': UiUtils.translate(context, 'onboarding_2_title'),
        'description': UiUtils.translate(context, 'onboarding_2_description'),
      },
      {
        'lottie': onBoardingThreeData,
        'title': UiUtils.translate(context, 'onboarding_3_title'),
        'description': UiUtils.translate(context, 'onboarding_3_description'),
      },
    ];

    totalPages = slidersList.length;
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: Stack(
          children: <Widget>[
            Container(
              color: context.color.tertiaryColor.withOpacity(0.25),
            ),
            Align(
              alignment: Alignment.center.add(const Alignment(0, -.3)),
              child: SizedBox(
                height: 300,
                child: (slidersList[currentPageIndex]['lottie'] != null)
                    ? Lottie.memory(
                        slidersList[currentPageIndex]['lottie'],
                        delegates: const LottieDelegates(
                          values: [],
                        ),
                        errorBuilder: (context, error, stackTrace) {
                          return Container();
                        },
                      )
                    : Container(),
              ),
            ),
            PositionedDirectional(
              top: kPagingTouchSlop,
              start: 5,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: GestureDetector(
                  onTap: () async {
                    await context
                        .read<FetchSystemSettingsCubit>()
                        .fetchSettings(
                          isAnonymouse: true,
                        );
                    await Navigator.pushNamed(
                      context,
                      Routes.languageListScreenRoute,
                    );
                  },
                  child: Row(
                    children: [
                      StreamBuilder(
                        stream: Hive.box(HiveKeys.languageBox)
                            .watch(key: HiveKeys.currentLanguageKey),
                        builder: (context, AsyncSnapshot<BoxEvent> value) {
                          if (value.data?.value == null) {
                            if (context
                                    .watch<FetchSystemSettingsCubit>()
                                    .getSetting(SystemSetting.language)
                                    .toString() ==
                                'null') {
                              return const Text('');
                            }
                            return Text(
                              context
                                  .watch<FetchSystemSettingsCubit>()
                                  .getSetting(SystemSetting.language)
                                  .toString()
                                  .firstUpperCase(),
                            ).color(context.color.textColorDark);
                          } else {
                            return Text(
                              value.data!.value!['code']
                                  .toString()
                                  .firstUpperCase(),
                            ).color(context.color.textColorDark);
                          }
                        },
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: context.color.tertiaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: kPagingTouchSlop,
              end: 5,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(Routes.main,
                      arguments: {'from': 'splash'});

                  //    Navigator.pushReplacementNamed(context, Routes.login);
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Icon(
                    Icons.close,
                    color: context.color.tertiaryColor,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: GestureDetector(
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  currentSwipe = details.localPosition.direction;
                  setState(() {});
                },
                onHorizontalDragEnd: (details) {
                  if (currentSwipe < 0.5) {
                    if (changedOnPageScroll == 1 ||
                        changedOnPageScroll == 0.5) {
                      if (currentPageIndex > 0) {
                        currentPageIndex--;
                        changedOnPageScroll = 0;
                      }
                    }
                    setState(() {});
                  } else {
                    if (currentPageIndex < totalPages) {
                      if (changedOnPageScroll == 0 ||
                          changedOnPageScroll == 0.5) {
                        if (currentPageIndex < slidersList.length - 1) {
                          currentPageIndex++;
                        } else {
                          Navigator.of(context).pushReplacementNamed(
                              Routes.main,
                              arguments: {'from': 'splash'});
                          /* Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.login,
                            (route) => false,
                          );*/
                        }
                        setState(() {});
                      }
                    }
                  }

                  changedOnPageScroll = 0.5;
                  setState(() {});
                },
                child: Container(
                  height: 304.rh(context),
                  width: context.screenWidth,
                  decoration: BoxDecoration(
                    color: context.color.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 20,
                      left: 20,
                      bottom: 20,
                      top: 10,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            slidersList[currentPageIndex]['title'],
                            key: const Key('onboarding_title'),
                          )
                              .size(context.font.extraLarge.rf(context))
                              .color(context.color.tertiaryColor)
                              .bold(weight: FontWeight.w600),
                        ),
                        Text(
                          slidersList[currentPageIndex]['description'],
                          textAlign: TextAlign.center,
                        )
                            .setMaxLines(lines: 3)
                            .size(context.font.larger.rf(context))
                            .color(context.color.textColorDark),
                        const Spacer(),
                        Row(
                          children: [
                            Row(
                              children: [
                                for (var i = 0;
                                    i < slidersList.length;
                                    i++) ...[
                                  buildIndicator(
                                    context,
                                    selected: i == currentPageIndex,
                                  ),
                                ],
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              key: const ValueKey('next_screen'),
                              onTap: () {
                                if (currentPageIndex < slidersList.length - 1) {
                                  currentPageIndex++;
                                } else {
                                  Navigator.of(context).pushReplacementNamed(
                                      Routes.main,
                                      arguments: {
                                        'from': 'splash'
                                      }); /*Navigator.of(context).pushNamedAndRemoveUntil(
                                    Routes.login,
                                    (route) => false,
                                  );*/
                                }
                                setState(() {});
                              },
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: context.color.tertiaryColor,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: context.color.backgroundColor,
                                ),
                                // UiUtils.getSvg(AppIcons.iconArrowLeft)
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIndicator(BuildContext context, {required bool selected}) {
    if (selected) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Container(
          width: 36,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: context.color.tertiaryColor,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.color.textLightColor, width: 1.9),
          ),
        ),
      );
    }
  }
}
