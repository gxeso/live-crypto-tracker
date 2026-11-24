class CryptoPrice {
  final int id;
  final String name;
  final String symbol;
  final double price;
  final double percentChange24h;
  final double marketCap;
  final double volume24h;
  final DateTime lastUpdated;

  const CryptoPrice({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.percentChange24h,
    required this.marketCap,
    required this.volume24h,
    required this.lastUpdated,
  });

  factory CryptoPrice.fromJson(Map<String, dynamic> json) {
    final dynamic rawQuotes = json['quotes'];

    if (rawQuotes is! List || rawQuotes.isEmpty) {
      throw const FormatException('The cryptocurrency contains no quote data.');
    }

    final dynamic rawQuote = rawQuotes.first;

    if (rawQuote is! Map<String, dynamic>) {
      throw const FormatException(
        'The cryptocurrency quote has an invalid format.',
      );
    }

    final Map<String, dynamic> quote = rawQuote;

    return CryptoPrice(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      price: (quote['price'] as num).toDouble(),
      percentChange24h: (quote['percent_change_24h'] as num).toDouble(),
      marketCap: (quote['market_cap'] as num).toDouble(),
      volume24h: (quote['volume_24h'] as num).toDouble(),
      lastUpdated: DateTime.parse(quote['last_updated'] as String),
    );
  }
}
