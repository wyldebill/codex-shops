# Shops Map App

A Flutter application that displays shop locations in Buffalo, MN using interactive maps.

## Features

- 📍 Interactive map showing local shop locations
- 🔍 Search functionality to find specific shops
- 📱 Clean, modern Material 3 UI
- 🗺️ Map powered by MapLibre GL with Slpy.com tiles

## Map Integration

This app uses **MapLibre GL** with **Slpy.com** tile service for map rendering. MapLibre is an open-source mapping library that provides excellent performance and customization options.

## Setup

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- A Slpy.com API key ([Get one here](https://slpy.com))

### API Key Configuration

1. Copy the sample environment file:
   ```bash
   cp .env.sample .env
   ```

2. Add your Slpy API key to `.env`:
   ```
   SLPY_API_KEY=your_actual_key_here
   ```

### Installation

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Migration from Google Maps

This app was recently migrated from Google Maps to MapLibre GL with Slpy. For details about the migration, see [MIGRATION_SUMMARY.md](MIGRATION_SUMMARY.md).

## Getting Started with Flutter

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
