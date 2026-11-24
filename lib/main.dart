import 'package:flutter/material.dart';

import 'screens/crypto_ticker_screen.dart';

void main() {
  runApp(const CryptoTickerApp());
}

class CryptoTickerApp extends StatelessWidget {
  const CryptoTickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF080B14);
    const Color orange = Color(0xFFF7931A);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Ticker',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          brightness: Brightness.dark,
          surface: const Color(0xFF121827),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF121827),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        useMaterial3: true,
      ),
      home: const CryptoTickerScreen(),
    );
  }
}
