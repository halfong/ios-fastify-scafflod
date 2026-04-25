# iOS + Fastify Scaffold Template

A **GitHub Template repository** for building a full-stack mobile application with a SwiftUI iOS client and a Fastify (Node.js/TypeScript) server.

## Stack

| Layer | Technology |
|-------|-----------|
| iOS client | SwiftUI, Swift 5.9+, iOS 17+ |
| Server | Node.js 18+, Fastify 4, TypeScript 5 |
| API contract | OpenAPI 3.1 (YAML) |
| Scaffold | Node.js ESM script (`scripts/scaffold.mjs`) |

## Monorepo layout

```
.
├── ios/
│   ├── App/
│   │   ├── Sources/          # Swift source files
│   │   │   ├── App.swift           # @main entry
│   │   │   ├── AppConfig.swift     # API base URL config
│   │   │   ├── APIClient.swift     # HTTP client
│   │   │   ├── ContentView.swift   # Root view
│   │   │   └── ExampleViewModel.swift
│   │   ├── Tests/
│   │   ├── Configuration/
│   │   │   ├── Base.xcconfig       # PRODUCT_NAME, PRODUCT_BUNDLE_IDENTIFIER
│   │   │   ├── Debug.xcconfig
│   │   │   └── Release.xcconfig
│   │   └── Info.plist
│   └── Package.swift
├── server/
│   ├── src/
│   │   ├── index.ts                # Fastify entry
│   │   ├── config/env.ts           # Environment config
│   │   ├── routes/
│   │   │   ├── health.ts
│   │   │   └── example.ts
│   │   ├── types/api.ts            # Shared API types
│   │   └── tests/
│   ├── package.json
│   ├── tsconfig.json
│   └── .env.example
├── shared/
│   └── openapi/
│       └── openapi.yaml            # Single source of truth for API contract
├── scripts/
│   └── scaffold.mjs                # Interactive scaffolding script
├── .env.example
├── .gitignore
└── package.json
```

---

## 🚀 Quick start (using this template)

### 1. Create your repo from this template

Click the **"Use this template"** button at the top of this page, or use the GitHub CLI:

```bash
gh repo create my-app --template halfong/ios-fastify-scafflod --private --clone
cd my-app
```

### 2. Install scaffold dependencies

```bash
npm install
```

### 3. Run the scaffold script

```bash
npm run scaffold
```

The script will prompt you for:

| Prompt | Token replaced | Example |
|--------|---------------|---------|
| iOS app display name | `__APP_NAME__` | `MyApp` |
| iOS bundle identifier | `__BUNDLE_ID__` | `com.example.myapp` |
| Server npm package name | `__SERVER_NAME__` | `my-api-server` |
| Server port | `__SERVER_PORT__` | `3000` |
| API base URL (iOS client) | `__API_BASE_URL__` | `http://localhost:3000` |

Tokens are replaced across all text files in `ios/`, `server/`, `shared/`, and root config files. A `.scaffolded` marker is written to prevent accidental re-runs.

To force re-scaffold an already-scaffolded repo:

```bash
npm run scaffold -- --force
```

---

## 🖥️ Running the server

```bash
# Install server dependencies
cd server && npm install

# Copy and edit env file
cp .env.example .env

# Start in development mode (watch)
npm run dev

# OR from repo root
npm run server:dev
```

The server runs on `http://localhost:__SERVER_PORT__` by default.

Available endpoints:

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/api/v1/examples` | List example items |
| GET | `/api/v1/examples/:id` | Get a single item |

### Server commands

```bash
npm run dev        # tsx watch (hot reload)
npm run build      # tsc compile to dist/
npm start          # run compiled dist/index.js
npm run typecheck  # TypeScript type check (no emit)
npm run lint       # ESLint
npm run test       # Vitest unit tests
```

---

## 📱 Running the iOS app

### Prerequisites

- Xcode 15+ (iOS 17 SDK)
- macOS Ventura or later

### Steps

1. Make sure the server is running (see above)
2. Open the project in Xcode:
   ```bash
   open ios/App/App.xcodeproj
   ```
   Or if using Swift Package Manager directly:
   ```bash
   open ios/Package.swift
   ```
3. Select a simulator or device and press **⌘R** to run

### Configuration

The iOS app reads its API base URL from `ios/App/Sources/AppConfig.swift`:

```swift
enum AppConfig {
    static let apiBaseURL: String = "http://localhost:3000"
}
```

After scaffolding, this will already contain the URL you provided. Update it manually if the server address changes.

Build settings (display name, bundle ID) are configured via xcconfig:

- `ios/App/Configuration/Base.xcconfig`

---

## 🔧 Environment variables (server)

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | TCP port to listen on |
| `NODE_ENV` | `development` | Runtime environment |
| `LOG_LEVEL` | `info` | Fastify logger level |

Copy `server/.env.example` to `server/.env` and adjust as needed. **Never commit `.env` files with real secrets.**

---

## 📋 API Contract

The OpenAPI 3.1 spec lives in `shared/openapi/openapi.yaml` and is the single source of truth for both server routes and iOS client models.

To generate TypeScript types from the spec:

```bash
npx openapi-typescript shared/openapi/openapi.yaml -o server/src/types/openapi.d.ts
```

---

## 🏗️ Adding new features

1. Define the route in `shared/openapi/openapi.yaml`
2. Add the TypeScript type to `server/src/types/api.ts`
3. Implement the route in `server/src/routes/`
4. Add the corresponding Swift model and API call in `ios/App/Sources/`

---

## 📄 License

MIT
