import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertemplate/core/constants/app_constants.dart';
import 'package:fluttertemplate/core/models/transaction.dart';
import 'package:fluttertemplate/layers/data/dto/transaction_on_network_dto.dart';
import 'dart:developer' as developer;

abstract class TransactionsApi {
  Future<List<TransactionOnNetworkDto>> getTransactions(List<String> hashes);
  Future<List<String>> sendTransactions(List<Transaction> transactions);
}

class TransactionsApiImpl implements TransactionsApi {
  final Dio _dio;

  TransactionsApiImpl({
    required Dio dio,
  }) : _dio = dio;

  @override
  Future<List<TransactionOnNetworkDto>> getTransactions(
    List<String> hashes,
  ) async {
    try {
      Response<dynamic> response = await _dio.get(
          '${AppConstants.api}/transactions',
          queryParameters: {'hashes': hashes.join(',')});
      print(response.data);
      final l = (response.data as List)
          .map((e) => TransactionOnNetworkDto.fromMap(e))
          .toList();
      return l;
    } catch (e) {
      print(e);
      developer.log(e.toString());
      return [];
    }
  }

  @override
  Future<List<String>> sendTransactions(
    List<Transaction> transactions,
  ) async {
    try {
      print('call api');
      Response<dynamic> response = await _dio.post(
        '${AppConstants.api}/transaction/send-multiple',
        data: jsonEncode(transactions),
      );

      Map<String, dynamic> responseData = response.data['data'];
      Map<String, dynamic> txsHashesMap = responseData['txsHashes'];

      List<String> txsHashes = txsHashesMap.isNotEmpty
          ? txsHashesMap.values.cast<String>().toList()
          : [];

//{"data":{"numOfSentTxs":0,"txsHashes":{}},"code":"successful"}
      print(txsHashes);
      return txsHashes;
    } catch (e) {
      print(e);
      developer.log(e.toString());
      return [];
    }
  }
}
