import 'package:immozen/data/cubits/delete_advertisment_cubit.dart';
import 'package:immozen/data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import 'package:immozen/data/repositories/advertisement_repository.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:immozen/utils/admob/bannerAdLoadWidget.dart';
import 'package:flutter/material.dart';

class MyAdvertismentScreen extends StatefulWidget {
  const MyAdvertismentScreen({super.key});
  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return BlocProvider(
          create: (context) => FetchMyPromotedPropertysCubit(),
          child: const MyAdvertismentScreen(),
        );
      },
    );
  }

  @override
  State<MyAdvertismentScreen> createState() => _MyAdvertismentScreenState();
}

class _MyAdvertismentScreenState extends State<MyAdvertismentScreen> {
  final ScrollController _pageScrollController = ScrollController();
  Map<int, String>? statusMap;
  @override
  void initState() {
    context.read<FetchMyPromotedPropertysCubit>().fetchMyPromotedPropertys();

    Future.delayed(
      Duration.zero,
      () {
        statusMap = {
          0: UiUtils.translate(context, 'approved'),
          1: UiUtils.translate(context, 'pending'),
          2: UiUtils.translate(context, 'rejected'),
        };
      },
    );

    _pageScrollController.addListener(_pageScroll);
    super.initState();
  }

  void _pageScroll() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchMyPromotedPropertysCubit>().hasMoreData()) {
        context
            .read<FetchMyPromotedPropertysCubit>()
            .fetchMyPromotedPropertysMore();
      }
    }
  }

  @override
  void didChangeDependencies() {
    statusMap = {
      0: UiUtils.translate(context, 'approved'),
      1: UiUtils.translate(context, 'pending'),
      2: UiUtils.translate(context, 'rejected'),
    };
    super.didChangeDependencies();
  }

  Color statusColor(status) {
    if (status == 0) {
      return Colors.green;
    } else if (status == 1) {
      return Colors.orangeAccent;
    } else if (status == 2) {
      return Colors.red;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.translate(context, 'myAds'),
      ),
      /* bottomNavigationBar: const BottomAppBar(
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),*/
      body: BlocBuilder<FetchMyPromotedPropertysCubit,
          FetchMyPromotedPropertysState>(
        builder: (context, state) {
          if (state is FetchMyPromotedPropertysInProgress) {
            return Center(child: UiUtils.progress());
          }
          if (state is FetchMyPromotedPropertysFailure) {
            if (state.errorMessage is NoInternetConnectionError) {
              return NoInternet(
                onRetry: () {
                  context
                      .read<FetchMyPromotedPropertysCubit>()
                      .fetchMyPromotedPropertys();
                },
              );
            }

            return const SomethingWentWrong();
          }
          if (state is FetchMyPromotedPropertysSuccess) {
            if (state.advertisement.isEmpty) {
              return NoDataFound(
                title: 'noFeaturedAdsYes'.translate(context),
                description: 'noFeaturedDescription'.translate(context),
                onTap: () {
                  context
                      .read<FetchMyPromotedPropertysCubit>()
                      .fetchMyPromotedPropertys();
                  setState(() {});
                },
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _pageScrollController,
                    itemCount: state.advertisement.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      var advertisement = state.advertisement[index];
                      advertisement = context
                          .watch<PropertyEditCubit>()
                          .getAd(advertisement);
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.propertyDetails,
                            arguments: {
                              'propertyData': advertisement,
                              'fromMyProperty': true,
                            },
                          );
                        },
                        child: BlocProvider(
                          create: (context) => DeleteAdvertismentCubit(
                            AdvertisementRepository(),
                          ),
                          child: MyAdvertisementPropertyHorizontalCard(
                            advertisement: advertisement,
                            useRow: true,
                            showLikeButton: false,
                            additionalHeight: 45,
                            statusButton: StatusButton(
                              lable:
                                  statusMap![advertisement.advertisementStatus]
                                      .toString()
                                      .firstUpperCase(),
                              color: statusColor(
                                advertisement.advertisementStatus,
                              ),
                              textColor: context.color.buttonColor,
                            ),
                            addBottom: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 5.rw(context),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: context.color.inverseSurface
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    width: 100,
                                    height: 22,
                                    child: Center(
                                      child: Text(
                                        advertisement.advertisementType!,
                                      ).size(context.font.small),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              BlocConsumer<DeleteAdvertismentCubit,
                                  DeleteAdvertismentState>(
                                listener: (context, state) {
                                  if (state is DeleteAdvertismentSuccess) {
                                    context
                                        .read<FetchMyPromotedPropertysCubit>()
                                        .delete(advertisement.advertisementId);
                                  }
                                },
                                builder: (
                                  BuildContext context,
                                  DeleteAdvertismentState state,
                                ) {
                                  ///it will only show delete button when status is pending it means 1.

                                  if (advertisement.advertisementStatus != 1) {
                                    // return SizedBox.shrink();
                                    return SizedBox(
                                      height: 40,
                                      width: 32,
                                      child: SizedBox(width: 10.rw(context)),
                                    );
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      UiUtils.showBlurredDialoge(
                                        context,
                                        dialoge: BlurredDialogBox(
                                          title: UiUtils.translate(
                                            context,
                                            'deleteBtnLbl',
                                          ),
                                          onAccept: () async {
                                            if (Constant.isDemoModeOn) {
                                              HelperUtils.showSnackBarMessage(
                                                context,
                                                UiUtils.translate(
                                                  context,
                                                  'thisActionNotValidDemo',
                                                ),
                                              );
                                            } else {
                                              await context
                                                  .read<
                                                      DeleteAdvertismentCubit>()
                                                  .delete(
                                                    advertisement
                                                        .advertisementId,
                                                  );
                                            }
                                          },
                                          content: Text(
                                            UiUtils.translate(
                                              context,
                                              'confirmDeleteAdvert',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: context.color.secondaryColor,
                                        shape: BoxShape.circle,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color.fromARGB(33, 0, 0, 0),
                                            offset: Offset(0, 2),
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                                      child: (state
                                              is DeleteAdvertismentInProgress)
                                          ? UiUtils.progress()
                                          : SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: FittedBox(
                                                fit: BoxFit.none,
                                                child: SvgPicture.asset(
                                                  AppIcons.bin,
                                                  colorFilter: ColorFilter.mode(
                                                    context.color.tertiaryColor,
                                                    BlendMode.srcIn,
                                                  ),
                                                  width: 18,
                                                  height: 18,
                                                ),
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 10.rw(context),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (state.isLoadingMore) UiUtils.progress(),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
