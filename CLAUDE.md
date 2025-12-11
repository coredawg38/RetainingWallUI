# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter web application for designing retaining walls. Users input wall parameters, see a real-time preview, pay via Stripe, and download engineering PDF documents. Communicates with a C++ backend server (rwcpp) for calculations.

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run development server (web)
flutter run -d chrome

# Code generation (freezed, json_serializable) - required after model changes
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs

# Run analyzer
flutter analyze

# Run all tests
flutter test

# Run single test file
flutter test test/widget_test.dart
```

## Architecture

### Technology Stack
- **State Management**: flutter_riverpod
- **Routing**: go_router (see `lib/app/router.dart` for routes)
- **Code Generation**: freezed + json_serializable for immutable models
- **HTTP Client**: http package
- **Payments**: flutter_stripe / flutter_stripe_web

### Directory Structure
```
lib/
├── app/           # Router configuration
├── core/          # Shared infrastructure
│   ├── api/       # ApiClient for backend communication
│   ├── constants/ # App-wide constants, enums, pricing
│   ├── services/  # Stripe service
│   └── theme/     # Material 3 theme
├── features/      # Feature modules (Clean Architecture pattern)
│   ├── delivery/      # PDF download after payment
│   ├── information/   # Landing page
│   ├── payment/       # Stripe payment flow
│   └── wall_input/    # Wall design wizard
│       ├── data/      # Models (freezed), repositories
│       ├── domain/    # Validators
│       ├── presentation/  # Pages, widgets
│       └── providers/     # Riverpod providers
└── shared/        # Reusable widgets
```

### Routes
- `/` - Landing/information page
- `/design` - Wall design wizard with preview
- `/payment` - Stripe payment processing
- `/delivery/:requestId` - PDF download page

### Backend Integration

API base URL: `http://localhost:8001/retainingwall` (configured in `lib/core/constants/app_constants.dart`)

**Endpoints:**
- `POST /api/v1/design` - Submit wall design, returns requestId
- `GET /api/v1/status/{requestId}` - Check design processing status
- `GET /files/{requestId}/{filename}` - Download generated PDFs
- `GET /health` - Server health check
- `POST /api/v1/create-payment-intent` - Create Stripe payment intent

### Wall Parameters Schema

Defined in `lib/features/wall_input/data/models/retaining_wall_input.dart`:
- `height`: 24-144 inches
- `material`: 0=concrete, 1=CMU
- `surcharge`: 0=flat, 1=1:1, 2=1:2, 4=1:4 slope
- `optimization_parameter`: 0=excavation, 1=footing
- `soil_stiffness`: 0=stiff, 1=soft
- `topping`: 0-24 inches
- `has_slab`: boolean
- `toe`: 0-120 inches
- `site_address`: {street, City, State, "Zip Code"}
- `customer_info`: {name, email, phone, mailing_address}

Note: JSON keys have specific capitalization to match server schema (e.g., "City", "State", "Zip Code").

### Code Generation

Models with `@freezed` annotations require regeneration after changes:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files: `*.g.dart` (json_serializable), `*.freezed.dart` (freezed)

### Pricing Tiers (in `app_constants.dart`)
- Under 4 ft: $49.99
- 4-8 ft: $99.99
- Over 8 ft: $149.99
