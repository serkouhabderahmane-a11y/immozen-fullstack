import 'package:immozen/app/app_theme.dart';
import 'package:immozen/data/cubits/property/fetch_my_properties_cubit.dart';
import 'package:immozen/data/cubits/system/app_theme_cubit.dart';
import 'package:immozen/ui/screens/main_activity.dart';
import 'package:immozen/ui/screens/proprties/Property%20tab/sell_rent_screen.dart';
import 'package:immozen/utils/Extensions/extensions.dart';
import 'package:immozen/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

int propertyScreenCurrentPage = 0;
ValueNotifier<Map> emptyCheckNotifier =
    ValueNotifier({'isSellEmpty': false, 'isRentEmpty': false});

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => MyPropertyState();
}

class MyPropertyState extends State<PropertiesScreen>
    with TickerProviderStateMixin {
  int offset = 0;
  int total = 0;
  int selectTab = 0;
  final PageController _pageController = PageController();
  bool isSellEmpty = false;
  bool isRentEmpty = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarDividerColor: Colors.transparent,
        // systemNavigationBarColor: Theme.of(context).colorScheme.secondaryColor,
        systemNavigationBarIconBrightness:
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? Brightness.light
                : Brightness.dark,
        //
        statusBarColor: Theme.of(context).colorScheme.secondaryColor,
        statusBarBrightness:
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? Brightness.dark
                : Brightness.light,
        statusBarIconBrightness:
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? Brightness.light
                : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(
          context,
          title: 'myProperty'.translate(context),
          bottomHeight: 49,
          bottom: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                customTab(
                  context,
                  isSelected: selectTab == 0,
                  onTap: () {
                    selectTab = 0;
                    propertyScreenCurrentPage = 0;
                    setState(() {});
                    _pageController.jumpToPage(0);
                    cubitReference = context.read<FetchMyPropertiesCubit>();
                    propertyType = 'sell';
                  },
                  name: UiUtils.translate(context, 'sell'),
                  onDoubleTap: () {},
                ),
                customTab(
                  context,
                  isSelected: selectTab == 1,
                  onTap: () {
                    _pageController.jumpToPage(1);
                    selectTab = 1;
                    propertyScreenCurrentPage = 1;

                    cubitReference = context.read<FetchMyPropertiesCubit>();
                    propertyType = 'rent';

                    setState(() {});
                  },
                  onDoubleTap: () {},
                  name: UiUtils.translate(context, 'rent'),
                ),
              ],
            ),
          ],
        ),
        body: ScrollConfiguration(
          behavior: RemoveGlow(),
          child: PageView(
            onPageChanged: (value) {
              propertyScreenCurrentPage = value;
              selectTab = value;
              setState(() {});
            },
            controller: _pageController,
            children: [
              BlocProvider(
                create: (context) => FetchMyPropertiesCubit(),
                child: SellRentScreen(
                  type: 'sell',
                  key: const Key('0'),
                  controller: sellScreenController,
                ),
              ),
              BlocProvider(
                create: (context) => FetchMyPropertiesCubit(),
                child: SellRentScreen(
                  type: 'rent',
                  key: const Key('1'),
                  controller: rentScreenController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customTab(
    BuildContext context, {
    required bool isSelected,
    required String name,
    required Function() onTap,
    required Function() onDoubleTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: context.color.backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? context.color.tertiaryColor
                  : context.color.backgroundColor,
              width: 2,
            ),
          ),
        ),
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        height: 40,
        child: Center(
          child: Text(name).size(context.font.large),
        ),
      ),
    );
  }
}
