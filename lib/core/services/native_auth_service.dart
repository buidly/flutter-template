import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertemplate/core/constants/app_constants.dart';
import 'package:fluttertemplate/flavor_settings.dart';

class NativeAuthService {
  late final FlavorSettings flavorSettings;
  late final Dio dio;

  NativeAuthService({required this.flavorSettings, required this.dio});

  Future<String> initialize() async {
    final Map<String, String> response = await getLatestBlockHash(
      flavorSettings.apiUrl,
    );

    String hash = response['hash'] ?? '';
    String timestamp = response['timestamp'] ?? '';

    final Map<String, dynamic> extraInfo = {
      'timestamp': timestamp.toString(),
    };

    final String encodedExtraInfo = encodeValue(jsonEncode(extraInfo));
    final String encodedOrigin = encodeValue(AppConstants.origin);

    return '$encodedOrigin.$hash.${AppConstants.nativeAuthExpirySeconds}.$encodedExtraInfo';
  }

  Future<Map<String, String>> getLatestBlockHash(
    String apiAddress,
  ) async {
    try {
      Response<List<dynamic>> response = await dio.get(
          '${flavorSettings.apiUrl}/blocks?from=4&size=1&fields=hash,timestamp');

      List responseData = response.data ?? [];
      if (responseData.isNotEmpty) {
        Map<String, dynamic> firstItem = responseData.first;
        return {
          'hash': firstItem['hash'].toString(),
          'timestamp': firstItem['timestamp'].toString(),
        };
      }

      return <String, String>{};
    } catch (e) {
      debugPrint(e.toString());
      return <String, String>{};
    }
  }

  String encodeValue(String str) {
    return escape(base64Url.encode(utf8.encode(str)));
  }

  String escape(String str) {
    return str.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
  }

  String getToken(String address, String token, String signature) {
    final String encodedAddress = encodeValue(address);
    final String encodedToken = encodeValue(token);

    final String accessToken = '$encodedAddress.$encodedToken.$signature';
    return accessToken;
  }
}
