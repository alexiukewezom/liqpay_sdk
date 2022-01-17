library liqpay_sdk;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

/// Liqpay Payment Module
///
/// NOTICE OF LICENSE
///
/// This source file is subject to the Open Software License (OSL 3.0)
/// that is available through the world-wide-web at this URL:
/// http://opensource.org/licenses/osl-3.0.php
///
/// @module          liqpay
/// @category        LiqPay
/// @package         engenii.alexiuk/liqpay_sdk
/// @version         0.0.1
/// @author          engenii.alexiuk
/// @copyright       Copyright (c) 2014 Liqpay
/// @license         http://opensource.org/licenses/osl-3.0.php Open Software License (OSL 3.0)
///
/// EXTENSION INFORMATION
///
/// LIQPAY API       https://www.liqpay.ua/documentation/uk
///

class LiqPay {
  final String publicKey;
  final String privateKey;

  /// Creates object with helpers for accessing to Liqpay API

  LiqPay({required this.publicKey, required this.privateKey});

  /// {string} API host
  static const String host = 'https://www.liqpay.ua/api/';

  /// Call API

  Future<dynamic> api({
    required String path,
    required Map<String, dynamic> params,
  }) async {
    if (!params.containsKey('version')) throw Exception('version is mull');

    params['public_key'] = publicKey;
    final data = base64.encode(utf8.encode(json.encode(params)));
    final signature = strToSign(privateKey + data + privateKey);
    final response = await Dio().post(host + path,
        data: FormData.fromMap({
          "data": data,
          "signature": signature,
        }));

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception(response);
    }
  }

  String cnbForm(Map<String, dynamic> params) {
    String language = "ru";

    if (params['language'] != null) language = params['language'];

    params = cnbParams(params);
    final String data = base64.encode(utf8.encode(json.encode(params)));
    final String signature = strToSign(privateKey + data + privateKey);

    return '<form method="POST" action="https://www.liqpay.ua/api/3/checkout" accept-charset="utf-8">' +
        '<input type="hidden" name="data" value="' +
        data +
        '" />' +
        '<input type="hidden" name="signature" value="' +
        signature +
        '" />' +
        '<input type="image" src="//static.liqpay.ua/buttons/p1' +
        language +
        '.radius.png" name="btn_text" />' +
        '</form>';
  }

  String cnbSignature(Map<String, dynamic> params) {
    params = cnbParams(params);
    final String data = base64.encode(utf8.encode(json.encode(params)));
    return strToSign(privateKey + data + privateKey);
  }

  Map<String, dynamic> cnbParams(Map<String, dynamic> params) {
    params['public_key'] = publicKey;

    if (params['version'] == null) throw Exception('version is null');
    if (params['amount'] == null) throw Exception('amount is null');
    if (params['currency'] == null) throw Exception('currency is null');
    if (params['description'] == null) throw Exception('description is null');

    return params;
  }

  String strToSign(String str) {
    return base64.encode(sha1.convert(utf8.encode(str)).bytes);
  }

  Map<String, dynamic> cnbObject(Map<String, dynamic> params) {
    params = cnbParams(params);
    final String data = base64.encode(utf8.encode(json.encode(params)));
    final String signature = strToSign(privateKey + data + privateKey);
    return {'data': data, 'signature': signature};
  }
}
