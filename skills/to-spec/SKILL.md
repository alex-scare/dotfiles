---
name: to-spec
description: Turn the current conversation into a local implementation specification or PRD. Use when the user asks to create, capture, or synthesize a spec from decisions already discussed; save the result in the current repository's docs directory without conducting an interview.
---

# To Spec

Synthesize the current conversation and codebase context into a specification. Do not interview the user or reopen settled decisions.

## Process

1. Explore the repository to understand its current state. Read applicable project instructions, domain glossaries, ADRs, and existing documentation conventions.
2. Select the highest stable seam at which the feature can be tested. Prefer one externally observable seam over several implementation-level seams. Record the choice under **Testing Decisions** without pausing for confirmation.
3. Derive a concise specification title from the requested work and convert it to kebab case.
4. Create `docs/` at the repository root when it does not exist.
5. Save the specification as `docs/<kebab-case-title>.md` unless the user explicitly requested another filename within `docs/`.
6. Never overwrite an unrelated document. If the target exists and clearly describes the same work, update it. Otherwise, choose a distinct descriptive filename.
7. Write the specification using the template below. Preserve material uncertainties under **Further Notes** instead of asking follow-up questions.
8. Return a link to the created or updated local specification.

Do not publish to an issue tracker, create an issue, or require tracker configuration.

## Specification template

```markdown
# <Specification title>

## Problem Statement

The problem from the user's perspective.

## Solution

The solution from the user's perspective.

## User Stories

An extensive numbered list covering all agreed behavior. Use this format:

1. As an <actor>, I want <feature>, so that <benefit>.

## Implementation Decisions

Record agreed architecture, modules, interfaces, technical constraints, schemas, contracts, and interactions. Do not include specific file paths or working code snippets because they become stale quickly.

Exception: include a compact prototype-derived state machine, schema, reducer, or type shape when it expresses a settled decision more precisely than prose. Label it as prototype-derived and trim it to the decision-rich portion.

## Testing Decisions

Describe the externally observable behavior to test, the selected test seam, affected modules, and relevant prior art in the repository. Test behavior rather than implementation details.

## Out of Scope

State what this specification intentionally excludes.

## Further Notes

Record remaining inputs, non-blocking uncertainties, rollout notes, and relevant context.
```
