import 'package:immozen/data/model/agent/agent_model.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:flutter/material.dart';

class AgentCard extends StatelessWidget {
  const AgentCard({
    required this.agent,
    required this.propertyCount,
    required this.name,
    super.key,
    this.isFirst,
    this.showEndPadding,
  });

  final AgentModel agent;
  final bool? isFirst;
  final bool? showEndPadding;
  final String name;
  final int propertyCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HelperUtils.share(context, agent.id, agent.name);
      },
      onTap: () {
        GuestChecker.check(
          onNotGuest: () {
            if (context
                    .read<FetchSystemSettingsCubit>()
                    .getRawSettings()['is_premium'] ??
                false) {
              Navigator.pushNamed(
                context,
                Routes.agentDetailsScreen,
                arguments: {
                  'agent': agent,
                },
              );
            } else {
              if (agent.id.toString() == HiveUtils.getUserId()) {
                Navigator.pushNamed(
                  context,
                  Routes.agentDetailsScreen,
                  arguments: {
                    'agent': agent,
                  },
                );
              } else {
                UiUtils.showBlurredDialoge(
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: context.color.secondaryColor,
          border: Border.all(
            width: 1.5,
            color: context.color.borderColor,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        width: 155,
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
                clipBehavior: Clip.antiAlias,
                child: UiUtils.getImage(
                  agent.profile,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      overflow: TextOverflow.ellipsis,
                      agent.name,
                    ).bold().size(context.font.large).firstUpperCaseWidget(),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('Properties(${agent.propertyCount})').size(
                      context.font.normal,
                    ),
                  ],
                ),
              ),
            ),
            // ),
          ],
        ),
      ),
    );
  }
}
