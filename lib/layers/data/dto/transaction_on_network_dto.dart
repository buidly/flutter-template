import 'package:fluttertemplate/layers/domain/entity/transaction_on_network.dart';

class TransactionOnNetworkDto extends TransactionOnNetwork {
  const TransactionOnNetworkDto({
    super.sender = '',
    super.receiver = '',
    super.nonce = 0,
    super.value = '',
    super.signature = '',
    super.txHash = '',
    super.status = '',
    super.function,
  });

  factory TransactionOnNetworkDto.fromMap(Map<String, dynamic> json) {
    return TransactionOnNetworkDto(
      sender: json['sender'],
      receiver: json['receiver'],
      nonce: json['nonce'] as int,
      value: json['value'],
      function: json['function'],
      signature: json['signature'],
      txHash: json['txHash'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'receiver': receiver,
      'nonce': nonce,
      'value': value,
      'signature': signature,
      'txHash': txHash,
      'status': status,
    };
  }
}
