# iOS + Fastify Scaffold

A GitHub Template for full-stack mobile apps: SwiftUI iOS client + Fastify (TypeScript) server.

## Stack

| Layer | Technology |
|-------|-----------|
| iOS client | SwiftUI, Swift 5.9+, iOS 17+ |
| Server | Node.js 18+, Fastify 5, TypeScript 5 |
| ORM | Prisma 6 (MariaDB / MySQL) |
| API contract | OpenAPI 3.1 (YAML) |

## Monorepo layout

```
.
├── ios/
│   └── Sources/              # Swift source files — drag into your Xcode project
│       ├── App.swift               # @main entry point
│       ├── AppConfig.swift         # API base URL (edit directly)
│       ├── APIClient.swift         # HTTP client
│       ├── ContentView.swift       # Root view
│       ├── ExampleViewModel.swift
│       ├── Seed/                   # Reusable UI components & services
│       ├── Services/               # App-specific services
│       └── Views/                  # App screens
├── server/
│   ├── prisma/
│   │   └── schema.prisma           # Prisma schema (User, OAuthAccount, KiviRecord)
│   ├── src/
│   │   ├── index.ts                # Fastify entry
│   │   ├── config/env.ts           # Environment config
│   │   ├── routes/
│   │   ├── types/api.ts            # Shared API types
│   │   └── tests/
│   ├── package.json
│   └── tsconfig.json
├── shared/
│   └── openapi/
│       └── openapi.yaml            # API contract
└── .env.example
```

---

## Server

```bash
cd server
cp ../.env.example .env   # edit values
npm install
npm run dev               # hot reload on :3000
```

| Command | Description |
|---------|-------------|
| `npm run dev` | tsx watch (hot reload) |
| `npm run build` | tsc → dist/ |
| `npm start` | run dist/index.js |
| `npm run typecheck` | type check without emit |
| `npm run lint` | ESLint |
| `npm run test` | Vitest |

### Database (Prisma + MariaDB/MySQL)

```bash
npm run db:push           # push schema (dev, no migration file)
npm run db:migrate        # create + apply named migration
npm run db:migrate:deploy # apply pending migrations (CI/prod)
npm run db:seed           # create default admin user
```

Default models: `User`, `OAuthAccount`, `KiviRecord` (generic key/value store).

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | TCP port |
| `NODE_ENV` | `development` | Runtime environment |
| `DATABASE_URL` | — | MariaDB connection string |
| `API_BASE_URL` | `http://localhost:3000` | Base URL seen by iOS client |

---

## iOS project setup

The iOS code in `ios/Sources/` is plain Swift files — no `.xcodeproj` is committed. Create an Xcode project once and drag the sources in.

**1. Create a new Xcode project**

Xcode → **File → New → Project → iOS → App**

| Field | Value |
|---|---|
| Interface | SwiftUI |
| Language | Swift |

**2. Delete the Xcode-generated entry files**

Xcode auto-generates `[AppName]App.swift` and `ContentView.swift`. Delete them — the template provides its own.

**3. Drag in the Sources folder**

Drag `ios/Sources/` into the Xcode project navigator:
- ✅ Create groups
- ☐ Copy items if needed *(leave unchecked)*

**4. Set your API base URL**

Edit `ios/Sources/AppConfig.swift` and update `apiBaseURL` to point at your server.

**5. Build and run**

```
⌘B  — build
⌘R  — run on simulator or device
```

---

## API Contract

The OpenAPI 3.1 spec in `shared/openapi/openapi.yaml` is the source of truth for routes and models.

To generate TypeScript types:

```bash
npx openapi-typescript shared/openapi/openapi.yaml -o server/src/types/openapi.d.ts
```

### Adding new features

1. Define the route in `shared/openapi/openapi.yaml`
2. Add the TypeScript type to `server/src/types/api.ts`
3. Implement the route in `server/src/routes/`
4. Add the Swift model and API call in `ios/Sources/`

---

## License

MIT
