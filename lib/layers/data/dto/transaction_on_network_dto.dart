import 'package:fluttertemplate/layers/domain/entity/transaction_on_network.dart';

class TransactionOnNetworkDto extends TransactionOnNetwork {
  TransactionOnNetworkDto({
    required super.signature,
    super.guardian,
    super.guardianSignature,
    super.options,
    super.version,
  });

  factory TransactionOnNetworkDto.fromMap(Map<String, dynamic> json) =>
      TransactionOnNetworkDto(
        signature: json['signature'],
        guardian: json['guardian'],
        guardianSignature: json['guardianSignature'],
        options: json['options'],
        version: json['version'],
      );

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'signature': signature,
      'guardian': guardian,
      'guardianSignature': guardianSignature,
      'options': options,
      'version': version,
    };
    return data;
  }
}
