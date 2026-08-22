import 'package:immozen/utils/Extensions/extensions.dart';
import 'package:immozen/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({required this.interestUserCount, super.key});
  final String interestUserCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.05),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: context.color.tertiaryColor),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: context.screenWidth,
              height: 100,
              decoration: BoxDecoration(
                color: context.color.primaryColor,
                borderRadius: BorderRadius.circular(
                  10,
                ),
                border: Border.all(
                  color: context.color.borderColor,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(UiUtils.translate(context, 'interestedUserCount'))
                        .color(context.color.textColorDark)
                        .size(context.font.larger)
                        .bold(),
                    Center(
                      child: Text(interestUserCount)
                          .color(context.color.textColorDark)
                          .size(context.font.extraLarge)
                          .italic(),
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
