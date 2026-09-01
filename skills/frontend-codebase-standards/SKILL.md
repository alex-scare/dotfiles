---
name: frontend-codebase-standards
description: Apply opinionated frontend engineering standards when creating, implementing, refactoring, reviewing, or organizing TypeScript and React codebases. Use for frontend architecture, Bun toolchains, Biome formatting, import aliases, strict typing, Zod parsing, state management, reusable integrations such as workers or webhooks, Tailwind/UI-kit work, testing, documentation, and code-quality reviews.
---

# Frontend Codebase Standards

Build maintainable frontend code through ownership-oriented modules, strict state modeling, established tooling, and behavior-preserving changes. Apply these rules proportionally to the task; do not turn a small change into an unsolicited rewrite.

## Working method

1. Read repository instructions, package configuration, surrounding modules, and relevant tests before editing.
2. Inspect the working tree and preserve unrelated user changes.
3. Identify the owning module and the stable seam before adding files or abstractions.
4. Prefer established libraries and repository conventions over handwritten infrastructure.
5. Implement the smallest complete vertical change, including failure and impossible states.
6. Run formatting, typechecking, relevant tests, and broader gates in proportion to risk.
7. Update current architecture or agent guidance when a non-obvious contract changes.
8. Keep mechanical, dependency, architectural, and behavioral changes independently reviewable.

## Toolchain and automation

- Choose Bun whenever creating a new codebase or otherwise free to select the JavaScript toolchain. Use Bun as runtime, package manager, script runner, and lockfile authority.
- In an established repository, respect its existing toolchain unless the user authorizes migration.
- Do not introduce npm, Yarn, or pnpm artifacts into a Bun codebase.
- Keep one formatter and linter. Prefer Biome for TypeScript/JavaScript/JSX/JSON/CSS formatting, linting, and import organization.
- Connect the repository formatter to the editor, format-on-save, canonical typecheck, and CI.
- Normalize the whole repository in a dedicated mechanical commit after changing formatter settings.
- Do not create custom regex quality scripts when Biome, TypeScript, Zod, or another established tool already enforces the rule.
- Keep packages on verified current compatible versions. Isolate dependency upgrades from architecture and product changes.

## Imports and source organization

- Configure the same ownership aliases in TypeScript, the bundler, tests, workers, and editor tooling.
- Use aliases for cross-directory imports and `./` only for files in the same directory.
- Reject parent-relative `../` imports and nested relative crossings when an ownership alias exists.
- Let Biome organize imports.
- Organize source roots around ownership, not mechanisms. Prefer a small vocabulary such as `app`, `assets`, `core`, `domain`, `features`, `test`, and `ui-kit` when it fits the product.
- Keep feature UI, state, orchestration, and feature-specific adapters together.
- Do not create generic top-level `components`, `workers`, `services`, `hooks`, `utils`, `renderer`, or `persistence` directories when an app or feature owns the implementation.
- Introduce `pages` only when real routes justify it.
- Keep `core` small and flat. It is not a miscellaneous dumping ground.

## Module design

- Prefer deep modules: a small interface hiding meaningful behavior.
- Apply the deletion test. If deleting a module only removes forwarding code, delete or inline it. If complexity spreads across callers, the module is earning its place.
- Avoid speculative ports, factories, wrappers, and configuration for hypothetical future adapters.
- Introduce a seam when behavior genuinely varies or when a test adapter represents a real dependency boundary.
- Keep the application root focused on composition rather than workflows.
- Keep domain rules independent of React, state libraries, browser storage, workers, Canvas, and styling.
- Express domain changes through explicit operations or commands rather than broad mutable setters.

## Parsing and runtime validation

- Use Zod by default for untrusted data and schema parsing in a TypeScript frontend.
- Prefer the repository's established equivalent when it already uses another capable validation library.
- Do not invent handwritten object validators, record walkers, error aggregation, or schema combinators when Zod or an established library solves the problem.
- Define schemas at untrusted seams: imported files, persisted data, network responses, webhook payloads, worker messages, static JSON assets, URL data, and browser storage.
- Infer TypeScript types from schemas where practical so runtime and compile-time contracts cannot drift.
- Use explicit parsing or schema narrowing for DOM strings and external enum values; never cast uncontrolled strings directly into domain unions.
- Handwrite validation only when the data is trivial, a library cannot express the constraint cleanly, or a measured hot path justifies it. Document the reason.

## Types and state

- Enable strict TypeScript, including `exactOptionalPropertyTypes`, `noUncheckedIndexedAccess`, `noImplicitReturns`, and fallthrough protection when compatible.
- Prefer discriminated unions over related optional flags.
- Make invalid states unrepresentable. Model idle, running, succeeded, failed, and cancelled as distinct variants.
- Handle closed unions exhaustively. Use `assertNever` or an equivalent compile-time exhaustiveness guard.
- Avoid non-null assertions, broad `as` casts, and TypeScript suppressions. Narrow uncertain values.
- Separate durable state, transient UI state, derived state, and write-only actions.
- Keep state-library topology private to the owning module. Expose focused hooks or a small feature interface instead of unrestricted atoms or a wide mutable object.
- Compute shared derived values once rather than duplicating calculations in callers.
- Keep high-frequency pointer, viewport, animation-frame, and preview state local rather than globally persisted.
- Preserve ordered writes, stale-completion protection, identity scoping, and explicit failure states in persistence workflows.

## Standardize reusable lifecycles

- Standardize any repeated integration whose implementations must not omit lifecycle behavior. This includes workers, webhooks, event consumers, subscriptions, HTTP clients, storage adapters, background jobs, and similar reusable mechanisms.
- Centralize correlation, decoding, validation, retries when appropriate, cancellation, timeouts, error mapping, observability, cleanup, and idempotency when those guarantees repeat.
- Use a factory, shared runtime, or deep module when adding a new implementation should automatically inherit required guarantees.
- Keep domain-specific payloads and results typed; shared infrastructure must not erase meaningful differences.
- Validate inbound data with Zod or the repository's established schema library before domain logic sees it.
- For webhooks and event consumers, include signature/authentication verification where applicable, idempotency, replay/duplicate handling, typed event dispatch, and exhaustive event handling.
- For workers and cancellable tasks, terminate or clean up on success, cancellation, transport failure, decode failure, and synchronous startup/posting failure.
- Scope asynchronous results to the entity or request that started them so stale work cannot update newer state.
- Do not standardize one-off code prematurely. Repetition or a mandatory lifecycle contract must justify the abstraction.

## React and rendering

- Use React Compiler when the project supports it; do not add `memo`, `useMemo`, or `useCallback` solely as performance hints.
- Preserve stable identity when it is behaviorally significant to effects, subscriptions, or external interfaces.
- Keep browser-event translation, domain intent, and visualization separate.
- Keep hot rendering state in refs or local rendering modules, coalesce work with `requestAnimationFrame`, and avoid React commits for every pointer sample.
- Render only visible data for large interactive views and avoid resizing Canvas backing storage during viewport-only redraws.

## Styling, UI kit, and accessibility

- Use Tailwind as the styling implementation and semantic design tokens as the product color/spacing/type vocabulary.
- Avoid arbitrary feature-local colors and generic framework token names that can collide with component libraries.
- Keep the color system simple, expandable, and maintainable. Reserve semantic hues for brand/selection, destructive/error, warning, success, and neutral states.
- Verify text, non-text control, and focus contrast.
- Represent selected, checked, loading, failed, and disabled states with semantics and non-color indicators.
- Build reusable UI-kit modules only when they centralize accessibility, keyboard behavior, focus management, state styling, or repeated interaction rules.
- Test observable accessibility and behavior rather than Tailwind class strings.
- Preserve keyboard navigation, dialog focus, dismissal, screen-reader labels, responsive layouts, and touch behavior.

## Static assets and boundaries

- Store translations, catalogs, and other bundled data as static assets rather than executable objects.
- Let the consuming app or feature own Zod schemas, normalization, fallback behavior, and visible failures.
- Preserve provenance, licensing, and limitations for third-party datasets.
- Do not introduce remote ports or backend abstractions until a real backend exists.

## Testing and verification

- Test through the highest stable seam: domain rules, feature interfaces, reusable integration runtimes, UI-kit behavior, and assembled browser journeys.
- Test shared lifecycle guarantees once at the reusable module seam; keep adapter tests focused on payload and domain mapping.
- Use integration-capable local stand-ins such as fake IndexedDB where they provide more confidence than mocks.
- Replace obsolete implementation-coupled tests after equivalent behavior is protected at the new seam.
- Do not assert private atoms, helper calls, CSS class strings, or internal wiring without a compelling observable contract.
- Keep typecheck, unit tests, coverage, production build, and representative desktop/tablet browser tests green.
- Never weaken thresholds or exclude difficult production code merely to pass a migration.

## Documentation and change discipline

- Keep one authoritative current specification, architecture decision set, glossary, test plan, and issue ledger appropriate to the repository.
- Move superseded documents to an archive and keep archived history frozen.
- Update `AGENTS.md` or equivalent guidance when architecture, invariants, validation, or testing contracts change.
- Do not declare work complete while current documentation, issue status, or required manual release gates disagree with reality.
- Prefer behavior-preserving tracer-bullet migrations over big-bang rewrites.
- Keep dependency upgrades, formatting, file moves, architecture, behavior, and documentation closure in separate commits when practical.
- Never hide semantic changes in a mechanical formatting commit.

## Definition of done

Before completion, confirm that:

- Bun is the sole chosen toolchain when the project allows that choice.
- Biome and editor/CI behavior agree.
- Imports communicate ownership and aliases resolve everywhere.
- Domain logic is independent of presentation and infrastructure.
- Runtime inputs are parsed with Zod or an established equivalent.
- State and async workflows cannot represent contradictory combinations.
- Reusable lifecycles cannot silently omit required guarantees.
- Styling uses semantic tokens with accessible states.
- Relevant automated gates pass without weakened coverage.
- Documentation matches the delivered implementation.
- The final diff contains no unrelated or user-owned changes.
