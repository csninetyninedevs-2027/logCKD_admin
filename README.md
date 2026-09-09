# logCKD Admin Panel

A desktop-first **Flutter Web administration panel** for the logCKD platform. The admin panel gives authorized administrators a centralized view of users, food records, facilities, system health, regional user concentration, and platform analytics.

The interface is designed around a **dark, premium, operational dashboard style** using logCKD's teal visual identity, compact analytics, animated interactions, and persistent navigation.

---

## Project Status

| Step | Module | Status |
|---|---|---|
| 1 | Food Management Backend | ✅ Complete |
| 2 | Food Management Admin UI | ✅ Complete |
| 3 | User Concentration Map | ✅ Complete |
| 4 | System Status | ✅ Complete |
| 5 | Dashboard Expansion / Analytics | ✅ Complete |
| 6 | UI Unification + Interactivity | 🟡 In Progress |
| 7 | Final Admin Enhancements + Polish | ⏳ Pending |

---

## Main Features

### Admin Authentication
- Administrator login
- Access and refresh token handling
- Secure token storage using `flutter_secure_storage`
- Automatic access-token refresh after unauthorized API responses
- Protected routes with `go_router`

### Dashboard & Analytics
- Dashboard summary metrics
- Signup trend analytics
- Demographic analytics
- Risk distribution
- CKD stage breakdown
- Comorbidity prevalence
- Health-status analytics
- Compact, dark-themed chart cards

### User Management
- View registered users
- Open individual user details
- Review user profile and health-related administrative data

### Food Management
- View and manage food entries
- Create and edit food data
- Food status controls
- Bulk food operations and validation
- Numeric input validation for nutrient values

### Facility Management
- View and manage registered facilities
- Coordinate validation for latitude and longitude
- Facility-number validation

### User Concentration Map
- Interactive Philippines-focused map using `flutter_map`
- Dark teal/charcoal map styling
- Regional user concentration markers
- Selectable regional markers
- Pulsing selected markers
- New-user pulse when refreshed regional counts increase
- Zoom, pan, and reset controls
- Responsive selected-region details

### System Status
Monitors the main logCKD services, including:

- Main Backend
- Risk Engine
- Backup Service

The status screen can display service health information such as:

- Service status
- HTTP status
- Response time
- Uptime
- Environment/runtime information
- Endpoint information
- Last checked time

The interface uses an animated request-flow visualization with selectable service nodes and detailed service inspection.

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Admin application UI |
| Dart | Application language |
| Flutter Web | Primary deployment target |
| Riverpod | State management |
| Dio | HTTP/API communication |
| GoRouter | Routing and protected navigation |
| flutter_secure_storage | Admin token storage |
| flutter_dotenv | Environment configuration |
| fl_chart | Dashboard analytics/charts |
| flutter_map | Interactive regional map |
| latlong2 | Geographic coordinates |

---

## Project Structure

```text
lib/
├── main.dart
│
├── core/
│   ├── network/
│   │   ├── api_client.dart
│   │   └── providers.dart
│   ├── router/
│   │   └── app_router.dart
│   └── theme/
│       ├── app_theme.dart
│       └── admin_motion.dart
│
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   └── state/
│   ├── dashboard/
│   │   ├── presentation/
│   │   └── state/
│   ├── users/
│   │   ├── presentation/
│   │   └── state/
│   ├── foods/
│   │   ├── presentation/
│   │   └── state/
│   ├── content/
│   │   ├── presentation/
│   │   └── state/
│   ├── user_map/
│   │   ├── data/
│   │   ├── presentation/
│   │   └── state/
│   └── system_status/
│       ├── presentation/
│       └── state/
│
└── shared/
    ├── models/
    ├── utils/
    └── widgets/
```

---

## Requirements

Before running the project, make sure you have:

- Flutter installed
- Dart included with Flutter
- Google Chrome for Flutter Web development
- Access to the logCKD Admin API

Verify your Flutter installation:

```bash
flutter doctor
```

---

## Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd <project-folder>
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Create the environment file

Create a `.env` file in the project root:

```env
API_BASE_URL=https://logckdbackend-production.up.railway.app/api/admin
```

For local backend development, you can use:

```env
API_BASE_URL=http://localhost:3000/api/admin
```

> The production Railway URL should use HTTPS and should **not** include `:3000`.

The application loads `.env` during startup through `flutter_dotenv`.

### 4. Run the admin panel

```bash
flutter run -d chrome
```

---

## API Integration

The admin panel currently communicates with routes including:

```text
/auth/login
/auth/logout
/auth/me
/auth/refresh

/dashboard/summary
/analytics/demographics
/analytics/risk-distribution
/analytics/signup-trend

/users
/foods
/foods/status
/foods/bulk
/foods/bulk/validate
/facilities
/user-concentration
/system/services
```

The configured `API_BASE_URL` already contains `/api/admin`, so feature requests use paths relative to that base URL.

---

## Authentication Flow

The application stores:

```text
admin_access_token
admin_refresh_token
```

When an authenticated request returns HTTP `401`, the API client attempts to refresh the access token using:

```text
POST /auth/refresh
```

If refresh succeeds, the original request is retried. If refresh fails, stored admin tokens are cleared.

---

## Input Validation

Administrative create/edit forms validate values before submission.

Current food nutrient limits are treated as values **per serving**:

| Nutrient | Accepted Range |
|---|---:|
| Energy | 0–5000 kcal |
| Protein | 0–300 g |
| Carbohydrate | 0–500 g |
| Fat | 0–300 g |
| Sodium | 0–10000 mg |
| Potassium | 0–10000 mg |
| Cholesterol | 0–3000 mg |
| Fiber | 0–100 g |
| Sugar | 0–300 g |

Additional validation includes:

- Latitude: `-90` to `90`
- Longitude: `-180` to `180`
- Facility number: whole number
- Email: valid email format
- Password: minimum/maximum length protection
- Text fields: trimming and sensible length limits
- Numeric fields: numeric/decimal filtering where appropriate

Search fields remain unrestricted text fields.

---

## Design Direction

The current UI direction is intentionally different from generic SaaS admin templates.

### Keep
- Dark interface
- logCKD teal identity
- Soft rounded forms
- Premium spacing
- Dense but readable operational layouts
- Animated interactions
- Compact analytics
- Persistent collapsible sidebar

### Avoid
- Generic white dashboard cards
- Excessive glassmorphism
- Random purple/blue gradients
- Decorative charts without purpose
- Repetitive identical KPI cards
- Excessive glow
- Generic AI dashboard controls

The intended visual balance is approximately:

```text
20% main logCKD visual identity
70% premium dashboard inspiration
10% custom admin identity
```

---

## Map Design Notes

The User Concentration screen is intended to feel like a **real operational map**, not a hand-drawn Philippines illustration.

Current requirements include:

- Real geographic basemap
- Philippines-focused initial view
- Dark teal/charcoal treatment
- Clear geographic edges
- Regional concentration markers
- Minimal visual clutter
- Interactive zoom and pan
- Pulsing selected/new-user markers
- Responsive behavior when the browser is resized

---

## Testing

Before considering a revision complete, run:

```bash
flutter analyze
```

Then launch the web app:

```bash
flutter run -d chrome
```

Recommended areas to test:

```text
Login
- authentication works
- no layout crashes

Sidebar
- persists between routes
- collapsed state does not overflow

Dashboard
- analytics load correctly
- signup ranges return the expected number of months

Users
- user list loads
- user details open correctly

Foods
- create/edit validation works
- invalid nutrient values are rejected

Facilities
- facility information loads
- coordinate validation works

User Concentration
- map loads
- zoom/pan works
- regional markers are selectable
- selected marker pulses
- reset view works
- resizing does not trigger map assertions

System Status
- all services load
- service nodes are selectable
- refresh interaction works
- detailed service information displays correctly
```

---

## Build for Web

To create a production web build:

```bash
flutter build web
```

The generated output will be placed in:

```text
build/web/
```

---

## Development Workflow

For current UI revisions, the preferred workflow is:

1. Work from the latest project files.
2. Make changes module-by-module.
3. Keep backend/business logic untouched unless the task specifically requires logic changes.
4. Run one end-to-end test after each major module/revision.
5. Run `flutter analyze` before final testing.
6. Run the application in Chrome and verify responsive behavior.

---

## Current Development Focus

The project is currently in **Step 6 — UI Unification + Interactivity**.

Primary focus areas:

- User Concentration Map refinement
- Dashboard chart polish
- Consistent premium dark styling
- Animation and interaction refinement
- Responsive desktop behavior
- Final UI consistency across Login, Dashboard, Users, Map, and System Status

After Step 6, the remaining roadmap item is:

```text
Step 7 — Final Admin Enhancements + Polish
```

---

## Project

**logCKD Admin Panel**  
Administrative interface for the logCKD platform.
