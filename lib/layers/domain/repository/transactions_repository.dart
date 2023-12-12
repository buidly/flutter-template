import 'package:fluttertemplate/core/models/transaction.dart';
import 'package:fluttertemplate/layers/domain/entity/transaction_on_network.dart';

abstract class TransactionsRepository {
  Future<List<TransactionOnNetwork>> getTransactions(List<String> hashes);
  Future<List<String>> sendTransactions(List<Transaction> transactions);
}
