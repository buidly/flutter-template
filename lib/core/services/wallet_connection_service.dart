import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertemplate/core/constants/app_constants.dart';
import 'package:fluttertemplate/core/models/transaction.dart';
import 'package:fluttertemplate/core/models/transaction_response.dart';
import 'package:fluttertemplate/core/services/native_auth_service.dart';
import 'package:fluttertemplate/core/utils/apply_tx_signature.dart';
import 'package:fluttertemplate/flavor_settings.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectionService {
  late final SignClient signClient;
  late final FlavorSettings flavorSettings;
  late final NativeAuthService nativeAuthService;

  late final StreamController<SessionData> _connectionController =
      StreamController<SessionData>.broadcast();
  Stream<SessionData> get connectionStream => _connectionController.stream;

  late final StreamController<void> _disconnectController =
      StreamController<void>.broadcast();
  Stream<void> get disconnectStream => _disconnectController.stream;

  WalletConnectionService({
    required this.flavorSettings,
    required this.nativeAuthService,
  });

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
        redirect: Redirect(native: 'myflutterdapp://'),
      ),
    );

    initWsListeners();
  }

  initWsListeners() {
    _connectionController.onListen = () {
      Map<String, SessionData> sessions = signClient.getActiveSessions();
      if (sessions.isNotEmpty) {
        SessionData sessionData = sessions.entries.first.value;
        topic = sessionData.topic;
        _connectionController.add(sessionData);
      }
    };

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

  Future<String> connect() async {
    ConnectResponse resp = await signClient.connect(
      requiredNamespaces: {
        AppConstants.namespace: RequiredNamespace(
          chains: ['${AppConstants.namespace}:${flavorSettings.chainId}'],
          methods: [
            'mvx_signTransaction',
            'mvx_signTransactions',
            'mvx_signMessage',
            'mvx_signNativeAuthToken',
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

  Future<List<Transaction>> requestSignTransactions(
    List<Transaction> transactions,
  ) async {
    try {
      String method = transactions.length > 1
          ? 'mvx_signTransactions'
          : 'mvx_signTransaction';

      Object params = transactions.length > 1
          ? {'transactions': transactions.map((tx) => tx.toJson())}
          : {'transaction': transactions[0].toJson()};

      final dynamic signResponse = await signClient.request(
        chainId: '${AppConstants.namespace}:${flavorSettings.chainId}',
        topic: topic,
        request: SessionRequestParams(
          method: method,
          params: params,
        ),
      );

      List<Transaction> signedTransactions =
          getSignedTransactions(signResponse, transactions);

      return signedTransactions;
    } catch (e) {
      debugPrint(e.toString());
      return List.empty();
    }
  }

  Future<Map<String, String>> requestSignature(String address) async {
    try {
      String token = await nativeAuthService.initialize();
      Object params = {'address': address, 'token': token};

      final dynamic signResponse = await signClient.request(
        chainId: '${AppConstants.namespace}:${flavorSettings.chainId}',
        topic: topic,
        request: SessionRequestParams(
          method: 'mvx_signNativeAuthToken',
          params: params,
        ),
      );

      String signature = signResponse['signature'] ?? '';
      String nativeAuth = nativeAuthService.getToken(address, token, signature);

      return {
        'signature': signResponse['signature'],
        'nativeAuthToken': nativeAuth,
      };
    } catch (e) {
      debugPrint(e.toString());
      return <String, String>{};
    }
  }

  List<Transaction> getSignedTransactions(
    dynamic signResponse,
    List<Transaction> transactions,
  ) {
    List<TransactionResponse> transactionResponses = [];

    if (signResponse is List) {
      transactionResponses = signResponse
          .map<TransactionResponse>(
            (dynamic data) => parseTransactionResponse(data),
          )
          .toList();
    } else {
      transactionResponses.add(parseTransactionResponse(signResponse));
    }

    List<Transaction> signedTransactions = transactionResponses.map((response) {
      return applyTransactionSignature(
        transaction: transactions[transactionResponses.indexOf(response)],
        response: response,
      );
    }).toList();

    return signedTransactions;
  }

  TransactionResponse parseTransactionResponse(dynamic signResponse) {
    if (signResponse == null || signResponse is! Map<String, dynamic>) {
      throw ArgumentError('Invalid sign response format');
    }

    final Map<String, dynamic> responseMap = signResponse;

    return TransactionResponse(
      signature: responseMap['signature'],
      guardian: responseMap['guardian'],
      guardianSignature: responseMap['guardianSignature'],
      options: responseMap['options'],
      version: responseMap['version'],
    );
  }

  bool isConnected() {
    return topic.isNotEmpty;
  }
}
