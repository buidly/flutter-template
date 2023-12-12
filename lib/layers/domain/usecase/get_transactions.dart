import 'package:fluttertemplate/layers/domain/entity/transaction_on_network.dart';
import 'package:fluttertemplate/layers/domain/repository/transactions_repository.dart';

class GetTransactions {
  GetTransactions({
    required TransactionsRepository repository,
  }) : _repository = repository;

  final TransactionsRepository _repository;

  Future<List<TransactionOnNetwork>> call(List<String> hashes) async {
    final list = await _repository.getTransactions(hashes);
    return list;
  }
}
