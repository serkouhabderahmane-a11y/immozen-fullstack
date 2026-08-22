import 'package:immozen/data/model/data_output.dart';
import 'package:immozen/data/model/transaction_model.dart';
import 'package:immozen/utils/api.dart';

class TransactionRepository {
  Future<DataOutput<TransactionModel>> fetchTransactions() async {
    final parameters = <String, dynamic>{};

    final response = await Api.get(
      url: Api.getPaymentDetails,
      queryParameters: parameters,
    );

    final transactionList = (response['data'] as List)
        .cast<Map<String, dynamic>>()
        .map<TransactionModel>(TransactionModel.fromMap)
        .toList();

    return DataOutput<TransactionModel>(
      total: transactionList.length,
      modelList: transactionList,
    );
  }
}
