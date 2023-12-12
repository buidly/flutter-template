import 'package:fluttertemplate/core/models/transaction.dart';
import 'package:fluttertemplate/layers/domain/repository/transactions_repository.dart';

class SendTransactions {
  SendTransactions({
    required TransactionsRepository repository,
  }) : _repository = repository;

  final TransactionsRepository _repository;

  Future<List<String>> call(List<Transaction> transactions) async {
    print('call usecase with');
    final list = await _repository.sendTransactions(transactions);
    return list;
  }
}
