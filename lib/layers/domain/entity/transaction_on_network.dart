import 'package:equatable/equatable.dart';

class TransactionOnNetwork extends Equatable {
  final String sender;
  final String receiver;
  final int nonce;
  final String value;
  final String signature;
  final String txHash;
  final String status;
  final String? function;

  const TransactionOnNetwork({
    required this.sender,
    required this.receiver,
    required this.nonce,
    required this.value,
    required this.signature,
    required this.txHash,
    this.function,
    required this.status,
  });

  @override
  List<Object?> get props => [
        sender,
        receiver,
        nonce,
        value,
        signature,
        txHash,
        status,
      ];
}
