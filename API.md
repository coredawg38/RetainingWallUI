# Backend API Documentation

This document describes the backend API endpoints required by the Retaining Wall Builder web application.

## Base URL

Default: `http://orca.local:8001/retainingwall`

Configure via: `--dart-define=API_BASE_URL=https://your-server.com/retainingwall`

## Endpoints

### Health Check

```
GET /health
```

Returns server health status.

**Response:**
```json
{
  "status": "ok"
}
```

---

### Submit Design

```
POST /api/v1/design
Content-Type: application/json
```

Submits a retaining wall design for processing.

**Request Body:**
```json
{
  "height": 96.0,
  "material": 1,
  "surcharge": 0,
  "optimization_parameter": 0,
  "soil_stiffness": 0,
  "topping": 2,
  "has_slab": false,
  "toe": 12,
  "site_address": {
    "street": "123 Main St",
    "City": "Salt Lake City",
    "State": "UT",
    "Zip Code": 84101
  },
  "customer_info": {
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "(555) 123-4567",
    "mailing_address": {
      "street": "",
      "City": "",
      "State": "",
      "Zip Code": 0
    }
  }
}
```

**Field Definitions:**

| Field | Type | Values | Description |
|-------|------|--------|-------------|
| `height` | number | 24-144 | Wall height in inches |
| `material` | int | 0, 1 | 0=concrete, 1=CMU |
| `surcharge` | int | 0, 1, 2, 4 | 0=flat, 1=1:1, 2=1:2, 4=1:4 slope |
| `optimization_parameter` | int | 0, 1 | 0=excavation, 1=footing |
| `soil_stiffness` | int | 0, 1 | 0=stiff, 1=soft |
| `topping` | int | 0-24 | Topsoil thickness in inches |
| `has_slab` | bool | true/false | Whether wall has a slab |
| `toe` | int | 0-120 | Toe length in inches |

**Response (Success):**
```json
{
  "success": true,
  "request_id": "uuid-string",
  "message": "Design submitted successfully"
}
```

**Response (Error):**
```json
{
  "success": false,
  "error_message": "Description of error"
}
```

---

### Check Design Status

```
GET /api/v1/status/{requestId}
```

Checks the processing status of a submitted design.

**Response:**
```json
{
  "request_id": "uuid-string",
  "status": "completed",
  "files": ["PreviewDrawing.pdf", "DetailedDrawing.pdf"]
}
```

Status values: `pending`, `processing`, `completed`, `failed`

---

### Download File

```
GET /files/{requestId}/{filename}
```

Downloads a generated PDF file.

**Example:**
```
GET /files/abc123/PreviewDrawing.pdf
```

**Response:** Binary PDF file

**Available Files:**
- `PreviewDrawing.pdf` - Quick overview drawing
- `DetailedDrawing.pdf` - Full construction specifications

---

### Create Payment Intent (Stripe)

```
POST /api/v1/create-payment-intent
Content-Type: application/json
```

Creates a Stripe payment intent for processing payment.

**Request Body:**
```json
{
  "amount": 9999,
  "currency": "usd",
  "email": "customer@example.com",
  "metadata": {
    "request_id": "uuid-string"
  }
}
```

Note: `amount` is in cents (9999 = $99.99)

**Response:**
```json
{
  "clientSecret": "pi_xxx_secret_xxx",
  "paymentIntentId": "pi_xxx",
  "amount": 9999,
  "currency": "usd"
}
```

---

### Send Email (Optional)

```
POST /api/v1/send-email
Content-Type: application/json
```

Sends design documents to customer via email.

**Request Body:**
```json
{
  "request_id": "uuid-string",
  "email": "customer@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Email sent successfully"
}
```

---

## Error Handling

All endpoints return errors in this format:

```json
{
  "success": false,
  "error_message": "Human-readable error description"
}
```

HTTP status codes:
- `200` - Success
- `400` - Bad request (invalid input)
- `404` - Resource not found
- `500` - Server error

---

## CORS

The backend must allow CORS requests from the web application origin.

Required headers:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
```
