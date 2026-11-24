import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../models/crypto_price.dart';
import '../services/crypto_service.dart';

class CryptoTickerScreen extends StatefulWidget {
  const CryptoTickerScreen({super.key});

  @override
  State<CryptoTickerScreen> createState() => _CryptoTickerScreenState();
}

class _CryptoTickerScreenState extends State<CryptoTickerScreen> {
  static const Color _background = Color(0xFF080B14);
  static const Color _surface = Color(0xFF121827);
  static const Color _surfaceLight = Color(0xFF1A2133);
  static const Color _orange = Color(0xFFF7931A);
  static const Color _green = Color(0xFF25C896);
  static const Color _red = Color(0xFFFF5C6C);
  static const Color _mutedText = Color(0xFF8E98AA);

  final CryptoService _cryptoService = CryptoService();

  CryptoPrice? _cryptoPrice;
  String? _errorMessage;
  Timer? _refreshTimer;

  bool _isLoading = true;
  bool _requestInProgress = false;

  @override
  void initState() {
    super.initState();
    developer.log(
      'CryptoTickerScreen has been initialized',
      name: 'CryptoTickerScreen',
    );
    _fetchPrice();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      developer.log(
        'Automatic Refresh timer triggered',
        name: 'CryptoTickerScreen',
      );
      _fetchPrice();
    });
  }

  Future<void> _fetchPrice() async {
    if (_requestInProgress) {
      developer.log(
        'Refresh ignored because a request is already running',
        name: 'CryptoTickerScreen',
      );
      return;
    }

    developer.log('Price refresh started', name: 'CryptoTickerScreen');

    _requestInProgress = true;

    if (mounted) {
      setState(() {
        _isLoading = _cryptoPrice == null;

        _errorMessage = null;
      });
    }

    try {
      final CryptoPrice price = await _cryptoService.fetchBitcoinPrice();

      if (!mounted) {
        developer.log(
          'Result ignored because screen was disposed',
          name: 'CryptoTickerScreen',
        );
        return;
      }

      developer.log(
        'Price refresh completed successfully',
        name: 'CryptoTickerScreen',
      );

      setState(() {
        _cryptoPrice = price;
        _errorMessage = null;
        _isLoading = false;
      });
    } on SocketException {
      _showError('Unable to connect. Check your internet connection.');
    } on TimeoutException {
      _showError('The request took too long. Please try again.');
    } on HttpException catch (error) {
      _showError(error.message);
    } on FormatException {
      _showError('The server returned data in an unexpected format.');
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      _requestInProgress = false;
    }
  }

  void _showError(String message) {
    if (!mounted) {
      developer.log(
        'Error ignored because screen was disposed',
        name: 'CryptoTickerScreen',
      );
      return;
    }

    developer.log(
      'Displaying error state: $message',
      name: 'CryptoTickerScreen',
      level: 900,
    );

    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    developer.log('Disposing CryptoTickerScreen', name: 'CryptoTickerScreen');

    _refreshTimer?.cancel();
    developer.log(
      'Automatic refresh timer cancelled',
      name: 'CryptoTickerScreen',
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 76,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Market', style: TextStyle(color: _mutedText, fontSize: 12)),
            SizedBox(height: 2),
            Text(
              'Crypto Ticker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: const Row(
              children: [
                Icon(Icons.currency_bitcoin, color: _orange, size: 18),
                SizedBox(width: 5),
                Text('BTC', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [Color(0xFF242036), _background],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              RepaintBoundary(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _cryptoPrice == null) {
      return const Center(
        key: ValueKey('loading'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _orange),
            SizedBox(height: 18),
            Text(
              'Fetching live market data...',
              style: TextStyle(color: _mutedText),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_cryptoPrice != null) {
      return _buildSuccessState(_cryptoPrice!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorState() {
    return Center(
      key: const ValueKey('error'),
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, color: _red, size: 34),
            ),
            const SizedBox(height: 20),
            const Text(
              'Connection problem',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _mutedText, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _requestInProgress ? null : _fetchPrice,
              style: FilledButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(CryptoPrice price) {
    final bool isPositive = price.percentChange24h >= 0;

    final Color changeColor = isPositive ? _green : _red;

    final String sign = isPositive ? '+' : '';

    return RefreshIndicator(
      key: const ValueKey('success'),
      color: _orange,
      backgroundColor: _surfaceLight,
      elevation: 0,
      onRefresh: _fetchPrice,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 52,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceCard(price, isPositive, changeColor, sign),
                  const SizedBox(height: 18),
                  const Text(
                    'Market overview',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.pie_chart_rounded,
                          label: 'Market Cap',
                          value: _formatCompactCurrency(price.marketCap),
                          color: const Color(0xFF8B7CFF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.bar_chart_rounded,
                          label: '24h Volume',
                          value: _formatCompactCurrency(price.volume24h),
                          color: const Color(0xFF2BBEFF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildUpdateCard(price),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceCard(
    CryptoPrice price,
    bool isPositive,
    Color changeColor,
    String sign,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C2234), Color(0xFF111624)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: _orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.currency_bitcoin,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${price.symbol} / USD',
                      style: const TextStyle(color: _mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isPositive ? 'BULLISH' : 'BEARISH',
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          const Text(
            'CURRENT PRICE',
            style: TextStyle(
              color: _mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              _formatPrice(price.price),
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: changeColor,
                  size: 19,
                ),
                const SizedBox(width: 6),
                Text(
                  '$sign'
                  '${price.percentChange24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '24h',
                  style: TextStyle(color: _mutedText, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 20),
          Text(label, style: const TextStyle(color: _mutedText, fontSize: 12)),
          const SizedBox(height: 5),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(CryptoPrice price) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sync_rounded, color: _green, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live market data',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  'Updated ${_formatTime(price.lastUpdated)}',
                  style: const TextStyle(color: _mutedText, fontSize: 12),
                ),
              ],
            ),
          ),
          const Text(
            '60s',
            style: TextStyle(
              color: _green,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    final List<String> parts = value.toStringAsFixed(2).split('.');

    final String wholeNumber = parts.first;
    final StringBuffer result = StringBuffer();

    for (int index = 0; index < wholeNumber.length; index++) {
      if (index > 0 && (wholeNumber.length - index) % 3 == 0) {
        result.write(',');
      }

      result.write(wholeNumber[index]);
    }

    return '\$${result.toString()}.${parts.last}';
  }

  String _formatCompactCurrency(double value) {
    if (value >= 1000000000000) {
      return '\$'
          '${(value / 1000000000000).toStringAsFixed(2)}T';
    }

    if (value >= 1000000000) {
      return '\$'
          '${(value / 1000000000).toStringAsFixed(2)}B';
    }

    if (value >= 1000000) {
      return '\$'
          '${(value / 1000000).toStringAsFixed(2)}M';
    }

    return _formatPrice(value);
  }

  String _formatTime(DateTime dateTime) {
    final DateTime localTime = dateTime.toLocal();

    final int hour = localTime.hour == 0
        ? 12
        : localTime.hour > 12
        ? localTime.hour - 12
        : localTime.hour;

    final String minute = localTime.minute.toString().padLeft(2, '0');

    final String second = localTime.second.toString().padLeft(2, '0');

    final String period = localTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute:$second $period';
  }
}
