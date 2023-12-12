part of 'wallet_connect_bloc.dart';

sealed class WalletConnectEvent extends Equatable {
  const WalletConnectEvent();

  @override
  List<Object?> get props => [];
}

final class ConnectWalletEvent extends WalletConnectEvent {
  const ConnectWalletEvent();
}

final class DisconnectWalletEvent extends WalletConnectEvent {
  const DisconnectWalletEvent();
}

final class WalletConnectedEvent extends WalletConnectEvent {
  final SessionData session;

  const WalletConnectedEvent({required this.session});

  @override
  List<Object> get props => [session];
}

final class WalletDisconnectedEvent extends WalletConnectEvent {
  const WalletDisconnectedEvent();

  @override
  List<Object> get props => [];
}
