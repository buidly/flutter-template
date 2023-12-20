import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertemplate/core/services/native_auth_service.dart';
import 'package:fluttertemplate/flavor_settings.dart';
import 'package:get_it/get_it.dart';
import 'package:fluttertemplate/core/services/wallet_connection_service.dart';
import 'package:fluttertemplate/layers/data/source/network/transactions_api.dart';
import 'package:fluttertemplate/layers/data/transactions_repository_impl.dart';
import 'package:fluttertemplate/layers/domain/repository/transactions_repository.dart';
import 'package:fluttertemplate/layers/domain/usecase/get_transactions.dart';
import 'package:fluttertemplate/layers/domain/usecase/send_transactions.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerSingleton<FlavorSettings>(await _getFlavorSettings());
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
  getIt.registerSingleton<NativeAuthService>(NativeAuthService(
    flavorSettings: getIt<FlavorSettings>(),
    dio: getIt<Dio>(),
  ));
  getIt.registerSingleton<Alice>(
    Alice(
      showNotification: false,
      showInspectorOnShake: kDebugMode,
    ),
  );
  getIt.registerSingleton<WalletConnectionService>(
    WalletConnectionService(
      flavorSettings: getIt<FlavorSettings>(),
      nativeAuthService: getIt<NativeAuthService>(),
    ),
  );
  getIt.registerFactory<TransactionsApi>(
    () => TransactionsApiImpl(
      dio: getIt<Dio>(),
      flavorSettings: getIt<FlavorSettings>(),
    ),
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

Future<FlavorSettings> _getFlavorSettings() async {
  String flavor =
      await const MethodChannel('flavor').invokeMethod<String>('getFlavor') ??
          '';

  if (flavor == 'devnet') {
    return FlavorSettings.devnet();
  } else if (flavor == 'mainnet') {
    return FlavorSettings.mainnet();
  } else if (flavor == 'testnet') {
    return FlavorSettings.testnet();
  } else {
    throw Exception("Unknown flavor: $flavor");
  }
}
