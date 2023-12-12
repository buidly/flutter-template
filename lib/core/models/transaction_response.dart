class TransactionResponse {
  final String signature;
  final String? guardian;
  final String? guardianSignature;
  final int? options;
  final int? version;

  TransactionResponse({
    required this.signature,
    this.guardian,
    this.guardianSignature,
    this.options,
    this.version,
  });
}
