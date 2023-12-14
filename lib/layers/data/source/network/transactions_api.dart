import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertemplate/core/models/transaction.dart';
import 'package:fluttertemplate/flavor_settings.dart';
import 'package:fluttertemplate/layers/data/dto/transaction_on_network_dto.dart';
import 'dart:developer' as developer;

abstract class TransactionsApi {
  Future<List<TransactionOnNetworkDto>> getTransactions(List<String> hashes);
  Future<List<String>> sendTransactions(List<Transaction> transactions);
}

class TransactionsApiImpl implements TransactionsApi {
  final Dio dio;
  final FlavorSettings flavorSettings;

  const TransactionsApiImpl({required this.dio, required this.flavorSettings});

  @override
  Future<List<TransactionOnNetworkDto>> getTransactions(
    List<String> hashes,
  ) async {
    try {
      Response<dynamic> response = await dio.get(
          '${flavorSettings.apiUrl}/transactions',
          queryParameters: {'hashes': hashes.join(',')});

      final l = (response.data as List)
          .map((e) => TransactionOnNetworkDto.fromMap(e))
          .toList();
      return l;
    } catch (e) {
      developer.log(e.toString());
      return [];
    }
  }

  @override
  Future<List<String>> sendTransactions(
    List<Transaction> transactions,
  ) async {
    try {
      Response<dynamic> response = await dio.post(
        '${flavorSettings.apiUrl}/transaction/send-multiple',
        data: jsonEncode(transactions),
      );

      Map<String, dynamic> responseData = response.data['data'];
      Map<String, dynamic> txsHashesMap = responseData['txsHashes'];

      List<String> txsHashes = txsHashesMap.isNotEmpty
          ? txsHashesMap.values.cast<String>().toList()
          : [];

      return txsHashes;
    } catch (e) {
      developer.log(e.toString());
      return [];
    }
  }
}
