import 'package:fluttertemplate/core/constants/app_constants.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectionService {
  late final SignClient wcClient;

  String topic = '';

  Future<void> initializeClient() async {
    print('initializing');
    Stopwatch stopwatch = Stopwatch()..start();

    wcClient = await SignClient.createInstance(
      relayUrl: AppConstants.relayUrl,
      projectId: AppConstants.projectId,
      metadata: const PairingMetadata(
        name: 'dApp (Requester)',
        description: 'A dapp that can request that transactions be signed',
        url: 'https://walletconnect.com',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
        redirect: Redirect(
          native: 'walletconnect://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
    );
    stopwatch.stop();
    print('Initialization took: ${stopwatch.elapsedMilliseconds}ms');
  }

  Future<String> connect() async {
    ConnectResponse resp = await wcClient.connect(
      requiredNamespaces: {
        AppConstants.namespace: const RequiredNamespace(
          chains: ['${AppConstants.namespace}:${AppConstants.chainId}'],
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
