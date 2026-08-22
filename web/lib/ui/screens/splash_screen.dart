// import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:immozen/data/model/system_settings_model.dart';
import 'package:immozen/data/repositories/system_repository.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

// import '../app/routes.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:immozen/utils/hive_keys.dart';
import 'package:flutter/foundation.dart';
// import 'package:immozen/main.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AuthenticationState authenticationState;

  bool isTimerCompleted = false;
  bool isSettingsLoaded = false;
  bool isLanguageLoaded = false;

  @override
  void initState() {
    context.read<FetchCategoryCubit>().fetchCategories();
    context.read<FetchOutdoorFacilityListCubit>().fetch();
    locationPermission();
    checkIsUserAuthenticated();

    super.initState();
    setState(() {
      isLanguageLoaded = true;
    });

    Connectivity().checkConnectivity().then((value) {
      if (value.contains(ConnectivityResult.none)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return NoInternet(
                onRetry: () async {
                  try {
                    await LoadAppSettings().load(true);
                    if (context.color.brightness == Brightness.light) {
                      context.read<AppThemeCubit>().changeTheme(AppTheme.light);
                    } else {
                      context.read<AppThemeCubit>().changeTheme(AppTheme.dark);
                    }
                  } catch (e) {
                    log('no internet');
                  }
                  Future.delayed(
                    Duration.zero,
                    () {
                      Navigator.pushReplacementNamed(
                        context,
                        Routes.splash,
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      }
    });
    startTimer();
    //get Currency Symbol from Admin Panel
    Future.delayed(Duration.zero, () {
      context.read<ProfileSettingCubit>().fetchProfileSetting(
            context,
            Api.currencySymbol,
          );
    });
  }

  Future<void> locationPermission() async {
    if ((await Permission.location.status) == PermissionStatus.denied) {
      await Permission.location.request();
    }
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  Future<void> checkIsUserAuthenticated() async {
    authenticationState = context.read<AuthenticationCubit>().state;
    if (authenticationState == AuthenticationState.authenticated) {
      ///Only load sensitive details if user is authenticated
      ///This call will load sensitive details with settings
      await context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymouse: false,
          );
      completeProfileCheck();
    } else {
      //This call will hide sensitive details.
      await context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymouse: true,
          );
    }
  }

  Future<void> startTimer() async {
    Timer(const Duration(milliseconds: 300), () {
      isTimerCompleted = true;
      if (mounted) setState(() {});
    });
  }

  void navigateCheck() {
    ({
      'timer': isTimerCompleted,
      'setting': isSettingsLoaded,
      'language': isLanguageLoaded,
    }).logg;

    if (isTimerCompleted && isSettingsLoaded && isLanguageLoaded) {
      navigateToScreen();
    }
  }

  void completeProfileCheck() {
    if (HiveUtils.getUserDetails().name == '' ||
        HiveUtils.getUserDetails().email == '') {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          /*  Navigator.pushReplacementNamed(
            context,
            Routes.completeProfile,
            arguments: {
              'from': 'login',
            },
          );*/
          Navigator.pushReplacementNamed(
            context,
            Routes.main,
            arguments: {
              'from': 'login',
            },
          );
        },
      );
    }
  }

  void navigateToScreen() {
    if (context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.maintenanceMode) ==
        '1') {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(
          Routes.maintenanceMode,
        );
      });
    } else if (authenticationState == AuthenticationState.authenticated) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context)
            .pushReplacementNamed(Routes.main, arguments: {'from': 'main'});
      });
    } else if (authenticationState == AuthenticationState.unAuthenticated) {
      if (Hive.box(HiveKeys.userDetailsBox).get('isGuest') == true) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context)
              .pushReplacementNamed(Routes.main, arguments: {'from': 'splash'});
        });
      } else {
        /* Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });*/

        Future.delayed(Duration.zero, () {
          Navigator.of(context)
              .pushReplacementNamed(Routes.main, arguments: {'from': 'splash'});
        });
      }
    } else if (authenticationState == AuthenticationState.firstTime) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(Routes.onboarding);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    navigateCheck();

    return BlocListener<FetchLanguageCubit, FetchLanguageState>(
      listener: (context, state) {},
      child: BlocListener<FetchSystemSettingsCubit, FetchSystemSettingsState>(
        listener: (context, state) {
          if (state is FetchSystemSettingsFailure) {
            log('FetchSystemSettings Issue while load system settings ${state.errorMessage}');
          }
          if (state is FetchSystemSettingsSuccess) {
            if (kDebugMode) {
              print('FetchSystemSettingsSuccess');
            }
            final setting = [];
            if (setting.isNotEmpty) {
              if ((setting[0] as Map).containsKey('package_id')) {
                Constant.subscriptionPackageId = '';
              }
            }

            if (state.settings['data'].containsKey('demo_mode')) {
              Constant.isDemoModeOn =
                  state.settings['data']['demo_mode'] ?? false;
            }
            isSettingsLoaded = true;
            setState(() {});
          }
        },
        child: AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarColor: context.color.tertiaryColor,
          ),
          child: Scaffold(
            backgroundColor: context.color.tertiaryColor,
            body: Stack(
              children: [
                Align(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      'assets/AppIcon/icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    key: const ValueKey('companylogo'),
                    child: UiUtils.getSvg(AppIcons.companyLogo,
                        width: 200, color: secondaryColor_),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        final Uri url =
                            Uri.parse("https://hzein-technology.com/");
                        try {
                          if (!await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          )) {
                            throw 'Could not launch $url';
                          }
                        } catch (e) {
                          print("Error launching URL: $e");
                        }
                      },
                      child: Text(
                        'Developed by Hzein Technologie',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future getDefaultLanguage(VoidCallback onSuccess) async {
  try {
    // await Hive.initFlutter();v
    await Hive.openBox(HiveKeys.languageBox);
    await Hive.openBox(HiveKeys.userDetailsBox);
    await Hive.openBox(HiveKeys.authBox);

    if (kDebugMode) {
      print(
        'Here in SplashScreen HiveBox ${Hive.isBoxOpen(HiveKeys.languageBox)}',
      );
    }
    if (kDebugMode) {
      print('${HiveUtils.getLanguage()}');
    }
    if (HiveUtils.getLanguage() == null ||
        HiveUtils.getLanguage()?['data'] == null) {
      final result = await SystemRepository().fetchSystemSettings(
        isAnonymouse: true,
      );

      final code = result['data']['default_language'];

      await Api.get(
        url: Api.getLanguagae,
        queryParameters: {
          Api.languageCode: code,
        },
        useAuthToken: false,
      ).then((value) {
        HiveUtils.storeLanguage({
          'code': value['data']['code'],
          'data': value['data']['file_name'],
          'name': value['data']['name'],
          'isRTL': value['data']['rtl']?.toString() == '1',
        });
        onSuccess.call();
      });
    } else {
      onSuccess.call();
    }
  } catch (e, st) {
    log('Error while load default language $st');
  }
}
