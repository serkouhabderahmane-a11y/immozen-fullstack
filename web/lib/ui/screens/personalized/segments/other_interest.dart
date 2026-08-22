part of '../personalized_property_screen.dart';

class OtherInterests extends StatefulWidget {
  const OtherInterests({
    required this.onInteraction,
    required this.type,
    super.key,
  });

  final PersonalizedVisitType type;
  final Function(
    RangeValues priceRange,
    String location,
    List<int> propertyType,
  ) onInteraction;

  @override
  State<OtherInterests> createState() => _OtherInterestsState();
}

class _OtherInterestsState extends State<OtherInterests> {
  String selectedLocation = '';
  final TextEditingController _cityController = TextEditingController();
  late final min = personalizedInterestSettings.priceRange.first;
  late final max = personalizedInterestSettings.priceRange.last;
  RangeValues _priceRangeValues = const RangeValues(0, 100);
  RangeValues _selectedRangeValues = const RangeValues(0, 50);

  GooglePlaceRepository googlePlaceRepository = GooglePlaceRepository();
  List<int> selectedPropertyType = [0, 1];

  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        selectedPropertyType = personalizedInterestSettings.propertyType;

        if (personalizedInterestSettings.city.isNotEmpty) {
          _cityController.text =
              personalizedInterestSettings.city.firstUpperCase();
          selectedLocation = personalizedInterestSettings.city;
        }

        widget.onInteraction
            .call(_selectedRangeValues, selectedLocation, selectedPropertyType);
        setState(() {});
        final state = context.read<FetchSystemSettingsCubit>().state;
        if (state is FetchSystemSettingsSuccess) {
          final settingsData = state.settings['data'];
          final minPrice = double.parse(settingsData['min_price']);
          final maxPrice = double.parse(settingsData['max_price']);
          _priceRangeValues = RangeValues(minPrice, maxPrice);
          if (min != 0.0 && max != 0.0) {
            _selectedRangeValues = RangeValues(min, max);
          } else {
            _selectedRangeValues = RangeValues(minPrice, maxPrice / 4);
          }
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isFirstTime = widget.type == PersonalizedVisitType.FirstTime;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                const Spacer(
                  flex: 2,
                ),
                Text(
                  'selectCityYouWantToSee'.translate(context),
                )
                    .color(context.color.textColorDark)
                    .size(context.font.extraLarge)
                    .centerAlign(),
                Spacer(
                  flex: isFirstTime ? 1 : 2,
                ),
                if (isFirstTime)
                  GestureDetector(
                    onTap: () {
                      HelperUtils.killPreviousPages(
                        context,
                        Routes.main,
                        {'from': 'login'},
                      );
                    },
                    child: Chip(
                      label: Text('skip'.translate(context))
                          .color(context.color.buttonColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            buildCitySearchTextField(context),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text('selectedLocation'.translate(context))
                      .color(context.color.textColorDark.withOpacity(0.6)),
                  Expanded(child: Text(selectedLocation)),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text('choosePropertyType'.translate(context))
                .color(context.color.textColorDark)
                .size(context.font.extraLarge)
                .centerAlign(),
            const SizedBox(
              height: 10,
            ),
            PropertyTypeSelector(
              onInteraction: (List<int> values) {
                selectedPropertyType = values;
                widget.onInteraction
                    .call(_selectedRangeValues, selectedLocation, values);

                setState(() {});
              },
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              'chooseTheBudeget'.translate(context),
            )
                .color(context.color.textColorDark)
                .size(context.font.extraLarge)
                .centerAlign(),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('minLbl'.translate(context)),
                      Text(
                        _selectedRangeValues.start
                            .toInt()
                            .toString()
                            .priceFormate(context: context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: RangeSlider(
                    // labels: RangeLabels(_priceRangeValues.start.toString(), _priceRangeValues.end.toString()),
                    activeColor: context.color.tertiaryColor,
                    values: _selectedRangeValues,
                    onChanged: (RangeValues value) {
                      _selectedRangeValues = value;
                      widget.onInteraction.call(
                        _selectedRangeValues,
                        selectedLocation,
                        selectedPropertyType,
                      );
                      setState(() {});
                    },
                    min: _priceRangeValues.start,
                    max: _priceRangeValues.end,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('maxLbl'.translate(context)),
                      Text(
                        _selectedRangeValues.end
                            .toInt()
                            .toString()
                            .priceFormate(context: context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCitySearchTextField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: TypeAheadField(
        errorBuilder: (context, error) {
          return const Text('Error');
        },
        loadingBuilder: (context) {
          return Center(child: UiUtils.progress());
        },
        itemBuilder: (context, GooglePlaceModel itemData) {
          final address = <String>[
            itemData.city,
            // itemData.state,
            // itemData.country
          ];

          return ListTile(
            tileColor: context.color.secondaryColor,
            title: Text(address.join(',')),
          );
        },
        suggestionsCallback: (String pattern) async {
          if (pattern.length < 2) {
            return Future.value(<GooglePlaceModel>[]);
          }
          return googlePlaceRepository.serchCities(
            pattern,
          );
        },
        onSelected: (GooglePlaceModel suggestion) {
          final addressList = <String>[
            suggestion.city,
            // suggestion.state,
            // suggestion.country
          ];
          final address = addressList.join(',');
          _cityController.text = address;
          selectedLocation = address;
          widget.onInteraction.call(
            _selectedRangeValues,
            selectedLocation,
            selectedPropertyType,
          );

          setState(() {});
        },
      ),
    );
  }
}

class PropertyTypeSelector extends StatefulWidget {
  const PropertyTypeSelector({
    required this.onInteraction,
    super.key,
  });

  final Function(List<int> values) onInteraction;

  @override
  State<PropertyTypeSelector> createState() => _PropertyTypeSelectorState();
}

class _PropertyTypeSelectorState extends State<PropertyTypeSelector> {
  List<int> selectedPropertyType = [0, 1];

  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        if (personalizedInterestSettings.propertyType.isNotEmpty) {
          selectedPropertyType = personalizedInterestSettings.propertyType;
        }

        widget.onInteraction.call(selectedPropertyType);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            selectedPropertyType.clearAndAddAll([0, 1]);
            widget.onInteraction.call(selectedPropertyType);

            setState(() {});
          },
          child: Chip(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            label:
                Text('all'.translate(context)).size(context.font.large).color(
                      selectedPropertyType.containesAll([0, 1])
                          ? context.color.buttonColor
                          : context.color.textColorDark,
                    ),
            backgroundColor: selectedPropertyType.containesAll([0, 1])
                ? context.color.tertiaryColor
                : context.color.secondaryColor,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            selectedPropertyType.clearAndAdd(0);
            widget.onInteraction.call(selectedPropertyType);

            setState(() {});
          },
          child: Chip(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            label:
                Text('sell'.translate(context)).size(context.font.large).color(
                      selectedPropertyType.isSingleElementAndIs(0)
                          ? context.color.buttonColor
                          : context.color.textColorDark,
                    ),
            backgroundColor: selectedPropertyType.isSingleElementAndIs(0)
                ? context.color.tertiaryColor
                : context.color.secondaryColor,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            selectedPropertyType.clearAndAdd(1);
            widget.onInteraction.call(selectedPropertyType);
            setState(() {});
          },
          child: Chip(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            label:
                Text('rent'.translate(context)).size(context.font.large).color(
                      selectedPropertyType.isSingleElementAndIs(1)
                          ? context.color.buttonColor
                          : context.color.textColorDark,
                    ),
            backgroundColor: selectedPropertyType.isSingleElementAndIs(1)
                ? context.color.tertiaryColor
                : context.color.secondaryColor,
          ),
        ),
      ],
    );
  }
}
