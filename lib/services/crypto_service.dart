import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import '../models/crypto_price.dart';

class CryptoService {
  static const String _apiKey = String.fromEnvironment('CMC_API_KEY');

  static final Uri _endpoint = Uri.https(
    'pro-api.coinmarketcap.com',
    '/v2/simple/price',
    {'symbol': 'BTC', 'include_all': 'true'},
  );

  static const Duration _timeout = Duration(seconds: 5);

  Future<CryptoPrice> fetchBitcoinPrice() async {
    final HttpClient client = HttpClient();
    final Stopwatch stopwatch = Stopwatch()..start();

    developer.log(
      'Starting the bitcoin price fetch request',
      name: 'CryptoService',
    );

    try {
      if (_apiKey.isEmpty) {
        throw const HttpException(
          'The CoinMarketCap API key was not provided.',
        );
      }

      final HttpClientRequest request = await client
          .getUrl(_endpoint)
          .timeout(_timeout);

      request.headers.set('X-CMC_PRO_API_KEY', _apiKey);

      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      developer.log(
        'Get request prepared: ${_endpoint.path}',
        name: 'CryptoService',
      );

      final HttpClientResponse response = await request.close().timeout(
        _timeout,
      );

      developer.log(
        'Request received: HTTP ${response.statusCode}',
        name: 'CryptoService',
      );

      final String responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(_timeout);

      _validateStatusCode(response.statusCode);

      final dynamic decodedJson = jsonDecode(responseBody);

      if (decodedJson is! Map<String, dynamic>) {
        throw const FormatException('The API response is not a JSON object.');
      }

      final dynamic data = decodedJson['data'];

      if (data is! List || data.isEmpty) {
        throw const FormatException(
          'The API response contains no cryptocurrency data.',
        );
      }

      final dynamic bitcoinJson = data.first;

      if (bitcoinJson is! Map<String, dynamic>) {
        throw const FormatException(
          'The cryptocurrency data has an invalid format.',
        );
      }
      final CryptoPrice price = CryptoPrice.fromJson(bitcoinJson);

      developer.log(
        'Crypto price Bitcoin is parsed successfully: '
        '\$${price.price.toStringAsFixed(2)}',
        name: 'CryptoService',
      );

      return price;
    } catch (error, stackTrace) {
      developer.log(
        'Bitcoin price request failed',
        name: 'CryptoService',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      stopwatch.stop();
      client.close(force: true);

      developer.log(
        'HTTP client closed after '
        '${stopwatch.elapsedMilliseconds} ms',
        name: 'CryptoService',
      );
    }
  }

  void _validateStatusCode(int statusCode) {
    if (statusCode == HttpStatus.ok) {
      return;
    }

    switch (statusCode) {
      case HttpStatus.unauthorized:
        throw HttpException(
          'The cryptocurrency service rejected the request.',
          uri: _endpoint,
        );

      case HttpStatus.forbidden:
        throw HttpException(
          'Access to the cryptocurrency service was denied.',
          uri: _endpoint,
        );

      case HttpStatus.tooManyRequests:
        throw HttpException(
          'The API rate limit was reached. Please try again later.',
          uri: _endpoint,
        );

      case HttpStatus.internalServerError:
      case HttpStatus.badGateway:
      case HttpStatus.serviceUnavailable:
      case HttpStatus.gatewayTimeout:
        throw HttpException(
          'The cryptocurrency server is temporarily unavailable.',
          uri: _endpoint,
        );

      default:
        throw HttpException(
          'The request failed with status $statusCode.',
          uri: _endpoint,
        );
    }
  }
}
