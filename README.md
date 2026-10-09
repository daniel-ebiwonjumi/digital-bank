Digital Banking Application (Work in progress)

A mobile-first digital banking application built with Flutter, NestJS, TypeScript, and PostgreSQL.

"GitHub Repository" (github.com/daniel-ebiwomjumi/digital-bank)

«Project status: In development. This project is being developed incrementally, with an emphasis on backend architecture, secure authentication, data integrity, and reliable financial transaction processing. Features and implementation details are documented according to their current development status.»

Table of Contents

- "Overview" (#overview)
- "Problem Statement" (#problem-statement)
- "Project Objectives" (#project-objectives)
- "Features and Development Roadmap" (#features-and-development-roadmap)
- "Technology Stack" (#technology-stack)
- "System Architecture" (#system-architecture)
- "Architectural Decisions" (#architectural-decisions)
- "Security Considerations" (#security-considerations)
- "Financial Transaction Integrity" (#financial-transaction-integrity)
- "Database Design" (#database-design)
- "Authentication and Authorization" (#authentication-and-authorization)
- "API Design" (#api-design)
- "Getting Started" (#getting-started)
- "Testing Strategy" (#testing-strategy)
- "Current Limitations" (#current-limitations)
- "Future Improvements" (#future-improvements)
- "Disclaimer" (#disclaimer)

Overview

This project is an ongoing software engineering project focused on building a digital banking and wallet application with a Flutter mobile client and a NestJS backend.

The application is being designed around common digital banking workflows, including user registration, authentication, wallet management, financial transfers, and transaction history.

Beyond implementing application features, the project explores the engineering considerations involved in developing software that handles sensitive user information and financial operations.

These considerations include authentication, authorization, input validation, database integrity, secure transaction processing, and the design of mechanisms for identifying and responding to suspicious activity.

The mobile application and backend are developed as separate components, communicating through an API. This separation allows the client and server to have distinct responsibilities and allows backend business rules to remain independent of the mobile user interface.

The project is intended to demonstrate practical software engineering skills, including application architecture, API development, relational database design, security-conscious implementation, and technical decision-making.

Problem Statement

Applications that manage financial information require more than functional user interfaces and database operations.

A financial operation must be validated, authorized, and processed consistently. The system must also account for situations such as repeated requests, concurrent transactions, invalid inputs, unauthorized access, and unexpected failures.

For example, a transfer operation should not result in money being deducted from one wallet without the corresponding credit being applied to the destination wallet. Similarly, a mobile client should not be trusted to determine whether a user is authorized to perform a financial operation.

This project approaches these challenges by separating client-side presentation from backend business logic and by designing the backend around explicit security and data-integrity requirements.

Project Objectives

The primary objectives are to:

1. Build a mobile application using Flutter and Dart.
2. Develop a modular backend using NestJS and TypeScript.
3. Design and manage a relational database using PostgreSQL and Drizzle ORM.
4. Implement authentication and authorization around protected resources.
5. Establish clear boundaries between presentation, business logic, and data access.
6. Design wallet and transfer workflows with particular attention to data consistency and concurrent operations.
7. Apply input validation and server-side enforcement of business rules.
8. Explore security mechanisms for session management, suspicious activity detection, and account protection.
9. Establish a testing strategy for application behavior, API contracts, authentication, and financial operations.
10. Document technical decisions and the trade-offs associated with different implementation approaches.

Features and Development Roadmap

The following list distinguishes between the application's intended functionality and features that have been completed.

Implementation status should be updated as development progresses.

1. User Management and Authentication

The application is intended to support user registration and authentication using a mobile-number-based identity.

The backend will be responsible for validating credentials, issuing authentication tokens, and protecting resources that require an authenticated user.

Authentication and authorization will be enforced on the server rather than relying on the mobile application's navigation or interface controls.

2. Wallet Management

The wallet functionality is intended to provide users with access to their wallet information and balances.

Wallet operations will be governed by backend business rules so that clients cannot directly modify authoritative financial records.

The database and backend design will account for the need to maintain consistency between wallet balances and the transactions that affect them.

3. Financial Transfers

The transfer functionality is intended to support the movement of funds between wallets.

A transfer must satisfy relevant business rules before it can be completed, including checks relating to the initiating user, available funds, transaction amount, and destination wallet.

The backend design will account for database transactions and concurrent requests to prevent inconsistent financial records.

4. Transaction History

The application is intended to provide users with a history of their financial transactions.

Transaction records will be associated with the relevant wallets and operations so that the application can present transaction details based on persisted backend data.

5. Security and Fraud Prevention

Security is a central design consideration rather than an isolated feature.

The project will explore mechanisms for protecting authenticated resources, validating sensitive operations, managing sessions, and detecting suspicious transaction patterns.

Where implemented, these mechanisms should be enforced or evaluated by trusted backend components rather than relying solely on the mobile application.

Technology Stack

Mobile Application

Flutter and Dart

Flutter is used to build the mobile application, while Dart provides the programming language for implementing its application logic.

BLoC

BLoC is the chosen state-management approach for organizing application state and separating UI concerns from the logic that responds to user actions and API results.

This separation is intended to make application behavior easier to reason about and test as the project grows.

Backend

NestJS and TypeScript

NestJS provides the backend application framework, while TypeScript supports explicit types and structured application development.

The backend is being organized around NestJS modules and the separation of responsibilities between controllers, services, validation, and data-access components.

Controllers are intended to handle incoming requests and responses, while services encapsulate application and business logic.

Fastify

Fastify is the intended HTTP platform for the NestJS application.

The choice reflects an interest in using NestJS with an alternative to its default Express platform while maintaining NestJS's module and dependency-injection model.

The selection of an HTTP adapter does not replace the need for correct validation, authorization, and business logic.

Database

PostgreSQL

PostgreSQL is used as the relational database for application data.

A relational database is appropriate for this project because users, wallets, transfers, and transaction records have relationships and consistency requirements that need to be represented explicitly.

Database constraints and transactions will be used where appropriate to enforce data integrity.

Drizzle ORM

Drizzle ORM provides the application's database-access layer.

The goal is to keep database schemas and queries explicit and maintain clear relationships between TypeScript application types and PostgreSQL structures.

Database constraints remain important even when application-level validation is present, because database integrity should not depend exclusively on the behavior of an individual API endpoint.

System Architecture

The application follows a client-server architecture.

┌─────────────────────────────────┐
│       Flutter Mobile App        │
│                                 │
│  Dart                            │
│  BLoC State Management           │
│  UI and User Interaction         │
└────────────────┬────────────────┘
                 │
                 │ HTTP / JSON API
                 ▼
┌─────────────────────────────────┐
│       NestJS Backend            │
│                                 │
│  Request Validation              │
│  Authentication and Guards       │
│  Controllers                     │
│  Application Services            │
│  Business Rules                  │
│  Data Access                     │
└────────────────┬────────────────┘
                 │
                 │ Drizzle ORM
                 ▼
┌─────────────────────────────────┐
│          PostgreSQL             │
│                                 │
│  Users                           │
│  Wallets                         │
│  Transactions                    │
│  Related Application Data        │
└─────────────────────────────────┘

This diagram represents the intended architecture. Components should be adjusted to reflect the implementation as it evolves.

Architectural Responsibilities

Flutter client

The mobile application is responsible for presenting information, collecting user input, managing UI state, and communicating with the backend.

It may perform client-side validation to improve the user experience, but client-side checks are not treated as a security boundary.

NestJS backend

The backend is responsible for authenticating requests, enforcing authorization rules, validating inputs, executing business logic, and coordinating database operations.

Sensitive operations must be validated independently of the values or decisions supplied by the client.

PostgreSQL database

The database stores persistent application data and provides relational constraints and transactional capabilities.

The backend determines which operations are permitted, while the database helps preserve the consistency of the resulting records.

Architectural Decisions

The project is being developed with attention to the reasoning behind technical choices, rather than selecting tools solely because they are popular.

1. Flutter for the Mobile Client

Flutter provides a single framework for developing the mobile application.

It also allows application structure, UI state, and API integration to be developed independently of the backend implementation.

2. NestJS for the Backend

NestJS provides a modular structure for organizing backend functionality.

As the application grows, modules can be organized around responsibilities such as authentication, users, wallets, and transfers.

This structure is intended to make dependencies and responsibilities easier to understand, test, and maintain.

3. PostgreSQL for Persistent Data

The application involves related entities and operations that require reliable persistence.

PostgreSQL provides relational constraints and transaction support, which are relevant to maintaining consistency across related financial records.

4. Drizzle ORM for Database Access

Drizzle ORM is used to interact with PostgreSQL through TypeScript.

The approach favors explicit schemas and queries while retaining access to database-level capabilities when application requirements demand them.

The ORM is a data-access tool; it does not automatically guarantee correct financial logic or eliminate the need to understand SQL transactions, locking, constraints, and query behavior.

5. BLoC for Flutter State Management

BLoC is intended to separate UI state transitions from presentation code.

This can make asynchronous operations, such as authentication requests and balance retrieval, easier to model and test.

It also provides a structured approach to handling loading, success, and failure states.

6. Fastify as the HTTP Platform

Fastify is the selected HTTP platform for the NestJS backend.

This choice allows the project to explore NestJS's platform abstraction while using Fastify for HTTP request handling.

The choice of adapter is considered separately from application-level concerns such as authentication, validation, and database integrity.

Security Considerations

Security is particularly important for an application that models financial operations.

The project is being designed with the following principles in mind.

Server-Side Validation

All sensitive requests must be validated on the backend.

Client-side validation may help users correct mistakes before submitting a request, but it cannot replace server-side validation because clients can be modified or bypassed.

Validation will cover the structure and permitted values of incoming requests, while business rules will determine whether an operation is valid in its current context.

Authentication and Authorization

Authentication establishes the identity associated with a request.

Authorization determines whether that identity is permitted to perform the requested operation.

For example, successfully authenticating a user must not automatically grant access to another user's wallet or transaction records.

Authorization checks should therefore be applied to the resources and operations involved in each request.

Password Protection

Passwords should never be stored as plaintext.

The implementation is intended to use a suitable password-hashing algorithm, such as Argon2, and verify submitted credentials against the stored password hash.

Password hashes must not be returned through public API responses.

Token and Session Management

Token-based authentication is the intended approach for protecting API requests.

The implementation will need to account for token expiration, refresh behavior, token storage, and session invalidation.

Access-token validity and the ability to revoke or invalidate a session are separate concerns. A design that needs to respond quickly to compromised accounts or suspicious activity must explicitly account for how token validity is checked.

Sensitive Information

Passwords, authentication tokens, and other secrets should not be exposed in API responses or application logs.

Environment-specific configuration and credentials should be supplied through appropriate configuration mechanisms rather than committed to the repository.

Least Privilege

Users should receive access only to the resources and operations required by their permissions.

The backend must not trust a user identifier supplied by a client without checking that the authenticated user is authorized to access the associated resource.

Security Testing

Authentication, authorization, input validation, and sensitive business operations should be covered by automated tests.

Testing should include negative cases, such as attempts to access another user's resources, submit invalid values, reuse expired credentials, or perform operations that violate business rules.

Financial Transaction Integrity

One of the central engineering concerns in this project is maintaining consistent financial records.

A transfer is not merely an update to two wallet balances. It is a business operation involving multiple related changes that must succeed or fail together.

Atomicity

A transfer between two wallets should be processed atomically.

If the debit from the source wallet succeeds but the credit to the destination wallet fails, the system must not leave the database in a partially completed state.

Database transactions can help ensure that related changes are committed together or rolled back together.

Concurrent Operations

Multiple requests may attempt to modify the same wallet at approximately the same time.

For example, two transfer requests could arrive before either request has completed.

The implementation must account for this possibility so that concurrent operations cannot bypass available-balance checks or produce inconsistent results.

The appropriate approach may involve database locking, conditional updates, transaction isolation, or a combination of these mechanisms, depending on the final schema and transaction workflow.

Insufficient Funds

The backend must verify that a wallet has sufficient available funds before completing a debit.

This check must be performed in a way that remains correct under concurrent requests, rather than relying solely on a balance previously retrieved by the mobile client.

Duplicate Requests

Networks and clients can retry requests when a response is delayed or lost.

For a transfer endpoint, an unprotected retry could result in the same intended operation being processed more than once.

An idempotency mechanism is therefore an important design consideration for the transfer workflow.

Transaction Records

Financial operations should produce persistent records that allow the application to determine what occurred.

The transaction model should capture the relevant details of an operation, such as its amount, associated wallets, status, and creation time.

The final design will determine the appropriate transaction states and how failed, pending, and completed operations are represented.

Balance Consistency

Wallet balances and transaction records must remain consistent with the business rules of the system.

The implementation should define a clear source of truth for financial balances and establish how balances are updated, reconciled, and verified.

These requirements will guide the database schema, transaction workflow, and automated tests.

Database Design

PostgreSQL is used as the relational data store, with Drizzle ORM providing database access.

The database schema is intended to represent application entities explicitly and enforce important integrity rules.

Users

The user model is intended to hold account-related information.

The planned fields include:

- A unique user identifier.
- First and last names.
- A mobile number.
- An optional email address.
- A password hash.
- An account-verification status.
- Creation and update timestamps.

Unique constraints will be applied to identifiers such as mobile numbers and, where appropriate, email addresses.

Optional fields require particular care when defining database constraints so that their nullability and uniqueness behavior match the application's requirements.

Wallets

The wallet model will represent a user's wallet and the associated financial state.

The final schema should explicitly define wallet ownership, currency handling, balance representation, and any constraints required by the business rules.

Financial amounts should use a representation that avoids floating-point rounding errors. The choice of integer minor units or an appropriate exact-decimal database representation will depend on the final currency and accounting model.

Transactions

The transaction model will record operations that affect wallet balances.

The design should define the relationship between transaction records and the wallets involved, along with the transaction amount, status, and relevant timestamps.

The schema should also support the integrity requirements of the transfer workflow, including the prevention of duplicate processing where applica

