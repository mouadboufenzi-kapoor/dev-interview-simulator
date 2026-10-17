# Dev Interview Simulator

A web application that simulates technical interviews. It builds a session from a bank of questions, lets the user answer them, and returns a scored report with explanations.

Preparing for a technical interview usually means reading lists of questions without ever knowing whether an answer was right or why. This project turns that into practice: answer, get corrected immediately, and see which topics need work.

It is aimed at developers preparing for back-end, front-end or generalist interviews, from students to experienced engineers.

## Features

- Simulated interviews of 12 challenges, drawn at random and filtered by the selected profile and skills.
- Five types of challenges: situational QCM, problem solving (multiple correct answers), code review (find the bugs, with severity), sequential reasoning (order the steps by drag and drop), and architecture scenarios.
- Scoring computed on the server. The client never receives the corrections before submitting an answer.
- Corrections with the expected answer, the common mistake to avoid, and good practices.
- Guest mode without an account, and registered accounts with history and a progress dashboard.
- Back-office for administrators: create and edit challenges, profiles and scenarios, view platform statistics.
- Email/password authentication and Google sign-in.
- Light and dark theme.

## Tech stack

**Frontend:** React 19, TypeScript, Vite, Tailwind CSS 4, axios, dnd-kit, lucide-react.

**Backend:** Java 21, Spring Boot 3.4, Spring Web, Spring Data JPA, Spring Security, JJWT, Bean Validation, Flyway.

**Database:** PostgreSQL 18.

**Authentication:** stateless JWT, BCrypt for passwords, Google ID tokens verified server-side.

**Tools and infrastructure:** Docker, Docker Compose, Maven Wrapper, GitHub, Render (hosting), Supabase (managed PostgreSQL in production).

## Architecture

The frontend is a single-page application that talks to a REST API. It never accesses the database directly.

```
Browser (React SPA)
    |  HTTP + Authorization: Bearer <JWT>
    v
Spring Boot REST API  /api/**
    |  JWT filter, role checks, validation
    v
Services (drawing, correction, scoring, statistics)
    |  Spring Data JPA
    v
PostgreSQL
    ^  Flyway migrations and seeds, applied at startup
```

A few decisions worth knowing about:

- The API is the only authority. The client sends a choice, never a verdict; the correct options are not part of the response payload before submission.
- The API is stateless. Every request carries a JWT, verified on each call. Sessions are not stored server-side.
- Entities are not serialized directly. Each exchange goes through DTOs, in both directions.
- The schema belongs to Flyway, not to Hibernate. JPA runs with `ddl-auto: validate`, so the schema only changes through a migration file.
- Errors are handled in one place and returned with the proper HTTP status, which the frontend reads to react, including clearing the stored token on 401/403.

## Project structure

```
dev-interview-simulator/
|-- docker-compose.yml                    PostgreSQL 18 and the backend, for local use
|-- dev-interview-simulator-backend/
|   |-- Dockerfile                        multi-stage build: Maven, then JRE 21
|   |-- mvnw                              Maven Wrapper
|   |-- src/main/java/com/interview/simulator/
|   |   |-- admin/                        back-office: challenges, scenarios, profiles, stats
|   |   |-- auth/                         register, login, Google sign-in, JWT
|   |   |-- category/  skill/  profile/   reference data and their API
|   |   |-- user/                         accounts, guest resolution, user statistics
|   |   |-- challenge/                    challenges, options, scenarios, enums
|   |   |-- simulation/                   sessions, correction, scoring
|   |   |-- config/                       security rules, CORS, admin bootstrap
|   |   `-- exception/                    global error handling
|   |-- src/main/resources/
|   |   |-- application.yml
|   |   `-- db/
|   |       |-- migration/                schema changes
|   |       `-- seed/                     question bank and reference data
|   `-- src/test/java/                    unit and integration tests
`-- dev-interview-simulator-frontend/
    `-- src/
        |-- api/                          axios client, one module per resource
        |-- components/                   one folder per screen
        |-- types/                        contracts mirroring the API DTOs
        `-- utils/
```

## Getting started

### Prerequisites

- JDK 21
- Node.js 20 or newer
- Docker (for PostgreSQL)

### Configuration

The backend refuses to start without a few values, on purpose. There is no default `admin/admin` fallback and no default JWT secret. Create `dev-interview-simulator-backend/.env`:

```bash
JWT_SECRET=           # long random string, 32 characters or more
ADMIN_USERNAME=admin
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=       # strong password
```

Optional: `GOOGLE_CLIENT_ID` (enables Google sign-in), `CORS_ORIGINS`, `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`.

The frontend reads `VITE_API_URL` at build time. It defaults to `http://localhost:8080/api`, which matches a local backend, so nothing extra is needed to start locally.

### Run

```bash
git clone git@github.com:mouadboufenzi-kapoor/dev-interview-simulator.git
cd dev-interview-simulator
docker compose up -d               # PostgreSQL on 5432, backend on 8080

cd dev-interview-simulator-frontend
npm install
npm run dev                        # http://localhost:5173
```

To run the backend in an IDE instead, start only the database with `docker compose up -d postgres`, then launch `BackendApplication`. On Windows, use `mvnw.cmd spring-boot:run` from the backend folder.

Migrations and seeds run automatically on the first start, so the database arrives populated.

### Useful commands

```bash
cd dev-interview-simulator-backend
./mvnw test                        # unit and integration tests
./mvnw package                     # build the jar

cd dev-interview-simulator-frontend
npm run build                      # type check, then production build in dist/
npm run lint                       # oxlint
```

## Database

PostgreSQL 18. The schema and the content are both versioned with Flyway, in two folders:

- `db/migration` holds the structural changes: tables, columns, constraints.
- `db/seed` holds the question bank and reference data: categories, skills, profiles, challenges.

There are 30 versioned files, from the initial schema to the latest question catalogs. Files are applied once per database and are never edited afterwards; a change means a new versioned file. Seeds are written so that restarting the application does not create duplicates.

Two constraints protect the enumerated values in the database, one on `challenges.type` and one on `simulations.mode`. Adding a challenge type means extending both.

## Authentication

Two ways in, both returning a JWT valid for 8 hours by default (`JWT_EXPIRATION`):

- **Email and password.** Registered with `POST /api/auth/register`, which forces the `USER` role. Passwords are hashed with BCrypt.
- **Google.** The frontend obtains an ID token, and the backend verifies it against Google (issuer, audience, expiry, signature) before creating or reusing the account. It is enabled once `GOOGLE_CLIENT_ID` is set on both sides.

Guests are supported without an account. Their simulations are attached to a shared `default_user` account and are not kept as history.

Authorization is declared in `SecurityConfig`:

- public: `/api/auth/**`, `/api/categories/**`, `/api/skills/**`, `/api/profiles/**`, `/api/simulations/**`, `/api/health`
- `/api/admin/**` requires the `ADMIN` role
- everything else requires a valid token

The administrator account is created at startup from `ADMIN_USERNAME`, `ADMIN_EMAIL` and `ADMIN_PASSWORD`, and its password is kept in sync with that variable on restart.

## External AI integration (Gemini)

The back-office can generate new questions with an external LLM (Google Gemini). The integration is optional, admin-only, and the rest of the application runs normally without it.

- `POST /api/admin/challenges/generate` (admin role) takes a difficulty, a challenge type, a count of 1 to 10, and profile, category and skill references. Its interface is the fifth tab of the back-office, "Génération": type, difficulty, count, at least one profile and one category, optional skills and extra instructions. The button stays disabled until the form is valid, so a misconfigured request never reaches the provider.
- The backend builds the prompt itself (French, mobile-first editorial rules: short titles, a compact context matched to the difficulty, comparable answer options, no filler, and a self-check before returning) and asks for a strict JSON schema. The response goes through the same import service as a manual JSON import: every generated question lands as a `DRAFT`, categories, skills, profiles and difficulty are forced from the admin request and never taken from the model output, and an over-long answer is truncated to the requested count.
- Configuration: `GEMINI_API_KEY` (sent in a request header, never in the URL or the logs), `GEMINI_MODEL` (default `gemini-3.8-flash`), `GEMINI_BASE_URL` and `GENERATION_ENABLED`. Without a key the application starts normally and only the endpoint answers 503.
- Provider errors are translated: 429 stays a 429 (quota), while 401, 403, 404, other 5xx responses and unreadable bodies become a 502 with a generic message — the raw provider response and the key are never exposed.
- No extra dependency: the backend calls the provider with the JDK's own `HttpClient`.

## Project status

Available today: the full simulation flow with the five challenge types, guest and registered usage, the user dashboard, the administrator back-office, and the seeded question bank covering Java, Spring Boot, SQL, JPA Hibernate, API back-end, React, tests, architecture, distributed systems, system design, Git, Docker, CI/CD, and the Java to Spring transition.

The application is deployed: the API runs as a web service on Render, the frontend as a static site on the same platform, and PostgreSQL is managed by Supabase.

Not implemented yet: a CI pipeline, rate limiting, a refresh token (sessions end after 8 hours), automated end-to-end tests, and internationalization. The question bank is limited to what is seeded.

## Author

Mouad Boufenzi - [mouadboufenzi-kapoor](https://github.com/mouadboufenzi-kapoor)

Built as a personal project.
