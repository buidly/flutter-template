import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fluttertemplate/core/constants/app_constants.dart';
import 'package:fluttertemplate/core/models/transaction.dart';
import 'package:fluttertemplate/core/models/transaction_response.dart';
import 'package:fluttertemplate/core/services/wallet_connection_service.dart';
import 'package:fluttertemplate/core/utils/apply_tx_signature.dart';
import 'package:fluttertemplate/layers/domain/entity/transaction_on_network.dart';
import 'package:fluttertemplate/layers/domain/usecase/get_transactions.dart';
import 'package:fluttertemplate/layers/domain/usecase/send_transactions.dart';
import 'package:fluttertemplate/layers/presentation/using_bloc/transaction/bloc/transaction_state.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/json_rpc_models.dart';
part 'transaction_event.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final WalletConnectionService walletConnectionService;
  final SendTransactions sendTransactions;
  final GetTransactions getTransactions;

  TransactionBloc({
    required this.walletConnectionService,
    required this.sendTransactions,
    required this.getTransactions,
  }) : super(const TransactionState()) {
    on<SignTransactionsEvent>(signTransactions);
  }

  Future<void> signTransactions(
    SignTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    //todo check if its connected

    emit(state.copyWith(status: TransactionStatus.readyToSign));

    List<Transaction> transactions = event.transactions;
    String method = transactions.length > 1
        ? 'mvx_signTransactions'
        : 'mvx_signTransaction';

    Object params = transactions.length > 1
        ? {'transactions': transactions.map((tx) => tx.toJson())}
        : {'transaction': transactions[0].toJson()};

    final dynamic signResponse = await walletConnectionService.wcClient.request(
      chainId: '${AppConstants.namespace}:${AppConstants.chainId}',
      topic: walletConnectionService.topic,
      request: SessionRequestParams(
        method: method,
        params: params,
      ),
    );

    List<Transaction> signedTransactions =
        getSignedTransactions(signResponse, event);

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

  List<Transaction> getSignedTransactions(
    dynamic signResponse,
    SignTransactionsEvent event,
  ) {
    List<TransactionResponse> transactionResponses = [];

    if (signResponse is List) {
      transactionResponses = signResponse
          .map<TransactionResponse>(
            (dynamic data) => parseTransactionResponse(data),
          )
          .toList();
    } else {
      transactionResponses.add(parseTransactionResponse(signResponse));
    }

    List<Transaction> signedTransactions = transactionResponses.map((response) {
      return applyTransactionSignature(
        transaction: event.transactions[transactionResponses.indexOf(response)],
        response: response,
      );
    }).toList();

    return signedTransactions;
  }

  TransactionResponse parseTransactionResponse(dynamic signResponse) {
    if (signResponse == null || signResponse is! Map<String, dynamic>) {
      throw ArgumentError('Invalid sign response format');
    }

    final Map<String, dynamic> responseMap = signResponse;

    return TransactionResponse(
      signature: responseMap['signature'],
      guardian: responseMap['guardian'],
      guardianSignature: responseMap['guardianSignature'],
      options: responseMap['options'],
      version: responseMap['version'],
    );
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
