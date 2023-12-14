import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fluttertemplate/core/services/wallet_connection_service.dart';
import 'package:fluttertemplate/core/utils/get_address_from_session.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
part 'wallet_connect_event.dart';
part 'wallet_connect_state.dart';

class WalletConnectBloc extends Bloc<WalletConnectEvent, WalletConnectState> {
  late final WalletConnectionService walletConnectionService;

  WalletConnectBloc(this.walletConnectionService)
      : super(const WalletConnectInitial()) {
    on<ConnectWalletEvent>(connectWallet);
    on<WalletConnectedEvent>(walletConnected);
    on<DisconnectWalletEvent>(disconnectWallet);
    on<WalletDisconnectedEvent>(walletDisconnected);

    initWsListeners();
  }

  Future<void> initWsListeners() async {
    Map<String, SessionData> sessions =
        walletConnectionService.signClient.getActiveSessions();
    if (sessions.isNotEmpty) {
      SessionData sessionData = sessions.entries.first.value;
      add(WalletConnectedEvent(session: sessionData));
    }

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
    walletConnectionService.topic = event.session.topic;
    emit(WalletConnectConnected(address: address));
  }

  Future<void> walletDisconnected(
    WalletDisconnectedEvent event,
    Emitter<WalletConnectState> emit,
  ) async {
    emit(const WalletConnectInitial());
  }
}
