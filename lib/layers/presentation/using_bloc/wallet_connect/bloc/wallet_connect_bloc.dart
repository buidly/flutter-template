import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fluttertemplate/core/constants/app_constants.dart';
import 'package:fluttertemplate/core/services/wallet_connection_service.dart';
import 'package:fluttertemplate/core/utils/get_address_from_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
part 'wallet_connect_event.dart';
part 'wallet_connect_state.dart';

class WalletConnectBloc extends Bloc<WalletConnectEvent, WalletConnectState> {
  late final WalletConnectionService walletConnectionService;
  late final SharedPreferences prefs;

  WalletConnectBloc(
      {required this.walletConnectionService, required this.prefs})
      : super(const WalletConnectInitial()) {
    on<ConnectWalletEvent>(connectWallet);
    on<WalletConnectedEvent>(walletConnected);
    on<DisconnectWalletEvent>(disconnectWallet);
    on<WalletDisconnectedEvent>(walletDisconnected);

    initWsListeners();
  }

  Future<void> initWsListeners() async {
    walletConnectionService.connectionStream.listen((SessionData session) {
      add(WalletConnectedEvent(session: session));
    });

    walletConnectionService.disconnectStream.listen((_) {
      add(const WalletDisconnectedEvent());
    });
  }

  void connectWallet(
    ConnectWalletEvent event,
    Emitter<WalletConnectState> emit,
  ) async {
    emit(const WalletConnectLoading());

    try {
      String url = await walletConnectionService.connect();

      emit(WalletConnectInitiated(url: url));
    } catch (error) {
      emit(
        WalletConnectError(
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> disconnectWallet(
    DisconnectWalletEvent event,
    Emitter<WalletConnectState> emit,
  ) async {
    if (!walletConnectionService.isConnected()) {
      return;
    }

    walletConnectionService.disconnect();
  }

  Future<void> walletConnected(
    WalletConnectedEvent event,
    Emitter<WalletConnectState> emit,
  ) async {
    String address = getAddressFromSession(event.session);
    emit(WalletConnectConnected(address: address));

    String? nativeAuthToken = prefs.getString(AppConstants.nativeAuthTokenKey);
    if (nativeAuthToken == null) {
      Map<String, String> signatureResponse =
          await walletConnectionService.requestSignature(address);
      String nativeAuthToken = signatureResponse['nativeAuthToken'] ?? '';
      prefs.setString(AppConstants.nativeAuthTokenKey, nativeAuthToken);
    }
  }

  Future<void> walletDisconnected(
    WalletDisconnectedEvent event,
    Emitter<WalletConnectState> emit,
  ) async {
    prefs.remove(AppConstants.nativeAuthTokenKey);
    emit(const WalletConnectInitial());
  }
}
