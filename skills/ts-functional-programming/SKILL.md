---
name: ts-functional-programming
description: >-
  Use this skill when writing, reviewing, or refactoring TypeScript in a functional,
  Elixir-inspired style. Favor explicit data flow, immutable domain models,
  discriminated unions, exhaustive matching with ts-pattern, and typed success/error
  flows with neverthrow. Apply it to backend services, business logic, validation,
  orchestration, and API boundaries where expected failures should be represented as data.
---

# TypeScript Functional Programming

## Primary goal

Produce TypeScript that has the clarity of idiomatic Elixir while remaining natural to the TypeScript ecosystem.

Prefer:

- immutable data over stateful objects
- pure transformations over mutation
- explicit `Result` values over exceptions for expected failures
- exhaustive pattern matching over scattered conditionals
- small functions and pipelines over large service methods
- dependency injection through plain values or module factories
- runtime validation at untrusted boundaries

Do not imitate Elixir syntax mechanically. Preserve its programming model using TypeScript-native representations.

## Default libraries

Use these libraries when they are already available or when adding them is appropriate:

```ts
import { match, P } from "ts-pattern";
import {
  err,
  errAsync,
  ok,
  okAsync,
  Result,
  ResultAsync,
} from "neverthrow";
```

Use native TypeScript discriminated unions for domain data and errors.

## Core conventions

### Represent domain states as tagged unions

Prefer named object fields:

```ts
type PaymentState =
  | { readonly type: "pending"; readonly paymentId: string }
  | {
      readonly type: "completed";
      readonly paymentId: string;
      readonly amount: number;
    }
  | {
      readonly type: "failed";
      readonly paymentId: string;
      readonly reason: PaymentFailure;
    };
```

Avoid tuple unions unless tuple position is genuinely clearer than named fields.

### Represent expected failures with `Result`

```ts
type FindUserError =
  | { readonly type: "invalid_id"; readonly input: string }
  | { readonly type: "not_found"; readonly userId: string }
  | { readonly type: "repository_error"; readonly cause: unknown };

const findUser = (
  repository: UserRepository,
  userId: string,
): ResultAsync<User, FindUserError> => {
  if (userId.trim() === "") {
    return errAsync({ type: "invalid_id", input: userId });
  }

  return ResultAsync.fromPromise(
    repository.findById(userId),
    (cause): FindUserError => ({ type: "repository_error", cause }),
  ).andThen((user) =>
    user === null
      ? errAsync({ type: "not_found", userId })
      : okAsync(user),
  );
};
```

Use exceptions only for defects, violated invariants, or unrecoverable programmer errors.

### Match exhaustively

```ts
const describeError = (error: FindUserError): string =>
  match(error)
    .with(
      { type: "invalid_id" },
      ({ input }) => `Invalid user ID: ${input}`,
    )
    .with(
      { type: "not_found" },
      ({ userId }) => `User ${userId} was not found`,
    )
    .with(
      { type: "repository_error" },
      () => "Repository unavailable",
    )
    .exhaustive();
```

Prefer `.exhaustive()` for closed domain unions. Use `.otherwise()` only when the domain is intentionally open or a fallback is genuinely required.

### Chain fallible operations with `andThen`

```ts
const registerUser = (
  repository: UserRepository,
  input: RegisterUserInput,
): ResultAsync<User, RegisterUserError> =>
  validateRegistration(input)
    .asyncAndThen((registration) =>
      ensureEmailAvailable(repository, registration.email)
        .map(() => registration),
    )
    .andThen((registration) =>
      ResultAsync.fromPromise(
        repository.insert(registration),
        (cause): RegisterUserError => ({
          type: "repository_error",
          cause,
        }),
      ),
    );
```

Think of:

- `map` as transforming `{:ok, value}`
- `mapErr` as transforming `{:error, reason}`
- `andThen` as chaining tuple-returning functions
- `asyncAndThen` as crossing from `Result` to `ResultAsync`
- `.match(onOk, onErr)` as consuming the final result

### Keep the pure core separate from effects

Structure application code as:

```text
transport boundary
  -> parse and validate
  -> pure domain decisions
  -> effectful repository or network operations
  -> map domain result to transport response
```

Pure domain functions should:

- accept ordinary values
- return ordinary values or `Result`
- avoid I/O
- avoid time, randomness, environment access, and global state
- avoid mutation

Inject time, IDs, repositories, and external clients explicitly.

## Preferred module shape

Prefer plain functions or module factories over stateful service classes.

```ts
type Dependencies = {
  readonly users: UserRepository;
  readonly generateId: () => string;
  readonly now: () => Date;
};

export const makeUsers = (dependencies: Dependencies) => {
  const create = (
    input: CreateUserInput,
  ): ResultAsync<User, CreateUserError> => {
    // implementation
  };

  const find = (
    userId: string,
  ): ResultAsync<User, FindUserError> => {
    // implementation
  };

  return { create, find } as const;
};
```

Use classes only when identity, lifecycle, framework integration, or controlled mutable state is part of the actual domain.

## Validation boundaries

TypeScript types do not validate runtime input. Decode all untrusted data at system boundaries using the project’s schema library, such as Zod, Valibot, ArkType, or Effect Schema.

Convert schema failures into domain or transport errors explicitly.

```ts
const parseCreateUser = (
  input: unknown,
): Result<CreateUserInput, ValidationError> => {
  const parsed = CreateUserSchema.safeParse(input);

  return parsed.success
    ? ok(parsed.data)
    : err({
        type: "validation_error",
        issues: parsed.error.issues,
      });
};
```

Do not repeatedly revalidate trusted internal values.

## Error design

Errors should be small, serializable domain values.

Prefer:

```ts
type TransferError =
  | { readonly type: "invalid_amount"; readonly amount: number }
  | {
      readonly type: "insufficient_funds";
      readonly available: number;
      readonly requested: number;
    }
  | { readonly type: "account_not_found"; readonly accountId: string };
```

Avoid:

```ts
type TransferError = Error;
```

Do not expose raw infrastructure exceptions outside the infrastructure boundary. Wrap them in a stable tagged error and retain the original cause only for logging or diagnostics.

## Pattern matching guidance

Use `ts-pattern` when:

- consuming a discriminated union
- matching nested domain state
- replacing repeated `if`/`else if` checks
- handling several error variants
- guards make a domain rule clearer

Example with a guard:

```ts
const accountAction = (account: Account): AccountAction =>
  match(account)
    .with(
      {
        status: "active",
        balance: P.when((balance) => balance > 0),
      },
      () => ({ type: "allow_payment" }),
    )
    .with(
      { status: "active", balance: 0 },
      () => ({ type: "request_funding" }),
    )
    .with(
      { status: "suspended" },
      () => ({ type: "deny_payment", reason: "suspended" }),
    )
    .exhaustive();
```

Do not introduce pattern matching for a trivial two-branch boolean when a normal conditional is clearer.

## Async conventions

Return `ResultAsync<T, E>` directly rather than wrapping it in an unnecessary `async` function.

Prefer:

```ts
const loadUser = (
  repository: UserRepository,
  id: string,
): ResultAsync<User, LoadUserError> =>
  ResultAsync.fromPromise(
    repository.findById(id),
    (cause) => ({ type: "repository_error", cause } as const),
  ).andThen((user) =>
    user
      ? okAsync(user)
      : errAsync({ type: "not_found", userId: id } as const),
  );
```

Avoid:

```ts
const loadUser = async (...): Promise<Result<User, LoadUserError>> => {
  return await ResultAsync.fromPromise(...);
};
```

Use `Promise.all` or domain-appropriate concurrency only when operations are independent. Preserve explicit error mapping for each external operation.

## Transport mapping

Consume domain results at the edge of the application.

```ts
const toHttpResponse = (
  result: Result<User, CreateUserError>,
): HttpResponse =>
  result.match(
    (user) => ({ status: 201, body: user }),
    (error) =>
      match(error)
        .with(
          { type: "invalid_email" },
          () => ({ status: 400, body: { error: "Invalid email" } }),
        )
        .with(
          { type: "email_taken" },
          ({ email }) => ({
            status: 409,
            body: { error: `Email ${email} is already registered` },
          }),
        )
        .with(
          { type: "repository_error" },
          () => ({
            status: 500,
            body: { error: "Internal server error" },
          }),
        )
        .exhaustive(),
  );
```

Do not mix HTTP status codes, framework response objects, or transport-specific errors into core domain functions.

## Testing style

Test pure functions with table-driven cases.

```ts
describe("validateAge", () => {
  it.each([
    { age: 18, expected: ok(18) },
    { age: 24, expected: ok(24) },
    {
      age: 17,
      expected: err({ type: "underage", age: 17 }),
    },
  ])("validates $age", ({ age, expected }) => {
    expect(validateAge(age)).toEqual(expected);
  });
});
```

For `ResultAsync`, unwrap only inside tests when that makes assertions clearer. Prefer asserting the complete tagged result when possible.

Test each domain error variant and each exhaustive matching branch.

## Refactoring workflow

When converting imperative TypeScript:

1. Identify expected failure paths currently represented by thrown exceptions, `null`, booleans, or magic strings.
2. Create a discriminated error union.
3. Change leaf functions to return `Result` or `ResultAsync`.
4. Replace sequential checks with `map`, `andThen`, and `asyncAndThen`.
5. Move side effects to injected adapters.
6. Replace branching over domain states with exhaustive `ts-pattern` matches.
7. Decode untrusted values once at the boundary.
8. Add tests for every success and error variant.

Do not perform a whole-codebase functional rewrite merely for stylistic consistency. Refactor around domain boundaries and high-value workflows first.

## Code review checklist

Check that:

- domain unions are discriminated and exhaustive
- error variants contain useful contextual fields
- expected failures do not throw
- `ResultAsync` is not unnecessarily wrapped in `Promise<Result<...>>`
- infrastructure errors are mapped to stable application errors
- pure logic is independent of I/O and framework code
- dependencies are explicit
- objects are `readonly` where practical
- mutation is local, justified, and not observable outside the function
- `ts-pattern` matches use `.exhaustive()` where possible
- `map` is not used for functions that return another `Result`
- `andThen` is not used for infallible transformations
- validation occurs at untrusted boundaries
- transport mapping occurs at the application edge

## Avoid over-functionalization

Do not:

- build custom monad abstractions when `neverthrow` already covers the need
- introduce point-free code that obscures types or intent
- replace every conditional with `ts-pattern`
- wrap plain values in `Result` when no meaningful failure exists
- use `Option` or `Result` merely to avoid `undefined` in private local code
- copy Elixir tuple shapes when named TypeScript object fields are clearer
- force functional style into UI state or framework APIs where it creates friction

The goal is explicit, composable application code—not maximum abstraction.

## Elixir correspondence

Use this mapping when explaining or translating code:

| Elixir | TypeScript |
|---|---|
| `{:ok, value}` | `ok(value)` |
| `{:error, reason}` | `err(reason)` |
| `case` | `match(...).with(...).exhaustive()` |
| `with` | `.andThen(...)` / `.asyncAndThen(...)` |
| function clauses | `ts-pattern` branches or small functions |
| guards | `P.when(...)` |
| pipe operator | `Result` chaining or a data-first `pipe` |
| atom error | tagged object error |
| map/struct | `readonly` object type |
| process or task result | application-specific `ResultAsync` workflow |

## Output expectations

When producing code under this skill:

- provide complete, type-checkable snippets
- preserve exact error types across the pipeline
- avoid `any`; use `unknown` at unsafe boundaries
- use `readonly` for domain data unless mutation is required
- show both success and failure handling
- use names from the user’s domain rather than generic functional terminology
- explain important TypeScript–Elixir differences when presenting paired examples
