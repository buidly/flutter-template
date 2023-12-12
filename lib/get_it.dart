import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:fluttertemplate/core/services/wallet_connection_service.dart';
import 'package:fluttertemplate/layers/data/source/network/transactions_api.dart';
import 'package:fluttertemplate/layers/data/transactions_repository_impl.dart';
import 'package:fluttertemplate/layers/domain/repository/transactions_repository.dart';
import 'package:fluttertemplate/layers/domain/usecase/get_transactions.dart';
import 'package:fluttertemplate/layers/domain/usecase/send_transactions.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<Alice>(
    Alice(
      showNotification: kDebugMode,
      showInspectorOnShake: kDebugMode,
    ),
  );
  getIt.registerSingleton<WalletConnectionService>(WalletConnectionService());
  getIt.registerFactory<TransactionsApi>(
    () => TransactionsApiImpl(dio: getIt<Dio>()),
  );
  getIt.registerFactory<TransactionsRepository>(
    () => TransactionsRepositoryImpl(api: getIt<TransactionsApi>()),
  );
  getIt.registerFactory<GetTransactions>(
    () => GetTransactions(repository: getIt<TransactionsRepository>()),
  );
  getIt.registerFactory<SendTransactions>(
    () => SendTransactions(repository: getIt<TransactionsRepository>()),
  );
}
