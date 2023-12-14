import 'dart:async';

import 'package:fluttertemplate/core/constants/app_constants.dart';
import 'package:fluttertemplate/flavor_settings.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectionService {
  late final SignClient signClient;
  late final FlavorSettings flavorSettings;

  late final StreamController<SessionData> _connectionController =
      StreamController<SessionData>.broadcast();
  Stream<SessionData> get connectionStream => _connectionController.stream;

  late final StreamController<void> _disconnectController =
      StreamController<void>.broadcast();
  Stream<void> get disconnectStream => _disconnectController.stream;

  WalletConnectionService({required this.flavorSettings}) {
    signClient.onSessionConnect.subscribe((SessionConnect? sessionConnect) {
      if (sessionConnect != null) {
        SessionData session = sessionConnect.session;
        topic = session.topic;
        _connectionController.add(session);
      }
    });

    signClient.onSessionDelete.subscribe((SessionDelete? session) {
      if (session != null) {
        topic = '';
        _disconnectController.add(null);
      }
    });
  }

  String topic = '';

  Future<void> initializeClient() async {
    signClient = await SignClient.createInstance(
      relayUrl: AppConstants.relayUrl,
      projectId: AppConstants.projectId,
      metadata: const PairingMetadata(
        name: 'dApp (Requester)',
        description: 'A dapp that can request that transactions be signed',
        url: 'https://walletconnect.com',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
        redirect: Redirect(native: 'myflutterdapp://', universal: null),
      ),
    );
  }

  Future<String> connect() async {
    ConnectResponse resp = await signClient.connect(
      requiredNamespaces: {
        AppConstants.namespace: RequiredNamespace(
          chains: ['${AppConstants.namespace}:${flavorSettings.chainId}'],
          methods: [
            'mvx_signTransaction',
            'mvx_signTransactions',
            'mvx_signMessage',
          ],
          events: [],
        ),
      },
    );

    Uri? uri = resp.uri;

    final String url =
        '${AppConstants.multiversxDeeplinkUrl}?wallet-connect=${Uri.encodeComponent(uri.toString())}';

    return url;
  }

  disconnect() async {
    signClient.disconnect(
      topic: topic,
      reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
    );
  }

  bool isConnected() {
    return topic.isNotEmpty;
  }
}
