import 'package:fluttertemplate/core/constants/app_constants.dart';
import 'package:fluttertemplate/flavor_settings.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectionService {
  late final SignClient wcClient;
  late final FlavorSettings flavorSettings;

  WalletConnectionService({required this.flavorSettings});

  String topic = '';

  Future<void> initializeClient() async {
    wcClient = await SignClient.createInstance(
      relayUrl: AppConstants.relayUrl,
      projectId: AppConstants.projectId,
      metadata: const PairingMetadata(
        name: 'dApp (Requester)',
        description: 'A dapp that can request that transactions be signed',
        url: 'https://walletconnect.com',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
        redirect: Redirect(
          native: 'myflutterdapp://',
          universal: 'https://walletconnect.com',
        ),
      ),
    );
  }

  Future<String> connect() async {
    ConnectResponse resp = await wcClient.connect(
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
}
