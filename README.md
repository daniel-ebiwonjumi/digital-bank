Digital Banking Application

A mobile-first digital banking application built with Flutter, Dart, NestJS, TypeScript, and PostgreSQL.

Status: In development.

OVERVIEW

A digital banking and wallet application designed to explore secure authentication, modular backend architecture, relational data modeling, and reliable financial transaction processing.

The application uses Flutter for the mobile client and NestJS for the backend, with PostgreSQL as the persistent data store. The architecture emphasizes separation of concerns, explicit business rules, and data integrity.

The project prioritizes not only feature development but also the engineering principles required to build maintainable software that handles sensitive user information and financial operations.

TECHNOLOGY STACK

Mobile and web -  Flutter, Dart
State management - BLoC
Mobile architecture - Model-View-ViewModel (MVVM)
Backend -  NestJS, TypeScript
HTTP platform - Fastify
Database - PostgreSQL
Object Relational Mapper - Drizzle ORM
Authentication - Passport strategies, JWT
Password hashing - Argon2


SYSTEM ARCHITECTURE 

Flutter UI (View)
        |
ViewModel (MVVM)
        |
BLoC (Event → State)
        |
Repository / API Client
        |
        | HTTP / JSON
        |
NestJS Controllers
        |
Guards / Pipes
        |
NestJS Services (Business Logic)
        |
Drizzle ORM
        |
PostgreSQL Database

This illustrates the intended architecture.

ARCHITECTURAL RESPONSIBILITIES 

- Presentation: Flutter views render application state and collect user input.
- State management: BLoC coordinates user events, asynchronous operations, and UI state transitions.
- Presentation logic: ViewModels expose presentation-ready state and coordinate interactions between views and application services.
- Backend: NestJS handles request validation, authentication, authorization, and business logic.
- Persistence: Drizzle ORM provides typed database access, while PostgreSQL enforces relational constraints and transactional guarantees.

ARCHITECTURAL DECISION 

1. MVVM and Separation of Concerns

The mobile application follows the Model–View–ViewModel (MVVM) architectural pattern.

- Model: Represents application data and domain concepts.
- View: Displays state and forwards user interactions.
- ViewModel: Coordinates presentation logic and exposes state for the view to render.

MVVM prevents presentation code from becoming tightly coupled to application logic. This improves testability, maintainability, and the ability to evolve the UI independently of data-access and business concerns.

The architecture also establishes clear responsibilities between the UI, state management, and data-access layers. BLoC and MVVM serve complementary purposes: MVVM defines architectural responsibilities, while BLoC structures event-driven state transitions.

2. BLoC for Predictable State Management

BLoC is chosen over more permissive state-management approaches because it encourages explicit event-to-state transitions and clear separation between presentation and application logic.

Instead of allowing UI components to mutate state arbitrarily, BLoC organizes state changes around events and emitted states. This makes asynchronous workflows, such as authentication and wallet retrieval, easier to reason about and test.

Explicit states also support consistent handling of loading, success, empty, and failure conditions. The resulting behavior is more predictable, particularly as application workflows become more complex.

The key advantage is architectural discipline and testability, not an assertion that BLoC is universally superior or faster than alternatives.

3. NestJS and Modular Backend Design

NestJS provides a modular backend architecture with dependency injection and clearly defined component responsibilities.

Controllers handle HTTP interactions, services encapsulate application logic, and dedicated data-access components manage persistence. This separation supports independent testing and reduces coupling as functionality expands across authentication, users, wallets, and transfers.

Fastify is selected as the HTTP platform, separating request handling from the application's core business logic.

4. Drizzle ORM and PostgreSQL

Drizzle ORM is selected for its TypeScript-oriented schema definitions, explicit query construction, and close alignment with SQL.

Compared with Prisma's more abstract query API and TypeORM's entity-oriented abstraction, Drizzle offers a relatively thin layer over SQL. This can make query behavior easier to inspect, reduce abstraction overhead, and provide greater control over database operations.

Its lightweight approach can be advantageous for latency-sensitive endpoints and complex relational queries because developers can reason more directly about the SQL being executed.

However, actual performance also depends on query design, generated SQL, database indexes, connection management, data volume, and workload. 

PostgreSQL remains responsible for enforcing database constraints and providing transaction guarantees. Using an ORM does not eliminate the need to understand SQL, isolation levels, locking, or concurrency.

SECURITY AND AUTHENTICATION

The application is designed around server-enforced security boundaries.

- Authentication: Mobile-number-based credential verification using a password-hashing mechanism such as Argon2.
- Authorization: Protected endpoints verify that authenticated users are permitted to access the requested resources.
- Token management: JWT-based authentication with explicit consideration of expiration, refresh, and revocation.
- Input validation: Server-side validation and enforcement of business rules; client-side validation is for usability, not security.
- Sensitive data: Password hashes, tokens, and secrets must not be exposed in API responses, logs, or version control.
- Account protection: Future improvements include session invalidation and risk-based checks for suspicious activity.

A valid token establishes an authenticated identity; it does not automatically authorize access to every resource. Resource ownership and permissions must be checked independently.

FINANCIAL TRANSACTION INTEGRITY

Financial operations require stronger guarantees than ordinary CRUD workflows. The transfer implementation will be designed around the following invariants:

- Atomicity: Related debit and credit operations must succeed or fail together.
- Concurrency control: Simultaneous transfers must not bypass balance checks or violate wallet-balance invariants.
- Insufficient-funds protection: Balance validation must remain correct under concurrent requests.
- Idempotency: Retried requests must not unintentionally execute the same transfer multiple times.
- Persistent transaction records: Operations must be traceable through appropriate transaction states and associated records.
- Precision: Monetary values must use integer minor units or an appropriate exact-decimal representation rather than binary floating-point arithmetic.

PostgreSQL transactions, appropriate locking or conditional updates, database constraints, and application-level business rules will be used where necessary to preserve consistency.

DATABASE DESIGN 

PostgreSQL provides relational storage for the application's core entities.

- Users: Identity information, unique mobile numbers, optional email addresses, password hashes, verification status, and timestamps.
- Wallets: Ownership, currency, and monetary balances.
- Transactions: Transfer amounts, associated wallets, operation status, and timestamps.

Drizzle ORM provides typed schema definitions and database queries. Database constraints complement application validation by enforcing critical integrity rules at the persistence layer.

The final schema will define the precise relationships and constraints required by the implemented workflows.

API DESIGN 

The NestJS backend exposes an HTTP API consumed by the Flutter client.

The API is organized around distinct application responsibilities, with controllers handling requests and services implementing business operations.

All sensitive operations are validated and authorized on the backend. API endpoints must not rely on client-supplied balances, identities, or security decisions.

TESTING STRATEGY

Testing will focus on application correctness and security boundaries:

- Unit tests: Validate services, business rules, and state transitions.
- Integration tests: Verify database interactions, constraints, and transaction behavior.
- API tests: Exercise validation, authentication, authorization, and error handling.
- Financial workflow tests: Verify insufficient-funds protection, atomicity, concurrent operations, and idempotency.

Tests should cover failure scenarios as well as successful requests. In particular, financial invariants must be verified against the actual database behavior rather than inferred from application code alone.

CURRENT STATUS AND FUTURE WORK

The project is under active development. Planned milestones include completing authentication, implementing wallet and transfer workflows, strengthening session management, expanding automated test coverage, and introducing monitoring and suspicious-activity detection.

Features will be marked as implemented only when supported by the corresponding code and, where appropriate, automated tests.

DISCLAIMER

Although this project is being designed and developed with production-grade software engineering principles in mind, it is not intended for use as a live financial service. It must not be used to store real funds or process real financial transactions.
