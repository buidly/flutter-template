import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertemplate/core/utils/open_deep_link.dart';
import 'package:fluttertemplate/layers/presentation/using_bloc/wallet_connect/bloc/wallet_connect_bloc.dart';

// -----------------------------------------------------------------------------
// Button
// -----------------------------------------------------------------------------
class WalletConnectButton extends StatelessWidget {
  const WalletConnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalletConnectView();
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------
class WalletConnectView extends StatelessWidget {
  const WalletConnectView({super.key});

  @override
  Widget build(BuildContext context) {
    final walletConnectBloc = BlocProvider.of<WalletConnectBloc>(context);

    return BlocListener<WalletConnectBloc, WalletConnectState>(
      listener: (context, state) {
        if (state is WalletConnectInitiated) {
          final url = state.url;
          openDeepLink(url);
        }
      },
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(130.0, 45.0),
        ),
        onPressed: () {
          if (walletConnectBloc.state.runtimeType == WalletConnectConnected) {
            walletConnectBloc.add(const DisconnectWalletEvent());
          } else {
            walletConnectBloc.add(const ConnectWalletEvent());
          }
        },
        child: BlocBuilder<WalletConnectBloc, WalletConnectState>(
          builder: (context, state) {
            switch (state.runtimeType) {
              case WalletConnectLoading:
                return const SizedBox(
                  height: 16,
                  width: 16,
                  child: Center(child: CircularProgressIndicator()),
                );
              case WalletConnectConnected:
                return const Text('Disconnect');
              default:
                return const Text('Connect');
            }
          },
        ),
      ),
    );
  }
}
