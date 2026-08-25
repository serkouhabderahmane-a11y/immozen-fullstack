// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:immozen/data/cubits/home_page_data_cubit.dart';
import 'package:immozen/data/cubits/property/fetch_city_property_list.dart';
import 'package:immozen/data/cubits/property/home_infinityscroll_cubit.dart';
import 'package:immozen/data/helper/design_configs.dart';
import 'package:immozen/data/model/agent/agent_model.dart';
import 'package:immozen/data/model/category.dart';
import 'package:immozen/data/model/home_slider.dart';
import 'package:immozen/data/model/project_model.dart';
import 'package:immozen/data/model/system_settings_model.dart';
import 'package:immozen/data/repositories/project_repository.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:immozen/ui/screens/agents/agents_card.dart';
import 'package:immozen/ui/screens/home/Widgets/property_card_big.dart';
import 'package:immozen/ui/screens/home/Widgets/property_gradient_card.dart';
import 'package:immozen/ui/screens/home/widgets/category_card.dart';
import 'package:immozen/ui/screens/home/widgets/city_heading_card.dart';
import 'package:immozen/ui/screens/home/widgets/header_card.dart';
import 'package:immozen/ui/screens/home/widgets/homeListener.dart';
import 'package:immozen/ui/screens/home/widgets/home_profile_image_card.dart';
import 'package:immozen/ui/screens/home/widgets/home_search.dart';
import 'package:immozen/ui/screens/home/widgets/home_shimmers.dart';
import 'package:immozen/ui/screens/home/widgets/location_widget.dart';
import 'package:immozen/ui/screens/proprties/viewAll.dart';
import 'package:immozen/utils/admob/bannerAdLoadWidget.dart';
import 'package:immozen/utils/network/networkAvailability.dart';
import 'package:immozen/utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
// JWT Token

const double sidePadding = 18;

class HomeScreen extends StatefulWidget {
  final String? from;

  const HomeScreen({super.key, this.from});

  @override
  HomeScreenState createState() => HomeScreenState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map;
    return BlurredRouter(
      builder: (_) => HomeScreen(from: arguments['from'] as String),
    );
  }
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;
  List<PropertyModel> propertyLocalList = [];
  bool isCategoryEmpty = false;
  HomePageStateListener homeStateListener = HomePageStateListener();

  @override
  void initState() {
    DeepLinkManager.initDeepLinks(context);
    context.read<HomePageInfinityScrollCubit>().fetch();
    context.read<FetchHomePageDataCubit>().fetch(
          forceRefresh: false,
        );
    AppLinks().getInitialLink().then((value) {
      if (value == null) return;
      // Navigator.push(
      //   Constant.navigatorKey.currentContext!,
      //   NativeLinkWidget.render(
      //     RouteSettings(name: value.toString()),
      //   ),
      // );
    });
    AppLinks().uriLinkStream.listen((event) {
      // Navigator.push(
      //   Constant.navigatorKey.currentContext!,
      //   NativeLinkWidget.render(
      //     RouteSettings(name: event.toString()),
      //   ),
      // );
    });

    initializeSettings();
    addPageScrollListener();
    notificationPermissionChecker();
    fetchApiKeys();
    initializeHomeStateListener();
    super.initState();
  }

  void initializeSettings() {
    final settingsCubit = context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment(
      'force-disable-demo-mode',
    )) {
      Constant.isDemoModeOn =
          settingsCubit.getSetting(SystemSetting.demoMode) ?? false;
    }
  }

  void addPageScrollListener() {
    homeScreenController.addListener(pageScrollListener);
  }

  void initializeHomeStateListener() {
    homeStateListener.init(
      setState,
      onNetAvailable: () {
        if (mounted) {
          loadInitialData(
            context,
          );
        }
      },
    );
  }

  void fetchApiKeys() {
    if (context.read<AuthenticationCubit>().isAuthenticated()) {
      context.read<GetApiKeysCubit>().fetch();
    }
  }

  void pageScrollListener() {
    ///This will load data on page end
    if (homeScreenController.isEndReached()) {
      if (mounted) {
        if (context.read<HomePageInfinityScrollCubit>().hasMoreData()) {
          context.read<HomePageInfinityScrollCubit>().fetchMore();
        }
      }
    }
  }

  void _onTapPromotedSeeAll() {
    Navigator.pushNamed(context, Routes.promotedPropertiesScreen);
  }

  void _onTapNearByPropertiesAll() {
    final StateMap stateMap = StateMap<
        FetchNearbyPropertiesInitial,
        FetchNearbyPropertiesInProgress,
        FetchNearbyPropertiesSuccess,
        FetchNearbyPropertiesFailure>();

    ViewAllScreen<FetchNearbyPropertiesCubit, FetchNearbyPropertiesState>(
      title: 'nearByProperties'.translate(context),
      map: stateMap,
    ).open(context);
  }

  void _onTapMostLikedAll() {
    Navigator.pushNamed(context, Routes.mostLikedPropertiesScreen);
  }

  void _onTapMostViewedSeeAll() {
    Navigator.pushNamed(context, Routes.mostViewedPropertiesScreen);
  }

  void _onRefresh() {
    context.read<FetchNearbyPropertiesCubit>().fetch(
          forceRefresh: true,
        );
    context.read<FetchCityCategoryCubit>().fetchCityCategory(
          forceRefresh: true,
        );
    context.read<FetchPersonalizedPropertyList>().fetch(
          forceRefresh: true,
        );
    context.read<FetchHomePageDataCubit>().fetch(
          forceRefresh: true,
        );
    if (GuestChecker.value == false) {
      context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymouse: false,
            forceRefresh: true,
          );
    }
    setState(() {});
  }
void initializeFCMToken() async {
  log('initializeFCMToken called (Firebase Messaging removed)');
}

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final homeScreenState = homeStateListener.listen(context);
    HiveUtils.getJWT()?.log('JWT');

    ///
    return SafeArea(
      child: RefreshIndicator(
        color: context.color.tertiaryColor,
        onRefresh: () async {
          await CheckInternet.check(
            onInternet: () {
              _onRefresh();
            },
            onNoInternet: () {
              HelperUtils.showSnackBarMessage(
                context,
                'noInternet'.translate(context),
              );
            },
          );
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leadingWidth: (HiveUtils.getCityName() != null &&
                    HiveUtils.getCityName().toString().isNotEmpty)
                ? 200.rw(context)
                : 130,
            leading: Padding(
              padding: EdgeInsetsDirectional.only(
                start: sidePadding.rw(context),
              ),
              child: (HiveUtils.getCityName() != null &&
                      HiveUtils.getCityName().toString().isNotEmpty)
                  ? const LocationWidget()
                  : SizedBox(
                      child: LoadAppSettings().svg(appSettings.appHomeScreen!),
                    ),
            ),
            backgroundColor: const Color.fromARGB(0, 0, 0, 0),
            actions: [
              GuestChecker.updateUI(
                onChangeStatus: (bool? isGuest) {
                  Widget buildDefaultPersonSVG(BuildContext context) {
                    return Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: context.color.tertiaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: UiUtils.getSvg(
                          AppIcons.defaultPersonLogo,
                          color: context.color.tertiaryColor,
                          // fit: BoxFit.none,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    );
                  }

                  if (isGuest == null) {
                    return buildDefaultPersonSVG(context);
                  } else if (isGuest == true) {
                    return const SizedBox(
                      width: 90,
                    );
                  } else {
                    return const CircularProfileImageWidget();
                  }
                },
              ),
            ],
          ),
          backgroundColor: context.color.primaryColor,
          body: Builder(
            builder: (context) {
              if (homeScreenState.state == HomeScreenDataState.fail) {
                return const SomethingWentWrong();
              }
              return BlocConsumer<FetchSystemSettingsCubit,
                  FetchSystemSettingsState>(
                listener: (context, state) {
                  if (state is FetchHomePageDataLoading) {
                    //const HomeShimmer();
                    homeStateListener.setNetworkState(setState, true);
                    setState(() {});
                  }
                  if (state is FetchSystemSettingsSuccess) {
                    homeStateListener.setNetworkState(setState, true);
                    setState(() {});
                  }
                },
                builder: (context, state) {
                  if (homeScreenState.state == HomeScreenDataState.success) {
                  } else if (homeScreenState.state ==
                      HomeScreenDataState.nointernet) {
                    return NoInternet(
                      onRetry: () async {
                        await CheckInternet.check(
                          onInternet: () {
                            _onRefresh();
                          },
                          onNoInternet: () {
                            HelperUtils.showSnackBarMessage(
                              context,
                              'noInternet'.translate(context),
                            );
                          },
                        );
                      },
                    );
                  }

                  if (homeScreenState.state == HomeScreenDataState.nodata) {
                    return Center(
                      child: NoDataFound(
                        onTap: () {
                          context.read<FetchHomePageDataCubit>().fetch(
                                forceRefresh: false,
                              );
                        },
                      ),
                    );
                  }
                  return BlocBuilder<FetchHomePageDataCubit,
                      FetchHomePageDataState>(
                    builder: (homeContext, homeState) {
                      print('HomeScreenState: ${homeScreenState.state}');
                      print('homeState is: ${homeState.runtimeType}');

                      if (homeState is FetchHomePageDataLoading) {
                        //return const HomeShimmer();
                      }

                      if (homeState is FetchHomePageDataSuccess) {
                        final home = homeState.homePageDataModel;
                        print('Slider Count: ${home.sliderSection?.length}');
                        print(
                            'Categories Count: ${home.categoriesSection?.length}');
                        print(
                            'Featured Properties Count: ${home.featuredSection?.length}');
                        print('Agents Count: ${home.agentsList?.length}');
                        print(
                            'Most Liked Properties: ${home.mostLikedProperties?.length}');
                        print(
                            'Most Viewed Properties: ${home.mostViewedProperties?.length}');
                        print('Projects Count: ${home.projectSection?.length}');
                        return SingleChildScrollView(
                          controller: homeScreenController,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).padding.top,
                          ),
                          child: BlocProvider(
                            create: (context) => FetchHomePageDataCubit(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ///Looping through sections so arrange it
                                ...List.generate(
                                  AppSettings.sections.length,
                                  (index) {
                                    final section = AppSettings.sections[index];
                                    if (section == HomeScreenSections.Search) {
                                      return const HomeSearchField();
                                    } else if (section ==
                                        HomeScreenSections.PersonalizedFeed) {
                                      return const PersonalizedPropertyWidget();
                                    } else if (section ==
                                        HomeScreenSections.Slider) {
                                      return sliderWidget(home.sliderSection);
                                    } else if (section ==
                                        HomeScreenSections.Category) {
                                      return categoryWidget(
                                        home.categoriesSection,
                                      );
                                    } else if (section ==
                                        HomeScreenSections.NearbyProperties) {
                                      return buildNearByProperties();
                                    } else if (section ==
                                        HomeScreenSections.FeaturedProperties) {
                                      return featuredProperties(
                                        home.featuredSection,
                                        context,
                                      );
                                    } else if (section ==
                                        HomeScreenSections.Agents) {
                                      return buildAgents(home.agentsList);
                                    } else if (section ==
                                        HomeScreenSections.RecentlyAdded) {
                                      return const RecentPropertiesSectionWidget();
                                    } else if (section ==
                                        HomeScreenSections
                                            .MostLikedProperties) {
                                      return mostLikedProperties(
                                        home.mostLikedProperties,
                                        context,
                                      );
                                    } else if (section ==
                                        HomeScreenSections.MostViewed) {
                                      return mostViewedProperties(
                                        home.mostViewedProperties,
                                        context,
                                      );
                                    } else if (section ==
                                        HomeScreenSections.PopularCities) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        child: Column(
                                          children: [
                                            //   const BannerAdWidget(),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            popularCityProperties(),
                                          ],
                                        ),
                                      );
                                    } else if (section ==
                                        HomeScreenSections.project) {
                                      return buildProjects(
                                        home.projectSection,
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),

                                BlocBuilder<HomePageInfinityScrollCubit,
                                    HomePageInfinityScrollState>(
                                  builder: (context, state) {
                                    if (state
                                        is HomePageInfinityScrollFailure) {}
                                    if (state
                                        is HomePageInfinityScrollInProgress) {
                                      return LayoutBuilder(
                                        builder: (context, c) {
                                          return ListView.builder(
                                            padding: const EdgeInsets.all(16),
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                                child: Row(
                                                  children: [
                                                    const ClipRRect(
                                                      clipBehavior: Clip
                                                          .antiAliasWithSaveLayer,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(15),
                                                      ),
                                                      child: CustomShimmer(
                                                        height: 90,
                                                        width: 90,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          CustomShimmer(
                                                            height: 10,
                                                            width: c.maxWidth -
                                                                100,
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          const CustomShimmer(
                                                            height: 10,
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          CustomShimmer(
                                                            height: 10,
                                                            width: c.maxWidth /
                                                                1.2,
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          CustomShimmer(
                                                            height: 10,
                                                            width:
                                                                c.maxWidth / 4,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            shrinkWrap: true,
                                            itemCount: 6,
                                          );
                                        },
                                      );
                                    }

                                    if (state
                                        is HomePageInfinityScrollSuccess) {
                                      return Builder(
                                        builder: (context) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TitleHeader(
                                                enableShowAll: false,
                                                title: UiUtils.translate(
                                                  context,
                                                  'allProperties',
                                                ),
                                              ),
                                              ListView.builder(
                                                shrinkWrap: true,
                                                padding: const EdgeInsets.only(
                                                  right: 16,
                                                  left: 16,
                                                  bottom: 16,
                                                ),
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    state.properties.length,
                                                itemBuilder: (context, index) {
                                                  return PropertyHorizontalCard(
                                                    property:
                                                        state.properties[index],
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),

                                if (context
                                    .watch<HomePageInfinityScrollCubit>()
                                    .isLoadingMore()) ...[
                                  Center(child: UiUtils.progress()),
                                ],
                                const SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  bool cityEmpty() {
    if (context.watch<FetchCityCategoryCubit>().state
        is FetchCityCategorySuccess) {
      return (context.watch<FetchCityCategoryCubit>().state
              as FetchCityCategorySuccess)
          .cities
          .isEmpty;
    }
    return true;
  }

  Widget buildProjects(List<ProjectModel> projectSection) {
    return Column(
      children: [
        if (projectSection.isNotEmpty) ...[
          TitleHeader(
            title: 'Project section'.translate(context),
            onSeeAll: () {
              Navigator.pushNamed(context, Routes.allProjectsScreen);
            },
          ),
          Container(
            height: 250,
            margin: const EdgeInsets.only(bottom: 8, right: 7),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: projectSection.length,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              separatorBuilder: (context, index) {
                return const SizedBox(
                  width: 8,
                );
              },
              itemBuilder: (context, index) {
                final project = projectSection[index];
                return GestureDetector(
                  onTap: () async {
                    GuestChecker.check(
                      onNotGuest: () async {
                        if (context
                                .read<FetchSystemSettingsCubit>()
                                .getRawSettings()['is_premium'] ??
                            false) {
                          try {
                           // unawaited(Widgets.showLoader(context));
                            final fetch = ProjectRepository();
                            final dataOutput =
                                await fetch.fetchProjectFromProjectId(
                              project.id,
                            );
                            Future.delayed(
                              Duration.zero,
                              () {
                                Widgets.hideLoder(context);
                                HelperUtils.goToNextPage(
                                  Routes.projectDetailsScreen,
                                  context,
                                  false,
                                  args: {
                                    'project': dataOutput.modelList[0],
                                  },
                                );
                              },
                            );
                          } catch (e) {
                            log('Error is $e');
                            Widgets.hideLoder(context);
                          }
                        } else {
                          if (project.addedBy.toString() ==
                              HiveUtils.getUserId()) {
                            try {
                              //unawaited(Widgets.showLoader(context));
                              final fetch = ProjectRepository();
                              final dataOutput =
                                  await fetch.fetchProjectFromProjectId(
                                project.id,
                              );
                              Future.delayed(
                                Duration.zero,
                                () {
                                  Widgets.hideLoder(context);
                                  HelperUtils.goToNextPage(
                                    Routes.projectDetailsScreen,
                                    context,
                                    false,
                                    args: {
                                      'project': dataOutput.modelList[0],
                                    },
                                  );
                                },
                              );
                            } catch (e) {
                              log('Error is $e');
                              Widgets.hideLoder(context);
                            }
                          } else {
                            await UiUtils.showBlurredDialoge(
                              context,
                              dialoge: BlurredDialogBox(
                                title: 'Subscription needed',
                                isAcceptContainesPush: true,
                                onAccept: () async {
                                  await Navigator.popAndPushNamed(
                                    context,
                                    Routes.subscriptionPackageListRoute,
                                    arguments: {'from': 'home'},
                                  );
                                },
                                content: const Text(
                                  'Subscribe to package if you want to use this feature',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                  child: ProjectCard(
                    title: project.title ?? '',
                    categoryIcon: project.category?.image ?? '',
                    url: project.image ?? '',
                    categoryName: project.category?.category ?? '',
                    description: project.description ?? '',
                    status: project.type ?? '',
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget buildAgents(List<AgentModel> agents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (agents.isNotEmpty)
          TitleHeader(
            title: UiUtils.translate(context, 'agents'),
            onSeeAll: () {
              Navigator.pushNamed(context, Routes.agentListScreen);
            },
          ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            itemCount: agents.length < 5 ? agents.length : 5,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return const SizedBox(
                width: 8,
              );
            },
            itemBuilder: (context, index) {
              final agent = agents[index];
              return GestureDetector(
                child: AgentCard(
                  agent: agent,
                  propertyCount: agent.propertyCount,
                  name: agent.name,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget popularCityProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!cityEmpty()) const CityHeadingCard(),
        const SizedBox(
          height: 8,
        ),
        /*  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: BlocBuilder<FetchCityCategoryCubit, FetchCityCategoryState>(
            builder: (context, FetchCityCategoryState state) {
              if (state is FetchCityCategorySuccess) {
                return StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    ...List.generate(10, (index) {
                      if (index % 4 == 0 || index % 5 == 0) {
                        return StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 2,
                          child: buildCityCard(state, index),
                        );
                      } else {
                        return StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: buildCityCard(state, index),
                        );
                      }
                    }),
                  ],
                );
              }
              return Container();
            },
          ),
        ),*/
      ],
    );
  }

  Widget mostViewedProperties(
    List<PropertyModel> mostViewedProperties,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostViewedProperties.isNotEmpty)
          TitleHeader(
            onSeeAll: _onTapMostViewedSeeAll,
            title: UiUtils.translate(context, 'mostViewed'),
          ),
        buildMostViewedProperties(mostViewedProperties),
      ],
    );
  }

  Widget mostLikedProperties(
    List<PropertyModel> mostLikedProperties,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostLikedProperties.isNotEmpty) ...[
          TitleHeader(
            onSeeAll: _onTapMostLikedAll,
            title: UiUtils.translate(
              context,
              'mostLikedProperties',
            ),
          ),
          buildMostLikedProperties(mostLikedProperties),
          const SizedBox(
            height: 15,
          ),
        ],
      ],
    );
  }

  Widget featuredProperties(
    List<PropertyModel> featuredProperties,
    BuildContext context,
  ) {
    if (featuredProperties.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleHeader(
            onSeeAll: _onTapPromotedSeeAll,
            title: UiUtils.translate(
              context,
              'promotedProperties',
            ),
          ),
          buildPromotedProperites(featuredProperties),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget sliderWidget(List<HomeSlider> sliderList) {
    if (sliderList.isNotEmpty) {
      return const SliderWidget();
    }
    return const SizedBox.shrink();
  }

  Widget buildCityCard(FetchCityCategorySuccess state, int index) {
    return GestureDetector(
      onTap: () {
        context.read<FetchCityPropertyList>().fetch(
              cityName: state.cities[index].name,
              forceRefresh: true,
            );

        final stateMap = StateMap<
            FetchCityPropertyInitial,
            FetchCityPropertyInProgress,
            FetchCityPropertySuccess,
            FetchCityPropertyFail>();

        ViewAllScreen<FetchCityPropertyList, FetchCityPropertyListState>(
          title: state.cities[index].name.firstUpperCase(),
          map: stateMap,
        ).open(context);
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              UiUtils.getImage(
                state.cities[index].image,
                fit: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.76),
                      Colors.black.withOpacity(0.68),
                      Colors.black.withOpacity(0),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                bottom: 8,
                start: 8,
                child: Text(
                  '${state.cities[index].name.firstUpperCase()} (${state.cities[index].count})',
                ).color(context.color.buttonColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPromotedProperites(List<PropertyModel> promotedProperties) {
    return SizedBox(
      height: 261,
      child: ListView.builder(
        itemCount: promotedProperties.length.clamp(0, 6),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: sidePadding,
        ),
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final thisItemKey = GlobalKey();
          return GestureDetector(
            onTap: () async {
              try {
               // unawaited(Widgets.showLoader(context));
                final fetch = PropertyRepository();
                final dataOutput = await fetch.fetchPropertyFromPropertyId(
                  promotedProperties[index].id,
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
                log('Error is $e');
                Widgets.hideLoder(context);
              }
            },
            child: BlocProvider(
              create: (context) {
                return AddToFavoriteCubitCubit();
              },
              child: PropertyCardBig(
                key: thisItemKey,
                isFirst: index == 0,
                property: promotedProperties[index],
                onLikeChange: (type) {
                  if (type == FavoriteType.add) {
                    context
                        .read<FetchFavoritesCubit>()
                        .add(promotedProperties[index]);
                  } else {
                    context
                        .read<FetchFavoritesCubit>()
                        .remove(promotedProperties[index].id);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildMostLikedProperties(List<PropertyModel> mostLiked) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: sidePadding,
      ),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
        mainAxisSpacing: 15,
        crossAxisCount: 2,
        height: 260,
      ),
      itemCount: mostLiked.length.clamp(0, 4),
      itemBuilder: (context, index) {
        final properties = mostLiked[index];
        return GestureDetector(
          onTap: () async {
            try {
             // unawaited(Widgets.showLoader(context));
              final fetch = PropertyRepository();
              final dataOutput = await fetch.fetchPropertyFromPropertyId(
                properties.id,
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
              log('Error is $e');
              Widgets.hideLoder(context);
            }
          },
          child: BlocProvider(
            create: (context) => AddToFavoriteCubitCubit(),
            child: PropertyCardBig(
              showEndPadding: false,
              isFirst: index == 0,
              onLikeChange: (type) {
                if (type == FavoriteType.add) {
                  context.read<FetchFavoritesCubit>().add(properties);
                } else {
                  context.read<FetchFavoritesCubit>().remove(properties.id);
                }
              },
              property: properties,
            ),
          ),
        );
      },
    );
  }

  Widget buildNearByProperties() {
    return BlocConsumer<FetchNearbyPropertiesCubit, FetchNearbyPropertiesState>(
      listener: (context, state) {
        if (state is FetchNearbyPropertiesFailure) {
          homeStateListener.setNetworkState(
            setState,
            state.error is! NoInternetConnectionError,
          );
          setState(() {});
        }
        if (state is FetchNearbyPropertiesSuccess) {
          setState(() {});
        }
      },
      builder: (context, state) {
        if (state is FetchNearbyPropertiesInProgress) {
          return Column(
            children: [
              TitleHeader(
                onSeeAll: _onTapNearByPropertiesAll,
                title: "${UiUtils.translate(
                  context,
                  "nearByProperties",
                )}(${HiveUtils.getCityName()})",
              ),
              const NearbyPropertiesShimmer(),
            ],
          );
        }

        if (state is FetchNearbyPropertiesFailure) {
          return Text(state.error.toString());
        }
        if (state is FetchNearbyPropertiesSuccess) {
          if (state.properties.isEmpty) {
            return Container();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleHeader(
                onSeeAll: _onTapNearByPropertiesAll,
                title: "${UiUtils.translate(
                  context,
                  "nearByProperties",
                )}(${HiveUtils.getCityName()})",
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: sidePadding,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.properties.length.clamp(0, 6),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    var model = state.properties[index];
                    model = context.watch<PropertyEditCubit>().get(model);
                    return PropertyGradiendCard(
                      model: model,
                      isFirst: index == 0,
                      showEndPadding: false,
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Container();
      },
    );
  }

  Widget buildMostViewedProperties(List<PropertyModel> mostViewed) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: sidePadding,
      ),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
        mainAxisSpacing: 15,
        crossAxisCount: 2,
        height: 260,
      ),
      itemCount: mostViewed.length.clamp(0, 4),
      itemBuilder: (context, index) {
        final property = mostViewed[index];
        return GestureDetector(
          onTap: () async {
            try {
             // unawaited(Widgets.showLoader(context));
              final fetch = PropertyRepository();
              final dataOutput = await fetch.fetchPropertyFromPropertyId(
                property.id,
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
              log('Error is $e');
              Widgets.hideLoder(context);
            }
          },
          child: BlocProvider(
            create: (context) => AddToFavoriteCubitCubit(),
            child: PropertyCardBig(
              showEndPadding: false,
              isFirst: index == 0,
              onLikeChange: (type) {
                if (type == FavoriteType.add) {
                  context.read<FetchFavoritesCubit>().add(property);
                } else {
                  context.read<FetchFavoritesCubit>().remove(property.id);
                }
              },
              property: property,
            ),
          ),
        );
      },
    );
  }

  Widget categoryWidget(List<Category> categories) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 44.rh(context),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length.clamp(0, Constant.maxCategoryLength),
            itemBuilder: (context, index) {
              final category = categories[index];
              Constant.propertyFilter = null;
              if (index == (Constant.maxCategoryLength - 1)) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.categories);
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: 100.rw(context),
                      ),
                      height: 44.rh(context),
                      alignment: Alignment.center,
                      decoration: DesignConfig.boxDecorationBorder(
                        color: context.color.secondaryColor,
                        radius: 10,
                        borderWidth: 1.5,
                        borderColor: context.color.borderColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(UiUtils.translate(context, 'more')),
                      ),
                    ),
                  ),
                );
              }

              return buildCategoryCard(context, category, index != 0);
            },
          ),
        ),
      ],
    );
  }

  Widget buildCategoryCard(
    BuildContext context,
    Category category,
    frontSpacing,
  ) {
    return CategoryCard(
      frontSpacing: frontSpacing,
      onTapCategory: (category) {
        currentVisitingCategoryId = category.id;
        currentVisitingCategory = category;
        Navigator.of(context).pushNamed(
          Routes.propertiesList,
          arguments: {'catID': category.id, 'catName': category.category},
        );
      },
      category: category,
    );
  }
}

class RecentPropertiesSectionWidget extends StatefulWidget {
  const RecentPropertiesSectionWidget({super.key});

  @override
  State<RecentPropertiesSectionWidget> createState() =>
      _RecentPropertiesSectionWidgetState();
}

class _RecentPropertiesSectionWidgetState
    extends State<RecentPropertiesSectionWidget> {
  void _onRecentlyAddedSeeAll() {
    final dynamic statemap = StateMap<
        FetchRecentProepertiesInitial,
        FetchRecentPropertiesInProgress,
        FetchRecentPropertiesSuccess,
        FetchRecentPropertiesFailur>();
    ViewAllScreen<FetchRecentPropertiesCubit, FetchRecentPropertiesState>(
      title: 'recentlyAdded'.translate(context),
      map: statemap,
    ).open(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isRecentEmpty() {
      if (context.watch<FetchRecentPropertiesCubit>().state
          is FetchRecentPropertiesSuccess) {
        return (context.watch<FetchRecentPropertiesCubit>().state
                as FetchRecentPropertiesSuccess)
            .properties
            .isEmpty;
      }
      return true;
    }

    return Column(
      children: [
        if (!isRecentEmpty())
          TitleHeader(
            enableShowAll: false,
            title: 'recentlyAdded'.translate(context),
            onSeeAll: _onRecentlyAddedSeeAll,
          ),
        LayoutBuilder(
          builder: (context, c) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: sidePadding),
              child: BlocBuilder<FetchRecentPropertiesCubit,
                  FetchRecentPropertiesState>(
                builder: (context, state) {
                  if (state is FetchRecentPropertiesInProgress) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const ClipRRect(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                child: CustomShimmer(height: 90, width: 90),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    CustomShimmer(
                                      height: 10,
                                      width: c.maxWidth - 100,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const CustomShimmer(
                                      height: 10,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    CustomShimmer(
                                      height: 10,
                                      width: c.maxWidth / 1.2,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    CustomShimmer(
                                      height: 10,
                                      width: c.maxWidth / 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      shrinkWrap: true,
                      itemCount: 5,
                    );
                  }

                  if (state is FetchRecentPropertiesSuccess) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var modal = state.properties[index];
                        modal = context.watch<PropertyEditCubit>().get(modal);
                        return GestureDetector(
                          onTap: () {
                            HelperUtils.goToNextPage(
                              Routes.propertyDetails,
                              context,
                              false,
                              args: {
                                'propertyData': modal,
                                'propertiesList': state.properties,
                                'fromMyProperty': false,
                              },
                            );
                          },
                          child: PropertyHorizontalCard(
                            property: modal,
                            additionalImageWidth: 10,
                          ),
                        );
                      },
                      itemCount: state.properties.length.clamp(0, 4),
                      shrinkWrap: true,
                    );
                  }
                  if (state is FetchRecentPropertiesFailur) {
                    return Container();
                  }

                  return Container();
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class PersonalizedPropertyWidget extends StatelessWidget {
  const PersonalizedPropertyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchPersonalizedPropertyList,
        FetchPersonalizedPropertyListState>(
      builder: (context, state) {
        if (state is FetchPersonalizedPropertyInProgress) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleHeader(
                onSeeAll: () {},
                title: 'personalizedFeed'.translate(context),
              ),
              const PromotedPropertiesShimmer(),
            ],
          );
        }

        if (state is FetchPersonalizedPropertySuccess) {
          if (state.properties.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleHeader(
                onSeeAll: () {
                  final StateMap stateMap = StateMap<
                      FetchPersonalizedPropertyInitial,
                      FetchPersonalizedPropertyInProgress,
                      FetchPersonalizedPropertySuccess,
                      FetchPersonalizedPropertyFail>();

                  ViewAllScreen<FetchPersonalizedPropertyList,
                      FetchPersonalizedPropertyListState>(
                    title: 'personalizedFeed'.translate(context),
                    map: stateMap,
                  ).open(context);
                },
                title: 'personalizedFeed'.translate(context),
              ),
              SizedBox(
                height: 261,
                child: ListView.builder(
                  itemCount: state.properties.length.clamp(0, 6),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: sidePadding,
                  ),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final thisITemkye = GlobalKey();

                    var propertymodel = state.properties[index];
                    propertymodel =
                        context.watch<PropertyEditCubit>().get(propertymodel);
                    return GestureDetector(
                      onTap: () {
                        HelperUtils.goToNextPage(
                          Routes.propertyDetails,
                          context,
                          false,
                          args: {
                            'propertyData': propertymodel,
                            'propertiesList': state.properties,
                            'fromMyProperty': false,
                          },
                        );
                      },
                      child: BlocProvider(
                        create: (context) {
                          return AddToFavoriteCubitCubit();
                        },
                        child: PropertyCardBig(
                          key: thisITemkye,
                          isFirst: index == 0,
                          property: propertymodel,
                          onLikeChange: (type) {
                            if (type == FavoriteType.add) {
                              context
                                  .read<FetchFavoritesCubit>()
                                  .add(propertymodel);
                            } else {
                              context
                                  .read<FetchFavoritesCubit>()
                                  .remove(state.properties[index].id);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Container();
      },
    );
  }
}

Future<void> notificationPermissionChecker() async {
  if (!(await Permission.notification.isGranted)) {
    await Permission.notification.request();
  }
}

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<int> _bannerIndex = ValueNotifier(0);
  int bannersLength = 0;
  late Timer _timer;
  final PageController _pageController = PageController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<FetchHomePageDataCubit>().fetch(
          forceRefresh: false,
        );
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_bannerIndex.value < bannersLength - 1) {
        _bannerIndex.value++;
      } else {
        _bannerIndex.value = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _bannerIndex.value,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bannerIndex.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<FetchHomePageDataCubit, FetchHomePageDataState>(
      builder: (context, state) {
        if (state is FetchHomePageDataLoading) {
          return Column(
            children: [
              SizedBox(
                height: 15.rh(context),
              ),
              Container(
                margin: const EdgeInsets.only(
                  right: 18,
                  top: 10,
                  left: 18,
                  bottom: 10,
                ),
                height: 130.rh(context),
                child: ListView.builder(
                  controller: _pageController,
                  clipBehavior: Clip.antiAlias,
                  physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                  itemCount: 2,
                  itemBuilder: (context, index) => CustomShimmer(
                    height: 130.rh(context),
                    width: context.screenWidth * 0.3,
                  ),
                ),
              ),
              SizedBox(
                height: 15.rh(context),
              ),
            ],
          );
        }
        if (state is FetchHomePageDataSuccess &&
            state.homePageDataModel.sliderSection.isNotEmpty) {
          bannersLength = state.homePageDataModel.sliderSection.length;
          return Column(
            children: <Widget>[
              SizedBox(
                height: 15.rh(context),
              ),
              SizedBox(
                height: 130.rh(context),
                child: PageView.builder(
                  controller: _pageController,
                  clipBehavior: Clip.antiAlias,
                  physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                  itemCount: state.homePageDataModel.sliderSection.length,
                  onPageChanged: (index) {
                    _bannerIndex.value = index;
                  },
                  itemBuilder: (context, index) => _buildBanner(
                    state.homePageDataModel.sliderSection[index],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBanner(HomeSlider banner) {
    return GestureDetector(
      onTap: () async {
        if (banner.sliderType == '1') {
          UiUtils.showFullScreenImage(
            context,
            provider: NetworkImage(banner.image.toString()),
          );
        } else if (banner.sliderType == '2') {
          await Navigator.pushNamed(
            context,
            Routes.propertiesList,
            arguments: {
              'catID': banner.categoryId,
              'catName': banner.category!.category,
            },
          );
        } else if (banner.sliderType == '3') {
          try {
           // unawaited(Widgets.showLoader(context));
            final fetch = PropertyRepository();
            final dataOutput = await fetch.fetchPropertyFromPropertyId(
              banner.propertysId,
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
            log('Error is $e');
            Widgets.hideLoder(context);
          }
        } else if (banner.sliderType == '4') {
          await url_launcher.launchUrl(Uri.parse(banner.link!));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: sidePadding),
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              width: context.screenWidth,
              height: context.screenHeight * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: Colors.transparent,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: UiUtils.getImage(
                  banner.image.toString(),
                  width: context.screenWidth,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
