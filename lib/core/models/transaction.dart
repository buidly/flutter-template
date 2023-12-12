class Transaction {
  int nonce;
  String value;
  String sender;
  String receiver;
  String? senderUsername;
  String? receiverUsername;
  int gasPrice;
  int gasLimit;
  String data;
  String chainID;
  int version;
  int options;
  String? guardian;
  String? signature;
  String? guardianSignature;
  String? hash;

  Transaction({
    required this.nonce,
    required this.value,
    required this.sender,
    required this.receiver,
    this.senderUsername,
    this.receiverUsername,
    required this.gasPrice,
    required this.gasLimit,
    required this.data,
    required this.chainID,
    required this.version,
    required this.options,
    this.guardian,
    this.signature,
    this.guardianSignature,
    this.hash,
  });

  Map<String, dynamic> toJson() {
    return {
      'nonce': nonce,
      'value': value,
      'sender': sender,
      'receiver': receiver,
      'senderUsername': senderUsername,
      'receiverUsername': receiverUsername,
      'gasPrice': gasPrice,
      'gasLimit': gasLimit,
      'data': data,
      'chainID': chainID,
      'version': version,
      'options': options,
      'guardian': guardian,
      'signature': signature,
      'guardianSignature': guardianSignature,
      'hash': hash,
    };
  }
}
