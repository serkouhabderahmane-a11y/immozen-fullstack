import 'package:immozen/data/cubits/property/create_advertisement_cubit.dart';
import 'package:immozen/data/repositories/subscription_repository.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:immozen/ui/screens/home/Widgets/property_card_big.dart';
import 'package:immozen/utils/imagePicker.dart';
import 'package:flutter/material.dart';

enum AvertisementType {
  home('HomeScreen'),
  list('ProductListing');

  const AvertisementType(this.value);
  final String value;
}

class CreateAdvertisementPopup extends StatefulWidget {
  const CreateAdvertisementPopup({
    required this.property,
    super.key,
  });
  final PropertyModel property;
  static Route route(RouteSettings routeSettings) {
    try {
      final arguments = routeSettings.arguments as Map?;
      return BlurredRouter(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => CreateAdvertisementCubit()),
            BlocProvider(
              create: (context) => GetSubsctiptionPackageLimitsCubit(),
            ),
          ],
          child: CreateAdvertisementPopup(
            property: arguments?['propertyData'],
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  State<CreateAdvertisementPopup> createState() =>
      _CreateAdvertisementPopupState();
}

class _CreateAdvertisementPopupState extends State<CreateAdvertisementPopup> {
  Map? selectedAdvertismentOption;
  final PickImage _pickImage = PickImage();
  AvertisementType advertisementType = AvertisementType.home;
  bool hasPackage = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<GetSubsctiptionPackageLimitsCubit>().getLimits(
            SubscriptionLimitType.advertisement,
          );
    });
  }

  @override
  void dispose() {
    _pickImage.dispose();
    super.dispose();
  }

  Widget getPreview() {
    if (selectedAdvertismentOption?['id'] == 0 ||
        selectedAdvertismentOption == null) {
      return PropertyCardBig(
        showLikeButton: false,
        property: widget.property,
      );
    } else if (selectedAdvertismentOption?['id'] == 1) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: PropertyHorizontalCard(
          showLikeButton: false,
          property: widget.property,
        ),
      );
    } else {
      return Text(UiUtils.translate(context, 'previewNotAvail'));
    }
  }

  Future<void> _createAdvertisment() async {
    if (selectedAdvertismentOption?['id'] == 0) {
      advertisementType = AvertisementType.home;
    } else if (selectedAdvertismentOption?['id'] == 1) {
      advertisementType = AvertisementType.list;
    }

    await context.read<CreateAdvertisementCubit>().create(
          type: advertisementType.value,
          propertyId: widget.property.id.toString(),
          image: _pickImage.pickedFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        backgroundColor: context.color.backgroundColor,
        child: SingleChildScrollView(
          child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: context.color.shimmerBaseColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: IconButton(
                  splashColor: Colors.transparent,
                  splashRadius: 0.1,
                  padding: const EdgeInsets.all(1),
                  alignment: Alignment.center,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  iconSize: 15,
                  color: context.color.inverseSurface.withOpacity(0.5),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    UiUtils.translate(context, 'createAdvertisment'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocConsumer<CreateAdvertisementCubit,
                      CreateAdvertisementState>(
                    listener: (context, state) {
                      if (state is CreateAdvertisementInProgress) {
                        Widgets.showLoader(context);
                      }
                      if (state is CreateAdvertisementFailure) {
                        Widgets.hideLoder(context);
                        HelperUtils.showSnackBarMessage(
                          context,
                          UiUtils.translate(context, 'somethingWentWrng'),
                          type: MessageType.error,
                        );
                      }
                      if (state is CreateAdvertisementSuccess) {
                        Widgets.hideLoder(context);
                        context
                            .read<FetchMyPropertiesCubit>()
                            .update(state.property);
                        HelperUtils.showSnackBarMessage(
                          context,
                          UiUtils.translate(context, 'success'),
                          type: MessageType.success,
                        );
                        Navigator.pop(context);
                      }
                    },
                    builder: (context, state) {
                      return SizedBox(
                        height: 272,
                        child: Center(child: getPreview()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: OptionsRow(
                      initialValue: (initial) {
                        selectedAdvertismentOption = initial;
                      },
                      selected: (selected) {
                        setState(() {
                          selectedAdvertismentOption = selected;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocConsumer<GetSubsctiptionPackageLimitsCubit,
                      GetSubscriptionPackageLimitsState>(
                    listener: (context, state) {
                      if (state is GetSubscriptionPackageLimitsInProgress) {
                        Widgets.showLoader(context);
                      }
                      if (state is GetSubsctiptionPackageLimitsFailure) {
                        Widgets.hideLoder(context);
                        HelperUtils.showSnackBarMessage(
                          context,
                          UiUtils.translate(context, 'somethingWentWrng'),
                          type: MessageType.error,
                        );
                        Navigator.pop(context);
                      }
                      if (state is GetSubscriptionPackageLimitsSuccess) {
                        Widgets.hideLoder(context);
                      }
                    },
                    builder: (context, state) {
                      if (state is GetSubscriptionPackageLimitsSuccess) {
                        hasPackage = state.packageLimit.hasPackage == true;
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: UiUtils.buildButton(
                          context,
                          onPressed: () {
                            if (hasPackage) {
                              _createAdvertisment();
                            } else {
                              Navigator.pushNamed(
                                context,
                                Routes.subscriptionPackageListRoute,
                              );
                            }
                          },
                          prefixWidget: hasPackage
                              ? null
                              : Icon(
                                  Icons.lock,
                                  color: context.color.buttonColor,
                                ),
                          buttonTitle: hasPackage
                              ? UiUtils.translate(context, 'promote')
                              : UiUtils.translate(
                                  context,
                                  'subscribeToPackage',
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OptionsRow extends StatefulWidget {
  const OptionsRow({required this.selected, super.key, this.initialValue});
  final Function(Map<String, dynamic> initial)? initialValue;
  final Function(Map<String, dynamic> selected) selected;
  @override
  State<OptionsRow> createState() => _OptionsRowState();
}

class _OptionsRowState extends State<OptionsRow> {
  int selectedOption = 0;

  ///add options here
  List<String> options = ['Home', 'List'];

  Widget buildOption(String name, int index) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8, left: 8),
          child: UiUtils.buildButton(
            context,
            height: 34,
            buttonTitle: name,
            textColor: index == selectedOption
                ? context.color.textAutoAdapt(context.color.textColorDark)
                : Theme.of(context).colorScheme.tertiaryColor,
            radius: 7,
            fontSize: context.font.normal,
            onPressed: () {
              selectedOption = index;
              widget.selected({'id': index, 'value': name});
              setState(() {});
            },
            buttonColor: index == selectedOption
                ? Theme.of(context).colorScheme.tertiaryColor.withAlpha(255)
                : Theme.of(context).colorScheme.tertiaryColor.withAlpha(55),
          ),
        ),
      );

  @override
  void initState() {
    widget.initialValue?.call({'id': 0, 'value': options[0]});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ///We need index to select some value , So when we are storing it in list
    /// so we don't have index in list we can use for loop but it will not be perfect as this,
    ///  here we are converting list  to map so it will  get index automaticly and then using .map(k,v)
    ///  method so we can get index in key and do work on this
    /// .values will only use its String values and here .cast will convert List dynamic to List of widgets
    final optionList = options
        .asMap()
        .map((key, value) => MapEntry(key, buildOption(value, key)))
        .values
        .toList()
        .cast<Widget>();

    return Row(
      children: optionList,
    );
  }
}
