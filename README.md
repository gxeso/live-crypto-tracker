# Live Crypto Tracker

A Flutter application that retrieves and displays live cryptocurrency prices through the CoinMarketCap API. The project focuses on reliable API communication, lifecycle-safe refreshing, structured error handling, and performance monitoring.

## Features

- Live cryptocurrency price retrieval
- Pull-to-refresh support
- Automatic timed updates
- Loading, success, and error states
- Network and API error handling
- Lifecycle-safe timer management
- Structured JSON parsing
- Responsive Flutter interface

## Architecture

The application separates its responsibilities into:

- **Models** — convert API responses into structured Dart objects
- **Service layer** — handles CoinMarketCap API communication
- **Presentation layer** — displays prices and application states
- **Lifecycle management** — safely manages refresh timers and asynchronous updates

## Technologies

- Flutter
- Dart
- CoinMarketCap API
- HTTP networking
- Flutter DevTools

## API Configuration

The CoinMarketCap API key is not stored in this repository. Supply it at runtime using a Dart environment variable:

```bash
flutter run --dart-define=CMC_API_KEY=YOUR_API_KEY
```

## Getting Started

```bash
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=CMC_API_KEY=YOUR_API_KEY
```

## What I Learned

This project strengthened my understanding of asynchronous execution, REST API integration, JSON parsing, error propagation, widget lifecycle safety, timer disposal, and memory profiling with Flutter DevTools.
