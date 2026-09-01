---
name: grill-my-skills
description: Run adaptive technical-interview skill assessment and drills. Use when the user wants to be questioned, grilled, assessed, re-assessed, or prepared for interviews across frontend, TypeScript, React, browser/web platform, product engineering, backend, Go, or system design; especially when they ask to continue a skills assessment, identify gaps, or practice high-risk topics one question at a time.
---

# Grill My Skills

Run an adaptive interview assessment loop. The goal is to understand the user's current skill state, expose interview risks, teach through correction, and keep asking the next best question.

## Core Rules

- Ask exactly one question at a time.
- Do not provide the answer, ideal answer, or recommended answer before the user answers.
- After the user answers, give a score from `0` to `4`, detailed correction, and the next question.
- Use the user's latest answer to choose the next question. Stay adaptive, not scripted.
- Prefer high-risk, high-frequency interview topics over broad coverage when time is limited.
- If the user says to wrap up, stop questioning and summarize/persist results.
- If local repo files can answer setup, topic-range, background, or scoring questions, inspect them instead of asking.
- Do not create static question banks. Generate prompts from topics at assessment time.

## Score Meaning

- `0`: missing; cannot start or answer is mostly wrong.
- `1`: weak; recognizes words but would likely fail follow-ups.
- `2`: partial; useful instincts, but important gaps remain.
- `3`: ready; interview-usable for normal follow-ups.
- `4`: strong; clear explanation with tradeoffs, edge cases, and examples.

## Assessment Loop

1. Identify the current target identity and interview window if unknown.
2. Pick the next topic from the highest-risk area, recent weak answer, or repo coverage tracker.
3. Ask one concrete prompt. Use realistic code, design, debugging, or story scenarios.
4. Wait for the user's answer.
5. Score the answer and explain the correction in enough detail to teach the gap.
6. Name the current signal, such as `ready`, `partial`, or `weak`.
7. Ask the next question.

## Topic Priority

For Senior Frontend / Product Engineer positioning, prioritize:

1. React rendering, hooks, effects, stale closures, state ownership, data fetching, testing.
2. TypeScript modeling, narrowing, discriminated unions, `unknown`, runtime validation, exhaustive handling.
3. Browser and web platform: HTML forms, accessibility, CSS layout, DOM events, storage, fetch, cookies, CORS, security, performance.
4. Product engineering: analytics quality, paywalls, onboarding, admin tooling, tradeoffs, product stories.
5. Backend support: Go context/errors/testing, API contracts, auth, payments, idempotency, webhooks, system design.

Adjust the priority if the user states a different target role.

## Question Style

Use practical prompts:

- `explain`: ask for a concise spoken explanation.
- `debug`: show a broken snippet or scenario and ask for diagnosis.
- `code`: ask for a small type, component, function, or test shape.
- `design`: ask for boundaries, state ownership, API calls, failure modes, and tradeoffs.
- `story`: ask for context, problem, decision, tradeoff, result, and what the user would change now.

Keep story prompts short when the user is tired or time-limited. Prefer 2-3 polished reusable stories over many raw stories.

## Correction Style

Be direct and detailed:

- Start with the score.
- Say what was correct.
- Correct wrong terminology and unsafe claims.
- Show a compact code or architecture example when it makes the gap concrete.
- Explain what would matter in a senior interview.
- End with one next question only.

Do not flatter. Do not overwhelm. Keep the correction proportional to the risk.

## Repository Integration

When working inside a markdown learning repo:

- Read existing assessment docs before starting if present.
- Use the repo's scoring model and topic range if available.
- When wrapping up, update the smallest useful set of files:
  - daily/session note
  - coverage tracker
  - progress dashboard
  - review queue
- Link evidence to the dated session note.
- Do not add prepared question lists.

If no repo conventions exist, keep results in the chat unless the user asks for files.

## Wrap-Up Output

When the user asks to wrap up, provide:

- target identity assessed
- topics touched
- strongest signals
- weak/high-risk areas
- next 3 drills
- files updated, if any
