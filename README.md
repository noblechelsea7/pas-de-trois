# Pas de Trois — Korean Proxy Shopping Platform

A full-stack Flutter application for Korean proxy shopping (代購), featuring a buyer-facing storefront and a complete admin panel.

## Tech Stack

- Flutter 3.x + Dart
- Riverpod 2.0 (state management)
- go_router (navigation)
- Supabase (backend + auth + database)

## Features

### Buyer Side

- Product catalog with category filtering
- Shopping cart & checkout flow
- Order tracking with 6 status stages
- Member profile & address management
- Wishlist

### Admin Panel

- Dashboard with live statistics
- Order management & status updates
- Product management (add / edit / toggle)
- Member management (block / admin toggle)
- System settings (exchange rate, shipping fees, announcement)

## Architecture

MVVM + Clean Architecture + Feature-first modularization

## Getting Started

1. Clone the repo
2. Copy `env.example` to `.env.json` and fill in your Supabase credentials
3. Run `flutter pub get`
4. Run `flutter run --dart-define-from-file=.env.json`
