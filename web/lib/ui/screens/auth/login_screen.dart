import 'package:country_picker/country_picker.dart';
import 'package:immozen/data/model/system_settings_model.dart';
import 'package:immozen/data/repositories/auth_repository.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:immozen/utils/login/apple_login/apple_login.dart';
import 'package:immozen/utils/login/google_login/google_login.dart';
import 'package:immozen/utils/login/lib/login_status.dart';
import 'package:immozen/utils/login/lib/login_system.dart';
import 'package:immozen/utils/strings.dart';
import 'package:immozen/utils/validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:sms_autofill/sms_autofill.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.isDeleteAccount, this.popToCurrent});

  final bool? isDeleteAccount;
  final bool? popToCurrent;

  @override
  State<LoginScreen> createState() => LoginScreenState();

  static BlurredRouter route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SendOtpCubit()),
          BlocProvider(create: (context) => VerifyOtpCubit()),
        ],
        child: LoginScreen(
          isDeleteAccount: args?['isDeleteAccount'],
          popToCurrent: args?['popToCurrent'],
        ),
      ),
    );
  }
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileNumController = TextEditingController(
    text: Constant.isDemoModeOn ? Constant.demoMobileNumber : '',
  );
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController(
    text: Constant.isDemoModeOn ? Constant.demoMobileNumber : '',
  );

  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  List<Widget> list = [];
  String otpVerificationId = '';
  final _formKey = GlobalKey<FormState>();
  bool isOtpSent = false; //to swap between login & OTP screen
  bool isChecked = false; //Privacy policy checkbox value check
  String? phone,
      otp,
      countryCode = "253",
      countryName = "Djibouti",
      flagEmoji = "🇩🇯";

  int otpLength = 6;
  Timer? timer;
  int backPressedTimes = 0;
  int focusIndex = 0;
  late Size size;
  bool isOTPautofilled = false;
  ValueNotifier<int> otpResendTime = ValueNotifier<int>(
    Constant.otpResendSecond,
  );
  TextEditingController otpController = TextEditingController();
  bool isLoginButtonDisabled = true;
  String otpIs = '';

  MMultiAuthentication loginSystem = MMultiAuthentication({
    'google': GoogleLogin(),
    'apple': AppleLogin(),
  });

  @override
  void initState() {
    super.initState();
    context.read;
    loginSystem
      ..init()
      ..setContext(context)
      ..listen((MLoginState state) {
        if (state is MProgress) {
          //unawaited(Widgets.showLoader(context));
        }

        if (state is MSuccess) {
          Widgets.hideLoder(context);
          if (widget.isDeleteAccount ?? false) {
            context.read<DeleteAccountCubit>().deleteUserAccount(
                  context,
                );
          } else {
            context.read<LoginCubit>().login(
                  type: LoginType.values
                      .firstWhere((element) => element.name == state.type),
                  name: state.credentials.user?.displayName ??
                      state.credentials.user?.providerData.first.displayName,
                  email: state.credentials.user?.providerData.first.email,
                  phoneNumber:
                      state.credentials.user?.providerData.first.phoneNumber,
                  uniqueId: state.credentials.user!.uid,
                  countryCode: countryCode,
                );
          }
        }

        if (state is MFail) {
          Widgets.hideLoder(context);
          if (state.error.toString() != 'google-terminated') {
            HelperUtils.showSnackBarMessage(
              context,
              state.error.toString(),
              type: MessageType.error,
            );
          }
        }
      });
    context.read<FetchSystemSettingsCubit>().fetchSettings(
          isAnonymouse: true,
          forceRefresh: true,
        );
    mobileNumController.addListener(
      () {
        if (mobileNumController.text.isEmpty) {
          isLoginButtonDisabled = true;
          setState(() {});
        } else {
          isLoginButtonDisabled = false;
          setState(() {});
        }
      },
    );
/*
    HelperUtils.getSimCountry().then((value) {
      countryCode = value.phoneCode;
      flagEmoji = value.flagEmoji;
      setState(() {});
    });
*/
    for (var i = 0; i < otpLength; i++) {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      _controllers.add(controller);
      _focusNodes.add(focusNode);
    }

    Future.delayed(Duration.zero, listenotp);

    _controllers[otpLength - 1].addListener(() {
      if (isOTPautofilled) {
        _loginOnOTPFilled();
      }
    });
  }

  void listenotp() {
    final autoFill = SmsAutoFill();

    autoFill.code.listen((event) {
      if (isOtpSent) {
        Future.delayed(Duration.zero, () {
          for (var i = 0; i < _controllers.length; i++) {
            _controllers[i].text = event[i];
          }

          _focusNodes[focusIndex].unfocus();

          var allFilled = true;
          for (var i = 0; i < _controllers.length; i++) {
            if (_controllers[i].text.isEmpty) {
              allFilled = false;
              break;
            }
          }

          // Call the API if all OTP fields are filled
          if (allFilled) {
            _loginOnOTPFilled();
          }

          if (mounted) setState(() {});
        });
      }
    });
  }

  void _loginOnOTPFilled() {
    onTapLogin(context);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    if (timer != null) {
      timer!.cancel();
    }
    for (final fNode in _focusNodes) {
      fNode.dispose();
    }
    otpResendTime.dispose();
    mobileNumController.dispose();
    if (isOtpSent) {
      SmsAutoFill().unregisterListener();
    }
    super.dispose();
  }

  void resendOTP() {
    if (isOtpSent && AppSettings.otpServiceProvider == 'firebase') {
      context.read<SendOtpCubit>().sendFirebaseOTP(
            phoneNumber: '+${countryCode!}${mobileNumController.text}',
          );
    } else if (isOtpSent && AppSettings.otpServiceProvider == 'twilio') {
      context.read<SendOtpCubit>().sendTwilioOTP(
            phoneNumber: '+${countryCode!}${mobileNumController.text}',
          );
    }
  }

  Future<void> startTimer() async {
    timer?.cancel();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (otpResendTime.value == 0) {
          timer.cancel();
          otpResendTime.value = Constant.otpResendSecond;
          setState(() {});
        } else {
          otpResendTime.value--;
        }
      },
    );
    setState(() {});
  }

  Future<void> _onGoogleTap() async {
    try {
      await loginSystem.setActive('google');
      await loginSystem.login();
    } catch (e) {
      HelperUtils.showSnackBarMessage(
        context,
        'googleLoginFailed'.translate(context),
        type: MessageType.error,
      );
      return;
    }

    Navigator.pushNamed(context, Routes.main, arguments: {'from': 'login'});
  }

  Future<void> _onTapAppleLogin() async {
    try {
      await loginSystem.setActive('apple');
      await loginSystem.login();
    } catch (e) {
      print(e);
      HelperUtils.showSnackBarMessage(
        context,
        'appleLoginFailed'.translate(context),
        type: MessageType.error,
      );
      return;
    }

    Navigator.pushNamed(context, Routes.main, arguments: {'from': 'login'});
  }

  @override
  Widget build(BuildContext context) {
    final phoneLogin = context
        .read<FetchSystemSettingsCubit>()
        .getSetting(SystemSetting.numberWithOtpLogin);
    size = MediaQuery.of(context).size;
    if (context.watch<FetchSystemSettingsCubit>().state
        is FetchSystemSettingsSuccess) {
      Constant.isDemoModeOn = context
              .watch<FetchSystemSettingsCubit>()
              .getSetting(SystemSetting.demoMode) ??
          false;
    }

    return SafeArea(
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: context.color.tertiaryColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: WillPopScope(
            onWillPop: onBackPress,
            child: Scaffold(
              backgroundColor: context.color.backgroundColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                leadingWidth: 100 + 14,
                leading: !AppSettings.disableCountrySelection &&
                        phoneLogin == '1'
                    ? Visibility(
                        visible: !isOtpSent,
                        child: FittedBox(
                          fit: BoxFit.none,
                          child: GestureDetector(
                            onTap: showCountryCode,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: context.color.tertiaryColor
                                      .withOpacity(0.1),
                                  child: Text(flagEmoji ?? ''),
                                ),
                                UiUtils.getSvg(
                                  AppIcons.downArrow,
                                  color: context.color.textLightColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                actions: [
                  Builder(
                    builder: (context) {
                      if (widget.popToCurrent == true) {
                        return const SizedBox.shrink();
                      }
                      return FittedBox(
                        fit: BoxFit.none,
                        child: MaterialButton(
                          color: context.color.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: context.color.borderColor,
                              width: 1.5,
                            ),
                          ),
                          elevation: 0,
                          onPressed: () {
                            GuestChecker.set('login_screen', isGuest: true);
                            HiveUtils.setIsGuest();
                            APICallTrigger.trigger();
                            HiveUtils.setUserIsNotNew();
                            HiveUtils.setUserIsNotAuthenticated();
                            Navigator.pushReplacementNamed(
                              context,
                              Routes.main,
                              arguments: {
                                'from': 'login',
                                'isSkipped': true,
                              },
                            );
                          },
                          child: const Text('Skip'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: buildLoginFields(context),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> onBackPress() {
    if (widget.isDeleteAccount ?? false) {
      Navigator.pop(context);
    } else {
      if (isOtpSent == true) {
        setState(() {
          isOtpSent = false;
        });
      } else {
        return Future.value(true);
      }
    }
    return Future.value(false);
  }

  Widget buildLoginFields(BuildContext context) {
    return BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
      listener: (context, state) {
        if (state is AccountDeleted) {
          context.read<UserDetailsCubit>().clear();
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushReplacementNamed(context, Routes.login);
          });
        }
      },
      builder: (context, state) {
        return ScrollConfiguration(
          behavior: RemoveGlow(),
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(
              top: MediaQuery.of(context).padding.top + 40,
            ),
            child: BlocListener<LoginCubit, LoginState>(
              listener: (context, state) async {
                if (state is LoginInProgress) {
                  unawaited(Widgets.showLoader(context));
                } else {
                  if (widget.isDeleteAccount ?? false) {
                  } else {
                    Widgets.hideLoder(context);
                  }
                }
                if (state is LoginFailure) {
                  HelperUtils.showSnackBarMessage(
                    context,
                    state.errorMessage,
                    type: MessageType.error,
                  );
                }
                if (state is LoginSuccess) {
                  GuestChecker.set('login_screen', isGuest: false);
                  HiveUtils.setIsNotGuest();
                  await LoadAppSettings().load(true);
                  context
                      .read<UserDetailsCubit>()
                      .fill(HiveUtils.getUserDetails());

                  APICallTrigger.trigger();

                  await context.read<FetchSystemSettingsCubit>().fetchSettings(
                        isAnonymouse: false,
                        forceRefresh: true,
                      );
                  final settings = context.read<FetchSystemSettingsCubit>();

                  if (!const bool.fromEnvironment(
                    'force-disable-demo-mode',
                  )) {
                    Constant.isDemoModeOn =
                        settings.getSetting(SystemSetting.demoMode) ?? false;
                  }
                  if (state.isProfileCompleted) {
                    HiveUtils.setUserIsAuthenticated();
                    await HiveUtils.setUserIsNotNew();
                    await context.read<AuthCubit>().updateFCM(
                          context,
                        );
                    if (widget.popToCurrent == true) {
                      Navigator.pop(context);
                    } else {
                      await Navigator.pushReplacementNamed(
                        context,
                        Routes.main,
                        arguments: {'from': 'login'},
                      );
                    }
                  } else {
                    await HiveUtils.setUserIsNotNew();
                    await context.read<AuthCubit>().updateFCM(
                          context,
                        );

                    if (widget.popToCurrent == true) {
                      //Navigate to Edit profile field
                      /*  await Navigator.pushNamed(
                        context,
                        Routes.completeProfile,
                        arguments: {
                          'from': 'login',
                          'popToCurrent': widget.popToCurrent,
                          'phoneNumber': mobileNumController.text,
                        },
                      );*/
                      await Navigator.pushReplacementNamed(
                        context,
                        Routes.main,
                        arguments: {
                          'from': 'login',
                        },
                      );
                    } else {
                      //Navigate to Edit profile field
                      /*await Navigator.pushReplacementNamed(
                        context,
                        Routes.completeProfile,
                        arguments: {
                          'from': 'login',
                          'popToCurrent': widget.popToCurrent,
                          'phoneNumber': mobileNumController.text,
                        },
                      );*/
                      await Navigator.pushReplacementNamed(
                        context,
                        Routes.main,
                        arguments: {
                          'from': 'login',
                        },
                      );
                    }
                  }
                }
              },
              child: BlocListener<DeleteAccountCubit, DeleteAccountState>(
                listener: (context, state) {
                  if (state is DeleteAccountProgress) {
                    Widgets.hideLoder(context);
                    // Widgets.showLoader(context);
                  }
                  if (state is AccountDeleted) {
                    Widgets.hideLoder(context);
                  }
                },
                child: BlocListener<VerifyOtpCubit, VerifyOtpState>(
                  listener: (context, state) {
                    if (state is VerifyOtpInProgress) {
                      Widgets.showLoader(context);
                    } else {
                      if (widget.isDeleteAccount ?? false) {
                      } else {
                        Widgets.hideLoder(context);
                      }
                    }
                    if (state is VerifyOtpFailure) {
                      HelperUtils.showSnackBarMessage(
                        context,
                        state.errorMessage,
                        type: MessageType.error,
                      );
                    }

                    if (state is VerifyOtpSuccess) {
                      if (widget.isDeleteAccount ?? false) {
                        context.read<DeleteAccountCubit>().deleteUserAccount(
                              context,
                            );
                      } else if (AppSettings.otpServiceProvider == 'firebase') {
                        context.read<LoginCubit>().login(
                              type: LoginType.phone,
                              phoneNumber: state.credential!.user!.phoneNumber,
                              uniqueId: state.credential!.user!.uid,
                              countryCode: countryCode,
                            );
                      } else if (AppSettings.otpServiceProvider == 'twilio') {
                        context.read<LoginCubit>().login(
                              type: LoginType.phone,
                              phoneNumber: mobileNumController.text,
                              uniqueId: state.authId!,
                              countryCode: countryCode,
                            );
                      }
                    }
                  },
                  child: BlocListener<SendOtpCubit, SendOtpState>(
                    listener: (context, state) {
                      if (state is SendOtpInProgress) {
                        Widgets.showLoader(context);
                      } else {
                        if (widget.isDeleteAccount ?? false) {
                        } else {
                          Widgets.hideLoder(context);
                        }
                      }

                      if (state is SendOtpSuccess) {
                        startTimer();
                        isOtpSent = true;
                        if (isOtpSent) {
                          HelperUtils.showSnackBarMessage(
                            context,
                            UiUtils.translate(
                              context,
                              'optsentsuccessflly',
                            ),
                            type: MessageType.success,
                          );
                        }
                        otpVerificationId = state.verificationId;
                        setState(() {});

                        // context.read<SendOtpCubit>().setToInitial();
                      }
                      if (state is SendOtpFailure) {
                        HelperUtils.showSnackBarMessage(
                          context,
                          state.errorMessage,
                          type: MessageType.error,
                        );
                      }
                    },
                    child: Form(
                      key: _formKey,
                      child: isOtpSent
                          ? buildOtpVerificationScreen()
                          : buildLoginScreen(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String demoOTP() {
    if (Constant.isDemoModeOn &&
        Constant.demoMobileNumber == mobileNumController.text) {
      return Constant.demoModeOTP; // If true, return the demo mode OTP.
    } else {
      return ''; // If false, return an empty string.
    }
  }

  Widget buildOtpVerificationScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(UiUtils.translate(context, 'enterCodeSend'))
              .size(context.font.xxLarge)
              .bold(weight: FontWeight.w700)
              .color(context.color.textColorDark),
          SizedBox(
            height: 15.rh(context),
          ),
          if (widget.isDeleteAccount ?? false) ...[
            Text("${UiUtils.translate(context, "weSentCodeOnNumber")} +${HiveUtils.getUserDetails().mobile}")
                .size(context.font.large)
                .color(context.color.textColorDark.withOpacity(0.8)),
          ] else ...[
            Text("${UiUtils.translate(context, "weSentCodeOnNumber")} +$countryCode${mobileNumController.text}")
                .size(context.font.large)
                .color(context.color.textColorDark.withOpacity(0.8)),
          ],
          SizedBox(
            height: 20.rh(context),
          ),
          PinFieldAutoFill(
            autoFocus: true,
            controller: otpController,
            decoration: UnderlineDecoration(
              lineHeight: 1.5,
              colorBuilder: PinListenColorBuilder(
                context.color.tertiaryColor,
                Colors.grey,
              ),
            ),
            currentCode: demoOTP(),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: defaultTargetPlatform == TargetPlatform.iOS
                ? const TextInputType.numberWithOptions(signed: true)
                : TextInputType.number,
            onCodeSubmitted: (code) {
              if (AppSettings.otpServiceProvider == 'firebase') {
                if (widget.isDeleteAccount ?? false) {
                  context.read<VerifyOtpCubit>().verifyOTP(
                        verificationId: verificationID,
                        otp: code,
                      );
                } else {
                  context.read<VerifyOtpCubit>().verifyOTP(
                        verificationId: otpVerificationId,
                        otp: code,
                      );
                }
              } else if (AppSettings.otpServiceProvider == 'twilio') {
                context.read<VerifyOtpCubit>().verifyOTP(
                      otp: otpIs,
                      number: '+${countryCode!}${mobileNumController.text}',
                    );
              }
            },
            onCodeChanged: (code) {
              if (code?.length == 6) {
                otpIs = code!;
                // setState(() {});
              }
            },
          ),

          // loginButton(context),
          if (!(timer?.isActive ?? false)) ...[
            SizedBox(
              height: 70,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IgnorePointer(
                  ignoring: timer?.isActive ?? false,
                  child: setTextbutton(
                    UiUtils.translate(context, 'resendCodeBtnLbl'),
                    (timer?.isActive ?? false)
                        ? Theme.of(context).colorScheme.textLightColor
                        : Theme.of(context).colorScheme.tertiaryColor,
                    FontWeight.bold,
                    resendOTP,
                    context,
                  ),
                ),
              ),
            ),
          ],

          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(child: resendOtpTimerWidget()),
          ),

          loginButton(context),
        ],
      ),
    );
  }

  // Widget buildLoginScreen() {
  //   if (context.watch<FetchSystemSettingsCubit>().state
  //       is FetchSystemSettingsInProgress) {
  //     return Container(
  //       height: MediaQuery.of(context).size.height * 0.6,
  //       width: MediaQuery.of(context).size.width,
  //       alignment: Alignment.center,
  //       child: UiUtils.progress(),
  //     );
  //   }
  //   if (context.watch<FetchSystemSettingsCubit>().state
  //       is FetchSystemSettingsSuccess) {
  //     final phoneLogin = context
  //         .read<FetchSystemSettingsCubit>()
  //         .getSetting(SystemSetting.numberWithOtpLogin);
  //     final socialLogin = context
  //         .read<FetchSystemSettingsCubit>()
  //         .getSetting(SystemSetting.socialLogin);
  //     if (phoneLogin == '1' && socialLogin == '1') {
  //       return Padding(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Row(
  //               children: [
  //                 Text(UiUtils.translate(context, 'enterYourNumber'))
  //                     .size(context.font.xxLarge)
  //                     .bold(weight: FontWeight.w700)
  //                     .color(context.color.textColorDark),
  //               ],
  //             ),
  //             SizedBox(
  //               height: 15.rh(context),
  //             ),
  //             Row(
  //               children: [
  //                 Text(
  //                   UiUtils.translate(context, 'weSendYouCode'),
  //                 )
  //                     .size(context.font.large)
  //                     .color(context.color.textColorDark.withOpacity(0.8)),
  //               ],
  //             ),
  //             SizedBox(
  //               height: 41.rh(context),
  //             ),
  //             buildMobileNumberField(),
  //             SizedBox(
  //               height: size.height * 0.05,
  //             ),
  //             buildNextButton(context),
  //             SizedBox(
  //               height: 20.rh(context),
  //             ),
  //             if (true) ...[
  //               Center(
  //                 child: Text('orContinueWith'.translate(context)),
  //               ),
  //               SizedBox(
  //                 height: 20.rh(context),
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   if (defaultTargetPlatform == TargetPlatform.iOS)
  //                     GestureDetector(
  //                       onTap: () {
  //                         HelperUtils.unfocus();
  //                         _onTapAppleLogin();
  //                       },
  //                       child: Container(
  //                         width: 50,
  //                         height: 50,
  //                         decoration: BoxDecoration(
  //                           color: context.color.secondaryColor,
  //                           borderRadius: BorderRadius.circular(10),
  //                           border: Border.all(
  //                             color: context.color.borderColor,
  //                             width: 1.5,
  //                           ),
  //                         ),
  //                         child: FittedBox(
  //                           fit: BoxFit.none,
  //                           child: SvgPicture.asset(
  //                             AppIcons.apple,
  //                             height: 25,
  //                             width: 25,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   const SizedBox(
  //                     width: 10,
  //                   ),
  //                   GestureDetector(
  //                     onTap: () {
  //                       HelperUtils.unfocus();
  //                       _onGoogleTap.call();
  //                     },
  //                     child: Container(
  //                       width: 50,
  //                       height: 50,
  //                       decoration: BoxDecoration(
  //                         color: context.color.secondaryColor,
  //                         borderRadius: BorderRadius.circular(10),
  //                         border: Border.all(
  //                           color: context.color.borderColor,
  //                           width: 1.5,
  //                         ),
  //                       ),
  //                       child: FittedBox(
  //                         fit: BoxFit.none,
  //                         child: SvgPicture.asset(
  //                           AppIcons.google,
  //                           height: 25,
  //                           width: 25,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //             const SizedBox(
  //               height: 25,
  //             ),
  //             buildTermsAndPrivacyWidget(),
  //           ],
  //         ),
  //       );
  //     } else if (phoneLogin == '1' && socialLogin == '0') {
  //       return Padding(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           children: <Widget>[
  //             Row(
  //               children: [
  //                 Text(UiUtils.translate(context, 'enterYourNumber'))
  //                     .size(context.font.xxLarge)
  //                     .bold(weight: FontWeight.w700)
  //                     .color(context.color.textColorDark),
  //               ],
  //             ),
  //             SizedBox(
  //               height: 15.rh(context),
  //             ),
  //             Row(
  //               children: [
  //                 Text(
  //                   UiUtils.translate(context, 'weSendYouCode'),
  //                 )
  //                     .size(context.font.large)
  //                     .color(context.color.textColorDark.withOpacity(0.8)),
  //               ],
  //             ),
  //             SizedBox(
  //               height: 41.rh(context),
  //             ),
  //             buildMobileNumberField(),
  //             SizedBox(
  //               height: size.height * 0.05,
  //             ),
  //             buildNextButton(context),
  //             SizedBox(
  //               height: 20.rh(context),
  //             ),
  //             buildTermsAndPrivacyWidget(),
  //           ],
  //         ),
  //       );
  //     } else if (phoneLogin == '0' && socialLogin == '1') {
  //       return Container(
  //         height: MediaQuery.of(context).size.height * 0.75,
  //         width: MediaQuery.of(context).size.width,
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           children: <Widget>[
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     UiUtils.translate(context, 'loginToYourAccount'),
  //                     style: TextStyle(
  //                       color: context.color.textColorDark,
  //                     ),
  //                   )
  //                       .setMaxLines(lines: 2)
  //                       .size(context.font.xxLarge)
  //                       .bold(weight: FontWeight.w700)
  //                       .color(context.color.textColorDark),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(
  //               height: 20.rh(context),
  //             ),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     UiUtils.translate(context, 'loginSecurelyWith'),
  //                     style: TextStyle(
  //                       color: context.color.textColorDark,
  //                     ),
  //                   )
  //                       .size(context.font.large)
  //                       .color(context.color.textColorDark),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(
  //               height: 20.rh(context),
  //             ),
  //             SizedBox(
  //               height: 20.rh(context),
  //             ),
  //             if (defaultTargetPlatform == TargetPlatform.iOS) ...[
  //               GestureDetector(
  //                 onTap: () {
  //                   HelperUtils.unfocus();
  //                   _onTapAppleLogin();
  //                 },
  //                 child: Container(
  //                   width: MediaQuery.of(context).size.width * 0.9,
  //                   height: 50,
  //                   decoration: BoxDecoration(
  //                     color: context.color.secondaryColor,
  //                     borderRadius: BorderRadius.circular(10),
  //                     border: Border.all(
  //                       color: context.color.borderColor,
  //                       width: 1.5,
  //                     ),
  //                   ),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       const SizedBox(
  //                         width: 10,
  //                       ),
  //                       FittedBox(
  //                         fit: BoxFit.none,
  //                         child: SvgPicture.asset(
  //                           AppIcons.apple,
  //                           height: 25,
  //                           width: 25,
  //                         ),
  //                       ),
  //                       const SizedBox(
  //                         width: 10,
  //                       ),
  //                       Text(
  //                         UiUtils.translate(context, 'signInWithApple'),
  //                         style: TextStyle(
  //                           color: context.color.textColorDark,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(
  //                 height: 10,
  //               ),
  //               Text(
  //                 UiUtils.translate(context, 'or'),
  //                 style: TextStyle(
  //                   color: context.color.textColorDark,
  //                 ),
  //               ),
  //               const SizedBox(
  //                 height: 10,
  //               ),
  //             ],
  //             GestureDetector(
  //               onTap: () {
  //                 HelperUtils.unfocus();
  //                 _onGoogleTap.call();
  //               },
  //               child: Container(
  //                 width: MediaQuery.of(context).size.width * 0.9,
  //                 height: 50,
  //                 decoration: BoxDecoration(
  //                   color: context.color.secondaryColor,
  //                   borderRadius: BorderRadius.circular(10),
  //                   border: Border.all(
  //                     color: context.color.borderColor,
  //                     width: 1.5,
  //                   ),
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     const SizedBox(
  //                       width: 10,
  //                     ),
  //                     FittedBox(
  //                       fit: BoxFit.none,
  //                       child: SvgPicture.asset(
  //                         AppIcons.google,
  //                         height: 25,
  //                         width: 25,
  //                       ),
  //                     ),
  //                     const SizedBox(
  //                       width: 10,
  //                     ),
  //                     Text(
  //                       UiUtils.translate(context, 'signInWithGoogle'),
  //                       style: TextStyle(
  //                         color: context.color.textColorDark,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             const Spacer(),
  //             buildTermsAndPrivacyWidget(),
  //           ],
  //         ),
  //       );
  //     } else {
  //       return Padding(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Row(
  //               children: [
  //                 Text(UiUtils.translate(context, 'enterYourNumber'))
  //                     .size(context.font.xxLarge)
  //                     .bold(weight: FontWeight.w700)
  //                     .color(context.color.textColorDark),
  //               ],
  //             ),
  //             SizedBox(
  //               height: 15.rh(context),
  //             ),
  //             Row(
  //               children: [
  //                 Text(
  //                   UiUtils.translate(context, 'weSendYouCode'),
  //                 )
  //                     .size(context.font.large)
  //                     .color(context.color.textColorDark.withOpacity(0.8)),
  //               ],
  //             ),
  //             SizedBox(
  //               height: 41.rh(context),
  //             ),
  //             buildMobileNumberField(),
  //             SizedBox(
  //               height: size.height * 0.05,
  //             ),
  //             buildNextButton(context),
  //             SizedBox(
  //               height: 20.rh(context),
  //             ),
  //             buildTermsAndPrivacyWidget(),
  //           ],
  //         ),
  //       );
  //     }
  //   } else {
  //     return const SomethingWentWrong();
  //   }
  // }

  Widget buildLoginScreen(BuildContext context) {
    return BlocConsumer<FetchSystemSettingsCubit, FetchSystemSettingsState>(
      listener: (context, state) {
        if (state is FetchSystemSettingsInProgress) {
          // unawaited(Widgets.showLoader(context));
        }
        if (state is FetchSystemSettingsSuccess) {
          Widgets.hideLoder(context);
        }
      },
      builder: (context, state) {
        if (state is FetchSystemSettingsSuccess) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildLoginContent(context),
          );
        } else if (state is FetchSystemSettingsFailure) {
          return const Center(child: SomethingWentWrong());
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildLoginContent(BuildContext context) {
    final phoneLogin = context
        .read<FetchSystemSettingsCubit>()
        .getSetting(SystemSetting.numberWithOtpLogin);
    final socialLogin = context
        .read<FetchSystemSettingsCubit>()
        .getSetting(SystemSetting.socialLogin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //   if (socialLogin == '0') ...[
        _buildTitle(context),
        SizedBox(height: 15.rh(context)),
        _buildSubtitle(context),
        SizedBox(height: 41.rh(context)),
        buildLoginForm(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        buildNextButton(context),
        SizedBox(height: 20.rh(context)),
        Center(child: Text('orContinueWith'.translate(context))),
        SizedBox(height: 20.rh(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (defaultTargetPlatform == TargetPlatform.iOS)
              _buildSocialButton(
                context: context,
                icon: AppIcons.apple,
                onTap: _onTapAppleLogin,
              ),
            const SizedBox(width: 10),
            _buildSocialButton(
              context: context,
              icon: AppIcons.google,
              onTap: _onGoogleTap,
            ),
          ],
        ),
        /*  ],
        if (socialLogin == '1') _buildSocialLoginSection(context, phoneLogin),*/
        SizedBox(height: 20.rh(context)),
        buildTermsAndPrivacyWidget(),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(UiUtils.translate(context, 'enterYourNumber'))
        .size(context.font.xxLarge)
        .bold(weight: FontWeight.w700)
        .color(context.color.textColorDark);
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(UiUtils.translate(context, 'weSendYouCode'))
        .size(context.font.large)
        .color(context.color.textColorDark.withOpacity(0.8));
  }

  Widget _buildSocialLoginSection(BuildContext context, String phoneLogin) {
    if (phoneLogin == '0') {
      return Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Text(
                  UiUtils.translate(context, 'loginToYourAccount'),
                  style: TextStyle(
                    color: context.color.textColorDark,
                  ),
                )
                    .setMaxLines(lines: 2)
                    .size(context.font.xxLarge)
                    .bold(weight: FontWeight.w700)
                    .color(context.color.textColorDark),
              ),
            ],
          ),
          SizedBox(
            height: 20.rh(context),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  UiUtils.translate(context, 'loginSecurelyWith'),
                  style: TextStyle(
                    color: context.color.textColorDark,
                  ),
                ).size(context.font.large).color(context.color.textColorDark),
              ),
            ],
          ),
          SizedBox(
            height: 20.rh(context),
          ),
          SizedBox(
            height: 20.rh(context),
          ),
          if (defaultTargetPlatform == TargetPlatform.iOS) ...[
            GestureDetector(
              onTap: () {
                HelperUtils.unfocus();
                _onTapAppleLogin();
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.color.borderColor,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    FittedBox(
                      fit: BoxFit.none,
                      child: SvgPicture.asset(
                        AppIcons.apple,
                        height: 25,
                        width: 25,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      UiUtils.translate(context, 'signInWithApple'),
                      style: TextStyle(
                        color: context.color.textColorDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              UiUtils.translate(context, 'or'),
              style: TextStyle(
                color: context.color.textColorDark,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
          GestureDetector(
            onTap: () {
              HelperUtils.unfocus();
              _onGoogleTap.call();
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 50,
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.color.borderColor,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  FittedBox(
                    fit: BoxFit.none,
                    child: SvgPicture.asset(
                      AppIcons.google,
                      height: 25,
                      width: 25,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    UiUtils.translate(context, 'signInWithGoogle'),
                    style: TextStyle(
                      color: context.color.textColorDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          SizedBox(height: 15.rh(context)),
          _buildSubtitle(context),
          SizedBox(height: 41.rh(context)),
          buildLoginForm(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          buildNextButton(context),
          SizedBox(height: 20.rh(context)),
          Center(child: Text('orContinueWith'.translate(context))),
          SizedBox(height: 20.rh(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (defaultTargetPlatform == TargetPlatform.iOS)
                _buildSocialButton(
                  context: context,
                  icon: AppIcons.apple,
                  onTap: _onTapAppleLogin,
                ),
              const SizedBox(width: 10),
              _buildSocialButton(
                context: context,
                icon: AppIcons.google,
                onTap: _onGoogleTap,
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HelperUtils.unfocus();
        onTap();
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.color.borderColor,
            width: 1.5,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.none,
          child: SvgPicture.asset(
            icon,
            height: 25,
            width: 25,
          ),
        ),
      ),
    );
  }

  Widget resendOtpTimerWidget() {
    return ValueListenableBuilder(
      valueListenable: otpResendTime,
      builder: (context, value, child) {
        if (!(timer?.isActive ?? false)) {
          return const SizedBox.shrink();
        }
        String formatSecondsToMinutes(int seconds) {
          final minutes = seconds ~/ 60;
          final remainingSeconds = seconds % 60;
          return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
        }

        return SizedBox(
          height: 70,
          child: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: "${UiUtils.translate(context, "resendMessage")} ",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.textColorDark,
                  letterSpacing: 0.5,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: formatSecondsToMinutes(int.parse(value.toString())),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiaryColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: UiUtils.translate(
                      context,
                      'resendMessageDuration',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiaryColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildLoginForm() {
    return Column(
      children: [
        // Email Field
        CustomTextFormField(
          action: TextInputAction.next,
          controller: emailController,
          isReadOnly: false,
          validator: CustomTextFieldValidator.email,
          hintText: UiUtils.translate(context, 'email'),
          keyboard: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 16),

        // Password Field
        CustomTextFormField(
          action: TextInputAction.done,
          controller: passwordController,
          isReadOnly: false,
          validator: CustomTextFieldValidator.password,
          hintText: UiUtils.translate(context, 'password'),
          keyboard: TextInputType.visiblePassword,
          textDirection: TextDirection.ltr,
          maxLine: 1,
          suffix: Icon(Icons.lock_outline, color: context.color.textColorDark),
        ),
      ],
    );
  }

  void showCountryCode() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(11),
        backgroundColor: context.color.backgroundColor,
        inputDecoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          iconColor: context.color.tertiaryColor,
          prefixIconColor: context.color.tertiaryColor,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.color.tertiaryColor),
          ),
          floatingLabelStyle: TextStyle(color: context.color.tertiaryColor),
          labelText: 'Search',
          border: const OutlineInputBorder(),
        ),
      ),
      favorite: ['+253'],
      onSelect: (Country value) {
        flagEmoji = value.flagEmoji;
        countryCode = value.phoneCode;
        setState(() {});
      },
    );
  }

  Future<void> sendVerificationCode({String? number}) async {
    if (AppSettings.otpServiceProvider == 'twilio' &&
        (widget.isDeleteAccount ?? false)) {
      try {
        await context
            .read<SendOtpCubit>()
            .sendTwilioOTP(phoneNumber: '+$number');
      } catch (e) {
        Widgets.hideLoder(context);
        HelperUtils.showSnackBarMessage(
          context,
          Strings.invalidPhoneMessage,
          type: MessageType.error,
        );
      }
    } else if (AppSettings.otpServiceProvider == 'firebase' &&
        (widget.isDeleteAccount ?? false)) {
      print("11111111111111111111111111111111111111111");
      try {
        await context
            .read<SendOtpCubit>()
            .sendFirebaseOTP(phoneNumber: '+$number');
      } catch (e) {
        Widgets.hideLoder(context);
        HelperUtils.showSnackBarMessage(
          context,
          Strings.invalidPhoneMessage,
          type: MessageType.error,
        );
      }
    }
    final form = _formKey.currentState;

    if (form == null) return;
    form.save();
    //checkbox value should be 1 before Login/SignUp
    try {
      if (form.validate()) {
        if (widget.isDeleteAccount ?? false) {
        } else if (AppSettings.otpServiceProvider == 'firebase') {
          await context.read<SendOtpCubit>().sendFirebaseOTP(
                phoneNumber: '+${countryCode!}${mobileNumController.text}',
              );
        } else if (AppSettings.otpServiceProvider == 'twilio') {
          await context.read<SendOtpCubit>().sendTwilioOTP(
                phoneNumber: '+${countryCode!}${mobileNumController.text}',
              );
        }
      }
    } catch (e) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(context, Strings.invalidPhoneMessage,
          type: MessageType.error);
    }
  }

  void onTapLogin(BuildContext context) async {
    final navigator = Navigator.of(context);
    try {
      if (AppSettings.otpServiceProvider == 'firebase') {
        if (widget.isDeleteAccount ?? false) {
          await context.read<VerifyOtpCubit>().verifyOTP(
                verificationId: verificationID,
                otp: otpIs,
              );
          print("11111111222222222222211111111111111");
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('static_key', 1);
          HiveUtils.setIsNotGuest();
          Navigator.pushReplacementNamed(
            context,
            Routes.main,
            arguments: {
              'from': 'login',
            },
          ); //Widgets.hideLoder(context);
        } else {
          print("111111111111111111111111111111111");

          await context.read<VerifyOtpCubit>().verifyOTP(
                verificationId: otpVerificationId,
                otp: otpIs,
              );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('static_key', 1);
          HiveUtils.setIsNotGuest();
          Navigator.pushReplacementNamed(
            context,
            Routes.main,
            arguments: {
              'from': 'login',
            },
          ); //Widgets.hideLoder(context);
        }
      } else if (AppSettings.otpServiceProvider == 'twilio') {
        await context.read<VerifyOtpCubit>().verifyOTP(
              otp: otpIs,
              number: '+${countryCode!}${mobileNumController.text}',
            );
      }
    } catch (e) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(context, 'invalidOtp'.translate(context));
    }
    if (otpIs.length < otpLength) {
      HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'lblEnterOtp'),
        messageDuration: 2,
      );
      return;
    }
  }

  Widget buildNextButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: buildButton(
        context,
        buttonTitle: UiUtils.translate(context, 'Login'),
        disabled: false,
        onPressed: /*sendVerificationCode*/ () {
          context.read<LoginCubit>().login(
                phoneNumber:
                    '000${DateTime.now().millisecondsSinceEpoch % 1000000}', // random dummy phone
                uniqueId: emailController.text.trim(), // used as auth_id
                type: LoginType.email,
                email: emailController.text.trim(),
                password: passwordController.text.trim(),
              );
        },
      ),
    );
  }

  Widget buildButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required String buttonTitle,
    double? height,
    double? width,
    bool? disabled,
  }) {
    return MaterialButton(
      minWidth: width ?? double.infinity,
      height: height ?? 56.rh(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.5,
      color: context.color.tertiaryColor,
      disabledColor: context.color.textLightColor,
      onPressed: (disabled != true)
          ? () {
              HelperUtils.unfocus();
              onPressed.call();
            }
          : null,
      child: Text(buttonTitle)
          .color(context.color.buttonColor)
          .size(context.font.larger),
    );
  }

  Widget loginButton(BuildContext context) {
    return buildButton(
      context,
      onPressed: () {
        onTapLogin(context);
      },
      buttonTitle: UiUtils.translate(
        context,
        'comfirmBtnLbl',
      ),
    );
  }

//otp
  Widget buildTermsAndPrivacyWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsetsDirectional.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        "${UiUtils.translate(context, "policyAggreementStatement")}\n",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.textColorDark,
                        ),
                  ),
                  TextSpan(
                    text: UiUtils.translate(context, 'termsConditions'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.tertiaryColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = (() {
                        HelperUtils.goToNextPage(
                          Routes.profileSettings,
                          context,
                          false,
                          args: {
                            'title':
                                UiUtils.translate(context, 'termsConditions'),
                            'param': Api.termsAndConditions,
                          },
                        );
                      }),
                  ),
                  TextSpan(
                    text: " ${UiUtils.translate(context, "and")} ",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.textColorDark,
                        ),
                  ),
                  TextSpan(
                    text: UiUtils.translate(context, 'privacyPolicy'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.tertiaryColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = (() {
                        HelperUtils.goToNextPage(
                          Routes.profileSettings,
                          context,
                          false,
                          args: {
                            'title':
                                UiUtils.translate(context, 'privacyPolicy'),
                            'param': Api.privacyPolicy,
                          },
                        );
                      }),
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
