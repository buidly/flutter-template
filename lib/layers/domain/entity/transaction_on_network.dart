import 'package:equatable/equatable.dart';

class TransactionOnNetwork with EquatableMixin {
  final String signature;
  final String? guardian;
  final String? guardianSignature;
  final int? options;
  final int? version;

  TransactionOnNetwork({
    required this.signature,
    this.guardian,
    this.guardianSignature,
    this.options,
    this.version,
  });

  @override
  List<Object?> get props =>
      [signature, guardian, guardianSignature, options, version];
}
