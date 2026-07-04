# Plan : Rate limiting on the public API

> **Statut** : 🟢 validé
> **Run en cours** : —
> **Escalades Fable** : 0/5
> **Demande d'origine** : "add rate-limiting to the public API"
> **Énoncé consolidé** : Per-IP rate limiting on all `/api/public/*` routes (sliding window, 429 + Retry-After), limits configurable per route group, in-memory store now with a clean interface for Redis later. Admin routes excluded (user decision, gate of 2026-07-03).
> **Créé** : 2026-07-03 · **Rédigé par** : Fable (session /plan)
> **Conso cumulée** : conception $1.10 · runs $0 (0 runs) · **total $1.10** · **dont Fable 14k tokens**

## Contexte

Express 4 app, entry `src/app.js`; public routes mounted in `src/routes/public.js` (12 endpoints, 3 groups: search, read, submit). Existing middlewares in `src/middleware/` follow the pattern `module.exports = opts => (req, res, next) => {…}`. Config lives in `src/config/index.js` (env-driven). Test runner: `npm test` (jest, tests in `tests/`). Smoke test: `npm run dev:check` (boots server, hits `/healthz`).

## Décisions & arbitrages

- Sliding-window counter per IP+group, not fixed window — burst-proof at boundaries; token bucket rejected as overkill for 3 groups (Fable, confirmed at gate).
- Store behind `RateStore` interface (`incr(key, windowMs)`) — in-memory Map now, Redis later without touching the middleware.
- 429 body follows the existing error envelope of `src/middleware/error.js`; `Retry-After` in seconds.
- Admin routes excluded (user decision at gate).

## Contrat d'exécution

Ce plan est appliqué par une session **Sonnet** (`/plan-run`) qui suit les modes opératoires à la lettre et constate les critères sur pièces. Pour chaque tâche : application → constat des critères → si échec, 1 retry → si nouvel échec, Plan B s'il existe (`[risque: haut]`) → sinon **arrêt du run** : la session n'invente rien, écrit une `Synthèse de blocage` dans la tâche (nature, tentatives, pièces, options, champ `Directive de reprise` vide) et rend la main. L'utilisateur fait arbitrer la synthèse par **Fable**, reporte la décision dans `Directive de reprise`, puis relance `/plan-run`.

## Pre-mortem

The plan failed because the sliding-window counter keyed on `req.ip` returned the proxy's address in production — every user shared one bucket and the API rate-limited itself into a 429 storm within minutes. The fix (`app.set('trust proxy', …)`) existed but nobody had checked how the app derives client IPs behind the load balancer. Secondary cause: T3's in-memory Map grew unbounded because expired windows were never pruned. → Converted: T2 criterion #3 (trust-proxy verified with forwarded-header test) and T2 Plan B; T3 criterion #2 (pruning verified).

## Tâches

### T0 — Verify environment smoke-test `[deps: —]` `[statut: ⬜]` `[touche: —]`

- **Quoi** : Confirm the environment contract before any work.
- **Méthode** : Run the existing `npm run dev:check`; no new script needed (alternative — writing a dedicated verify.sh — rejected: the project already has one).
- **Mode opératoire** :
  1. Run `npm ci` → expect exit 0.
  2. Run `npm run dev:check` → expect `healthz OK` on stdout.
  3. Run `npm test` → expect all suites green (baseline).
- **Contexte** : `package.json` scripts section.
- **Rendu attendu** : Confirmation report only — no file changes.
- **Critères de complétion (1-4, binaires, vérifiables)** :
  1. `npm run dev:check` exits 0 with `healthz OK`.
  2. `npm test` exits 0.
- **Journal** :

### T1 — Write failing acceptance tests `[deps: T0]` `[statut: ⬜]` `[touche: tests/rate-limit.test.js]`

- **Quoi** : Acceptance tests for the limiter, written first, committed, then frozen.
- **Méthode** : Supertest against the real app with a tiny test window (via config override), not unit tests of the store — the behavior under test is HTTP semantics (alternative rejected: mocking the clock everywhere, brittle).
- **Mode opératoire** :
  1. Read `tests/helpers/app.js` — quote the export signature before use.
  2. Create `tests/rate-limit.test.js` with cases: under-limit passes; over-limit returns 429 + `Retry-After`; separate IPs have separate buckets; window slides (request allowed again after windowMs); admin route never limited.
  3. Run `npm test -- rate-limit` → expect **all new tests FAIL** (module not implemented).
  4. Commit: `fablewise: T1 acceptance tests (red)`.
- **Contexte** : `tests/helpers/app.js`, jest config in `package.json`.
- **Rendu attendu** : `tests/rate-limit.test.js`, committed, red.
- **Critères de complétion** :
  1. File exists and `npm test -- rate-limit` shows the 5 cases failing (not erroring).
  2. Commit present in `git log`.
- **Journal** :

### T2 — Implement the limiter middleware `[deps: T1]` `[statut: ⬜]` `[risque: haut]` `[touche: src/middleware/rate-limit.js, src/config/index.js]`

- **Quoi** : Sliding-window per-IP limiter behind a `RateStore` interface, per-group limits from config.
- **Méthode** : Sliding window log-lite (two adjacent fixed windows, weighted) over a Map store — O(1) memory per key vs true log; token bucket rejected (D-in-plan #1).
- **Mode opératoire** :
  1. Create `src/middleware/rate-limit.js` exporting `opts => (req,res,next)` per house pattern (quote the pattern from `src/middleware/error.js` first).
  2. Implement `MemoryRateStore` with `incr(key, windowMs)` and expiry pruning on access.
  3. Key = `${clientIp}:${group}`; derive `clientIp` via `req.ip` AND verify `trust proxy` handling (step 5).
  4. On limit exceeded: 429 through the existing error envelope + `Retry-After` (seconds, integer, ≥1).
  5. Add a test asserting the client IP is derived from `X-Forwarded-For` when `trust proxy` is enabled — if the app never sets `trust proxy`, STOP: blocking report (pre-mortem cause #1), do not guess.
  6. Add per-group limits to `src/config/index.js` (env-driven, defaults documented in comment).
  7. `npm test -- rate-limit` → all T1 tests green, **without touching them**.
- **Contexte** : `src/middleware/error.js` (envelope), `src/config/index.js` (config pattern).
- **Rendu attendu** : middleware + store + config keys.
- **Critères de complétion** :
  1. `npm test -- rate-limit` exits 0.
  2. `git diff tests/rate-limit.test.js` is empty (frozen tests untouched).
  3. Forwarded-header test present and green (pre-mortem).
- **Plan B** : If the two-window approximation fails the sliding test, fall back to exact timestamp-list-per-key (bounded by maxHits per window, pruned on incr) — simpler, slightly more memory, same interface; steps: replace `incr` internals only, rerun tests.
- **Journal** :

### T3 — Wire routes + config docs `[deps: T2]` `[statut: ⬜]` `[groupe: A]` `[touche: src/routes/public.js, README.md]`

- **Quoi** : Mount the middleware on the 3 public route groups; document the config keys.
- **Méthode** : One `rateLimit({group})` per router group at mount point — not per-endpoint (12 duplications rejected).
- **Mode opératoire** :
  1. Quote the current mount lines in `src/routes/public.js`; insert `rateLimit({ group: 'search'|'read'|'submit' })` before each group router.
  2. Append a "Rate limiting" section to README.md listing the env keys from T2 step 6 and the 429 semantics.
  3. `npm test` → full suite green.
- **Critères de complétion** :
  1. `npm test` exits 0.
  2. `grep -c rateLimit src/routes/public.js` returns 3.
- **Journal** :

### T4 — End-to-end check `[deps: T3]` `[statut: ⬜]` `[groupe: A]` `[touche: —]` `[contexte: lourd]`

- **Quoi** : Prove the wired app limits for real, outside jest.
- **Mode opératoire** :
  1. `npm run dev:check` → healthy.
  2. Boot dev server; loop `curl -s -o /dev/null -w "%{http_code}\n"` N+1 times on a search endpoint (N = configured limit) → expect the last call to print `429` and a `Retry-After` header via `curl -sI`.
- **Critères de complétion** :
  1. Loop output shows 200×N then 429.
  2. `Retry-After` header present on the 429.
- **Journal** :

## Rapport de run

<!-- Rempli par /plan-run. -->
