import 'dart:developer';

import 'package:immozen/data/cubits/agents/fetch_property_cubit.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:immozen/ui/screens/agents/cards/agent_property_card.dart';
import 'package:flutter/material.dart';

class AgentProperties extends StatefulWidget {
  const AgentProperties({
    required this.agentId,
    super.key,
  });

  final int agentId;

  @override
  State<AgentProperties> createState() => _AgentPropertiesState();
}

class _AgentPropertiesState extends State<AgentProperties> {
  ///This Scroll controller for listen page end
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    _pageScrollController.addListener(onPageEnd);
    super.initState();
  }

  ///This method will listen page scroll changes
  void onPageEnd() {
    ///This is exetension which will check if we reached end or not
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchAgentsPropertyCubit>().hasMoreData()) {
        context.read<FetchAgentsPropertyCubit>().fetchMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final back = context.color.brightness == Brightness.light
        ? Colors.grey.shade100
        : Colors.grey.shade900;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<FetchAgentsPropertyCubit, FetchAgentsPropertyState>(
        builder: (agentsContext, state) {
          if (state is FetchAgentsPropertySuccess &&
              state.agentsProperty.propertiesData.isEmpty) {
            return Container(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(
                top: 15,
                left: 18,
                right: 18,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                color: context.color.brightness == Brightness.light
                    ? context.color.backgroundColor
                    : back,
                boxShadow: [
                  BoxShadow(
                    color: context.color.inverseSurface.withOpacity(0.1),
                    blurRadius: 5,
                  ),
                ],
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: NoDataFound(
                onTap: () {
                  context.read<FetchAgentsPropertyCubit>().fetchAgentsProperty(
                        agentId: widget.agentId,
                        forceRefresh: true,
                      );
                },
              ),
            );
          }
          if (state is FetchAgentsPropertySuccess &&
              state.agentsProperty.propertiesData.isNotEmpty) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: ScrollConfiguration(
                    behavior: RemoveGlow(),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.only(
                        top: 15,
                        left: 18,
                        right: 18,
                      ),
                      decoration: BoxDecoration(
                        color: context.color.brightness == Brightness.light
                            ? context.color.backgroundColor
                            : back,
                        boxShadow: [
                          BoxShadow(
                            color:
                                context.color.inverseSurface.withOpacity(0.05),
                            blurRadius: 5,
                          ),
                        ],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                              left: 18,
                              right: 18,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            height: 36,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color:
                                  context.color.brightness == Brightness.light
                                      ? back
                                      : context.color.backgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                color: context.color.inverseSurface,
                              ),
                              '${state.agentsProperty.customerData.propertyCount} ${UiUtils.translate(context, 'properties')}',
                            ).bold(weight: FontWeight.w700),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              controller: _pageScrollController,
                              itemCount:
                                  state.agentsProperty.propertiesData.length,
                              itemBuilder: (context, index) {
                                final agentsProperty =
                                    state.agentsProperty.propertiesData[index];
                                return PropertyCard(
                                  a: agentsProperty,
                                  onTap: () async {
                                    try {
                                      unawaited(Widgets.showLoader(context));
                                      final fetch = PropertyRepository();
                                      final dataOutput = await fetch
                                          .fetchPropertyFromPropertyId(
                                        agentsProperty.id,
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
                                              'propertyData':
                                                  dataOutput.modelList[0],
                                              'propertiesList':
                                                  dataOutput.modelList,
                                              'fromMyProperty': false,
                                            },
                                          );
                                        },
                                      );
                                    } catch (e) {
                                      log('Error is $e');
                                      Widgets.hideLoder(context);
                                    }
                                    // if (context
                                    //         .read<FetchPropertyByAgentCubit>()
                                    //         .state
                                    //     is FetchPropertyByAgentInProgress) {
                                    //   return;
                                    // }
                                    // context
                                    //     .read<FetchPropertyByAgentCubit>()
                                    //     .fetchPropertyByAgent(
                                    //       agentId: agentsProperty.addedBy,
                                    //       propertyId: agentsProperty.id,
                                    //     );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (context
                    .watch<FetchAgentsPropertyCubit>()
                    .isLoadingMore()) ...[
                  Center(child: UiUtils.progress()),
                ],
                const SizedBox(
                  height: 30,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
