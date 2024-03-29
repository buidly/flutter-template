import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertemplate/core/models/transaction.dart';
import 'package:fluttertemplate/layers/presentation/using_bloc/transaction/bloc/transaction_bloc.dart';
import 'package:fluttertemplate/layers/presentation/using_bloc/transaction/bloc/transaction_state.dart';

// -----------------------------------------------------------------------------
// Button
// -----------------------------------------------------------------------------
class SignTransactionButton extends StatelessWidget {
  const SignTransactionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignTransactionView();
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------
class SignTransactionView extends StatelessWidget {
  const SignTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionBloc = BlocProvider.of<TransactionBloc>(context);

    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(130.0, 45.0),
        ),
        onPressed: () {
          transactionBloc.add(
            SignTransactionsEvent(
              transactions: List.filled(
                1,
                Transaction(
                  nonce: 0,
                  value: '1000000000000000',
                  sender: '',
                  receiver: '',
                  gasPrice: 1000000000,
                  gasLimit: 70000,
                  data: '',
                  version: 1,
                  options: 0,
                  chainID: 'D',
                ),
              ),
            ),
          );
        },
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state.status == TransactionStatus.pending) {
              return const SizedBox(
                height: 16,
                width: 16,
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              return const Text('Sign');
            }
          },
        ));
  }
}
