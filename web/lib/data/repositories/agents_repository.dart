import 'package:immozen/data/model/agent/agent_model.dart';
import 'package:immozen/data/model/agent/agents_property_model.dart';
import 'package:immozen/data/model/data_output.dart';
import 'package:immozen/utils/api.dart';
import 'package:immozen/utils/constant.dart';

class AgentsRepository {
  Future<DataOutput<AgentModel>> fetchAllAgents({
    required int offset,
  }) async {
    final response = await Api.get(
      url: Api.getAgents,
      queryParameters: {
        Api.limit: Constant.loadLimit,
        Api.offset: offset,
      },
    );
    print("agents list ---------------------");
    print(response['data']);
    final modelList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<AgentModel>(AgentModel.fromJson)
        .toList();
    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<({int total, AgentsProperty agentsProperty})> fetchAgentProperties({
    required int offset,
    required int agentId,
  }) async {
    final parameters = <String, dynamic>{
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      Api.id: agentId,
    };

    final result = await Api.get(
      url: Api.getAgentProperties,
      queryParameters: parameters,
    );
    final data = result['data'] as Map<String, dynamic>;

    final agentsProperty = AgentsProperty.fromJson(data);
    final total = result['total'] as int? ?? 0;

    return (
      total: total,
      agentsProperty: agentsProperty,
    );
  }

  Future<({int total, AgentsProperty agentsProperty})> fetchAgentProjects({
    required int agentId,
    required int offset,
    required int isProjects,
  }) async {
    final parameters = <String, dynamic>{
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      Api.isProjects: isProjects,
      Api.id: agentId,
    };

    final result = await Api.get(
      url: Api.getAgentProperties,
      queryParameters: parameters,
    );
    final data = result['data'] as Map<String, dynamic>;
    final total = result['total'] as int;

    return (
      total: total,
      agentsProperty: AgentsProperty.fromJson(data),
    );
  }
}
