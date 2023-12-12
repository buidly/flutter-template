part of 'wallet_connect_bloc.dart';

class WalletConnectState extends Equatable {
  const WalletConnectState();

  @override
  List<Object> get props => [];
}

class WalletConnectInitial extends WalletConnectState {
  const WalletConnectInitial();
}

class WalletConnectLoading extends WalletConnectState {
  const WalletConnectLoading();
}

class WalletConnectConnected extends WalletConnectState {
  final String address;

  const WalletConnectConnected({required this.address});

  @override
  List<Object> get props => [address];
}

class WalletConnectInitiated extends WalletConnectState {
  final String url;

  const WalletConnectInitiated({required this.url});

  @override
  List<Object> get props => [url];
}

class WalletConnectError extends WalletConnectState {
  final String message;

  const WalletConnectError({required this.message});

  @override
  List<Object> get props => [message];
}
