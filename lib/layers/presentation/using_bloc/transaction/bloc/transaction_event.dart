part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

final class SignTransactionsEvent extends TransactionEvent {
  final List<Transaction> transactions;

  const SignTransactionsEvent({required this.transactions});

  @override
  List<Object> get props => [transactions];
}
