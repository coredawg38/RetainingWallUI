# Wall Input Feature Documentation

The wall input feature is a multi-step wizard that guides users through designing a retaining wall, collecting payment, and receiving engineering documents.

## Directory Structure

```
lib/features/wall_input/
├── data/
│   ├── models/
│   │   └── retaining_wall_input.dart    # Freezed models
│   └── repositories/
│       └── wall_repository.dart         # API abstraction layer
├── domain/
│   └── validators/
│       └── wall_input_validator.dart    # JSON schema validation
├── presentation/
│   ├── pages/
│   │   └── wall_input_page.dart         # Main wizard page
│   └── widgets/
│       ├── wall_form.dart               # Wall parameters form
│       ├── wall_preview.dart            # Real-time visualization
│       ├── address_form.dart            # Address input
│       └── customer_form.dart           # Customer info form
└── providers/
    └── wall_input_provider.dart         # Riverpod state management
```

---

## Data Models

### RetainingWallInput

The main model representing a complete wall design specification.

| Field | Type | Range/Values | Default | Description |
|-------|------|--------------|---------|-------------|
| `height` | double | 24-144 inches | 48 | Wall height |
| `toe` | int | 0-120 inches | 12 | Toe length |
| `material` | int | 0=concrete, 1=CMU | 1 | Wall material |
| `surcharge` | int | 0=flat, 1=1:1, 2=1:2, 4=1:4 | 0 | Slope condition |
| `soilStiffness` | int | 0=stiff, 1=soft | 0 | Soil type |
| `topping` | int | 0-24 inches | 2 | Topsoil thickness |
| `optimizationParameter` | int | 0=excavation, 1=footing | 0 | Design optimization |
| `hasSlab` | bool | true/false | false | Whether wall has slab |
| `siteAddress` | Address | - | - | Construction location |
| `customerInfo` | CustomerInfo | - | - | Contact details |

**Computed Properties:**
- `heightInFeet` - Height converted to feet
- `price` - Calculated price based on height tier
- `priceTierDescription` - Human-readable tier label
- `isValid` - Complete validation check

### Address

| Field | Type | JSON Key | Description |
|-------|------|----------|-------------|
| `street` | String | "street" | Street address |
| `city` | String | "City" | City name |
| `state` | String | "State" | 2-letter state code |
| `zipCode` | int | "Zip Code" | ZIP code |

### CustomerInfo

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Full name |
| `email` | String | Email address |
| `phone` | String | Phone number (10-11 digits) |

---

## Wizard Steps

The wall input page implements a 4-step wizard:

### Step 1: Parameters
- **Component:** `WallForm` + `AddressForm`
- **Input:** Wall dimensions, material, site conditions
- **Validation:** All wall parameters and site address required
- **Proceed when:** `hasValidWallParameters && hasValidSiteAddress`

### Step 2: Customer Info
- **Component:** `CustomerForm`
- **Input:** Name, email, phone
- **Validation:** All fields required, email/phone format checked
- **Proceed when:** `hasValidCustomerInfo`

### Step 3: Payment
- **Component:** Order summary + Stripe card input
- **Flow:** Payment → submitDesign() → advance to Step 4
- **Integration:** Stripe CardField (web) / Payment Sheet (mobile)

### Step 4: Delivery
- **Component:** Success message with download options
- **Actions:** Download Preview PDF, Download Detailed PDF, Go to Downloads
- **Navigation:** Links to `/delivery/{requestId}`

---

## State Management

### WallInputState

```dart
class WallInputState {
  final RetainingWallInput input;        // Current form data
  final WizardStep currentStep;          // Active wizard step
  final bool isSubmitting;               // Submission in progress
  final DesignResponse? lastResponse;    // API response
  final List<String> validationErrors;   // Validation errors
  final String? errorMessage;            // Error message
}
```

### WallInputNotifier

**Wall Parameter Methods:**
- `updateHeight(double)` - Update wall height
- `updateToe(int)` - Update toe length
- `updateMaterial(int)` - Update material type
- `updateSurcharge(int)` - Update slope condition
- `updateSoilStiffness(int)` - Update soil type
- `updateTopping(int)` - Update topsoil thickness
- `updateOptimizationParameter(int)` - Update optimization
- `updateHasSlab(bool)` - Toggle slab

**Address Methods:**
- `updateSiteStreet(String)`
- `updateSiteCity(String)`
- `updateSiteState(String)`
- `updateSiteZipCode(int)`

**Customer Methods:**
- `updateCustomerName(String)`
- `updateCustomerEmail(String)`
- `updateCustomerPhone(String)`

**Navigation Methods:**
- `nextStep()` - Advance wizard (validates first)
- `previousStep()` - Go back one step
- `goToStep(WizardStep)` - Jump to specific step

**Action Methods:**
- `validate()` - Run full validation
- `submitDesign()` - Submit to backend API
- `reset()` - Reset to initial state
- `clearError()` - Clear error message

### Providers

```dart
// Main provider
final wallInputProvider = NotifierProvider<WallInputNotifier, WallInputState>()

// Selector providers for granular rebuilds
final currentWallInputProvider       // RetainingWallInput
final currentWizardStepProvider      // WizardStep
final wallPriceProvider              // double
final isSubmittingProvider           // bool
final lastDesignResponseProvider     // DesignResponse?
```

---

## Validation

### WallInputValidator

Uses JSON Schema validation matching the backend server expectations.

**Validation Rules:**
- Height: 24-144 inches
- Material: 0 or 1
- Surcharge: 0, 1, 2, or 4
- Optimization: 0 or 1
- Soil stiffness: 0 or 1
- Topping: 0-24 inches
- Toe: 0-120 inches
- Email: Regex pattern validation
- Phone: 10-11 digits

**Methods:**
- `validate(RetainingWallInput)` - Full validation, returns `ValidationResult`
- `validateField(String field, dynamic value)` - Single field validation

---

## Wall Preview

### WallPreview Widget

Real-time custom-painted visualization of the wall design.

**Visual Elements:**
- Ground line (tan/earth color)
- Footing (based on material color)
- Wall structure (main rectangle)
- Slab (if enabled)
- Topping layer (if set)
- Surcharge slope (diagonal fill showing angle)
- Dimension lines with labels
- Material label ("CMU" or "CONCRETE")

**Slope Visualization:**
| Surcharge | Slope Angle |
|-----------|-------------|
| 0 | Flat (no slope) |
| 1 | 1:1 (45 degrees) |
| 2 | 1:2 (half rise) |
| 4 | 1:4 (quarter rise) |

**Scaling:**
- 144" max height maps to 70% of canvas height
- All dimensions scale proportionally
- Uses `LayoutBuilder` for responsive sizing

---

## Form Widgets

### WallForm

Organized in sections:
1. **Wall Dimensions** - Height slider, toe input
2. **Material & Construction** - Material dropdown, slab toggle
3. **Site Conditions** - Surcharge, soil stiffness, topping
4. **Design Optimization** - Optimization parameter dropdown

### AddressForm

- Street text field
- City text field
- State searchable dropdown (all 50 US states)
- ZIP code numeric field

### CustomerForm

- Name text field
- Email text field (format validation)
- Phone text field (auto-formats to (XXX) XXX-XXXX)

---

## API Integration

### Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v1/design` | POST | Submit wall design |
| `/api/v1/status/{requestId}` | GET | Check processing status |
| `/files/{requestId}/{filename}` | GET | Download generated PDFs |

### WallRepository

Abstraction layer with caching:
- `submitDesign(RetainingWallInput)` - Submit design, returns `DesignResponse`
- `getDesignStatus(String requestId)` - Check status
- `getFileUrl(requestId, filename)` - Construct download URL
- `downloadPreviewPdf()` / `downloadDetailedPdf()` - Binary downloads

---

## Pricing

| Height | Price |
|--------|-------|
| Under 4 ft | $49.99 |
| 4-8 ft | $99.99 |
| Over 8 ft | $149.99 |

Calculated via `PricingTiers.calculatePrice(heightInches)` in `app_constants.dart`.

---

## Responsive Layout

### Desktop
- Side-by-side layout (60% preview, 40% form)
- Vertical divider between panels
- Full preview always visible

### Mobile
- Tabbed interface ("Design" and "Preview" tabs)
- Form and preview in separate tabs
- Touch-friendly spacing and inputs

---

## Data Flow

```
User Input
    ↓
Form Widget (WallForm, AddressForm, CustomerForm)
    ↓
Provider Method (e.g., updateHeight)
    ↓
WallInputNotifier.state = state.copyWith(...)
    ↓
UI Rebuilds (via Riverpod watch)
    ↓
WallPreview updates visualization
```

**Submission Flow:**
```
Payment Success
    ↓
wallInputProvider.submitDesign()
    ↓
WallInputValidator.validate()
    ↓
ApiClient.submitDesign(input.toJson())
    ↓
Backend returns {success, requestId}
    ↓
State updated with lastResponse
    ↓
Wizard advances to Step 4
```

---

## Key Files Reference

| File | Line | Purpose |
|------|------|---------|
| `wall_input_page.dart` | 1-450 | Main wizard page and layout |
| `wall_input_provider.dart` | 1-300 | State management |
| `retaining_wall_input.dart` | 1-200 | Data models |
| `wall_preview.dart` | 1-350 | Custom paint visualization |
| `wall_form.dart` | 1-250 | Parameter input form |
| `wall_input_validator.dart` | 1-150 | JSON schema validation |