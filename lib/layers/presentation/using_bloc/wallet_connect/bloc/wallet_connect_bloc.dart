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
        walletConnectionService.wcClient.getActiveSessions();
    if (sessions.isNotEmpty) {
      SessionData sessionData = sessions.entries.first.value;
      add(WalletConnectedEvent(session: sessionData));
    }

    walletConnectionService.wcClient.onSessionConnect
        .subscribe((SessionConnect? session) {
      if (session != null) {
        add(WalletConnectedEvent(session: session.session));
      }
    });

    walletConnectionService.wcClient.onSessionDelete
        .subscribe((SessionDelete? session) {
      if (session != null) {
        add(const WalletDisconnectedEvent());
      }
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
    if (!isConnected()) {
      return;
    }

    walletConnectionService.wcClient.disconnect(
      topic: walletConnectionService.topic,
      reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
    );
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
    walletConnectionService.topic = '';
  }

  bool isConnected() {
    return state is WalletConnectConnected;
  }
}
