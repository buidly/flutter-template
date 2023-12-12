import 'package:equatable/equatable.dart';
import 'package:fluttertemplate/core/models/transaction.dart';

enum TransactionStatus { initial, readyToSign, pending, error }

class TransactionState extends Equatable {
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.txHashes = const [],
  });

  final TransactionStatus status;
  final List<String> txHashes;

  TransactionState copyWith({
    TransactionStatus? status,
    List<Transaction>? signedTransactions,
    List<String>? txHashes,
  }) {
    return TransactionState(
      status: status ?? this.status,
      txHashes: txHashes ?? this.txHashes,
    );
  }

  @override
  List<Object> get props => [
        status,
        txHashes,
      ];
}
