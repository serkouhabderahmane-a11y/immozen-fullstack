import 'package:immozen/exports/main_export.dart';
import 'package:flutter/material.dart';

class CityHeadingCard extends StatelessWidget {
  const CityHeadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 211,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/city.jpg', fit: BoxFit.cover),
          Directionality(
            textDirection: Directionality.of(context),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Directionality.of(context) == TextDirection.ltr
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  radius: 3,
                  focalRadius: 1,
                  colors: [
                    Colors.black.withOpacity(0.97),
                    Colors.black.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 50,
            start: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 34,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text('popularCities'.translate(context))
                        .color(Colors.white)
                        .size(32),
                  ],
                ),
                Text('${context.watch<FetchCityCategoryCubit>().getCount() ?? 0}+ ${'properties'.translate(context)}')
                    .color(Colors.white),
              ],
            ),
          ),
          PositionedDirectional(
            bottom: 10,
            end: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, Routes.cityListScreen);
              },
              child: Container(
                alignment: AlignmentDirectional.center,
                width: MediaQuery.of(context).size.width * 0.3,
                height: 30,
                decoration: BoxDecoration(
                  color: context.color.secondaryColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      UiUtils.translate(context, 'seeAll'),
                    )
                        .size(context.font.normal)
                        .color(context.color.textColorDark)
                        .bold(weight: FontWeight.w700),
                    const SizedBox(
                      width: 10,
                    ),
                    UiUtils.getSvg(
                      AppIcons.arrowRight,
                      fit: BoxFit.fitHeight,
                      matchTextDirection: true,
                      height: 15,
                      color: context.color.textColorDark,
                      width: context.font.small,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
