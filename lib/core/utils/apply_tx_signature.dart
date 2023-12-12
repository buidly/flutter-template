import 'package:fluttertemplate/core/models/transaction.dart';
import 'package:fluttertemplate/core/models/transaction_response.dart';

Transaction applyTransactionSignature({
  required Transaction transaction,
  required TransactionResponse? response,
}) {
  if (response == null) {
    throw ArgumentError('Invalid transaction response');
  }

  final String signature = response.signature;
  final String? guardianSignature = response.guardianSignature;
  final int? version = response.version;
  final int? options = response.options;
  final String? guardian = response.guardian;

  if (transaction.guardian != null && transaction.guardian != guardian) {
    throw ArgumentError('Invalid guardian');
  }

  if (guardian != null) {
    transaction.guardian = guardian;
  }

  if (version != null) {
    transaction.version = version;
  }

  if (options != null) {
    transaction.options = options;
  }

  transaction.signature = signature;

  if (guardianSignature != null) {
    transaction.guardianSignature = guardianSignature;
  }

  return transaction;
}
