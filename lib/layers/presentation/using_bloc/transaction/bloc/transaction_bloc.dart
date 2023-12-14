import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fluttertemplate/core/models/transaction.dart';
import 'package:fluttertemplate/core/services/wallet_connection_service.dart';
import 'package:fluttertemplate/flavor_settings.dart';
import 'package:fluttertemplate/layers/domain/entity/transaction_on_network.dart';
import 'package:fluttertemplate/layers/domain/usecase/get_transactions.dart';
import 'package:fluttertemplate/layers/domain/usecase/send_transactions.dart';
import 'package:fluttertemplate/layers/presentation/using_bloc/transaction/bloc/transaction_state.dart';
part 'transaction_event.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final WalletConnectionService walletConnectionService;
  final SendTransactions sendTransactions;
  final GetTransactions getTransactions;
  final FlavorSettings flavorSettings;

  TransactionBloc({
    required this.walletConnectionService,
    required this.sendTransactions,
    required this.getTransactions,
    required this.flavorSettings,
  }) : super(const TransactionState()) {
    on<SignTransactionsEvent>(signTransactions);
  }

  Future<void> signTransactions(
    SignTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (!walletConnectionService.isConnected()) {
      return;
    }

    emit(state.copyWith(status: TransactionStatus.readyToSign));

    List<Transaction> signedTransactions = await walletConnectionService
        .requestSignTransactions(event.transactions);

    List<String> txHashes = await sendTransactions(signedTransactions);
    if (txHashes.isEmpty) {
      emit(
        state.copyWith(
          status: TransactionStatus.error,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: TransactionStatus.pending,
        txHashes: txHashes,
      ),
    );

    await checkTransactionsStatus(txHashes, emit);
  }

  Future<void> checkTransactionsStatus(
    List<String> hashes,
    Emitter<TransactionState> emit,
  ) async {
    while (true) {
      List<TransactionOnNetwork> transactions = await getTransactions(hashes);

      bool allCompleted = transactions.every((tx) => tx.status != 'pending');
      if (allCompleted) {
        emit(
          state.copyWith(
            status: TransactionStatus.initial,
          ),
        );
        break;
      }

      await Future.delayed(const Duration(seconds: 6));
    }
  }
}
