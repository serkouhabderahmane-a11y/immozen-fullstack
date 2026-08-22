import 'package:immozen/data/cubits/agents/fetch_projects_cubit.dart';
import 'package:immozen/data/repositories/project_repository.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:flutter/material.dart';

class AgentProjects extends StatefulWidget {
  const AgentProjects({
    required this.agentId,
    super.key,
  });

  final int agentId;

  @override
  State<AgentProjects> createState() => _AgentProjectsState();
}

class _AgentProjectsState extends State<AgentProjects> {
  ///This Scroll controller for listen page end
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    _pageScrollController.addListener(onPageEnd);
    context.read<FetchAgentsProjectCubit>().fetchAgentsProject(
          forceRefresh: false,
          agentId: widget.agentId,
        );
    super.initState();
  }

  ///This method will listen page scroll changes
  void onPageEnd() {
    ///This is exetension which will check if we reached end or not
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchAgentsProjectCubit>().hasMoreData()) {
        context.read<FetchAgentsProjectCubit>().fetchMore();
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
      body: BlocBuilder<FetchAgentsProjectCubit, FetchAgentsProjectState>(
        builder: (context, state) {
          if (state is FetchProjectsInProgress) {
            return Center(
              child: UiUtils.progress(
                normalProgressColor: context.color.tertiaryColor,
              ),
            );
          }
          if (state is FetchAgentsProjectFailure) {
            return const SomethingWentWrong();
          }
          if (state is FetchAgentsProjectSuccess &&
              state.agentsProperty.projectData.isEmpty) {
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
                  context.read<FetchAgentsProjectCubit>().fetchAgentsProject(
                        agentId: widget.agentId,
                        forceRefresh: true,
                      );
                },
              ),
            );
          }
          if (state is FetchAgentsProjectSuccess) {
            return Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: RemoveGlow(),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.only(
                        top: 15,
                        left: 18,
                        right: 18,
                      ),
                      padding: const EdgeInsets.only(
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
                              '${state.agentsProperty.customerData.projectCount} ${UiUtils.translate(context, 'projects')}',
                            ).bold(weight: FontWeight.w700),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              controller: _pageScrollController,
                              itemCount:
                                  state.agentsProperty.projectData.length,
                              itemBuilder: (context, index) {
                                final agentsProperty =
                                    state.agentsProperty.projectData[index];
                                return GestureDetector(
                                  onTap: () async {
                                    unawaited(Widgets.showLoader(context));
                                    final fetch = ProjectRepository();
                                    final dataOutput =
                                        await fetch.fetchProjectFromProjectId(
                                      agentsProperty.id,
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
                                  },
                                  child: ProjectCard(
                                    categoryName:
                                        agentsProperty.category.category,
                                    url: agentsProperty.image,
                                    title: agentsProperty.title,
                                    description: agentsProperty.city,
                                    categoryIcon: agentsProperty.category.image,
                                    status: agentsProperty.type,
                                  ),
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
                    .watch<FetchAgentsProjectCubit>()
                    .isLoadingMore()) ...[
                  Center(child: UiUtils.progress()),
                ],
                const SizedBox(
                  height: 30,
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
