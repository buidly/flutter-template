import 'package:fluttertemplate/core/models/transaction.dart';
import 'package:fluttertemplate/layers/data/source/network/transactions_api.dart';
import 'package:fluttertemplate/layers/domain/entity/transaction_on_network.dart';
import 'package:fluttertemplate/layers/domain/repository/transactions_repository.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsApi _api;

  TransactionsRepositoryImpl({
    required TransactionsApi api,
  }) : _api = api;

  @override
  Future<List<TransactionOnNetwork>> getTransactions(
    List<String> hashes,
  ) async {
    final fetchedList = await _api.getTransactions(hashes);
    return fetchedList;
  }

  @override
  Future<List<String>> sendTransactions(List<Transaction> transactions) async {
    final hashes = await _api.sendTransactions(transactions);
    return hashes;
  }
}
