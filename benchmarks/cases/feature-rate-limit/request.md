Add rate limiting to the public API in this project.

Spec:

- Applies to every route under `/api/` (current and future), per client IP.
- Fixed window: maximum 5 requests per 10 seconds per IP. The window resets 10 seconds after it opened.
- Over the limit: respond HTTP 429 with JSON body `{"error":"rate_limited"}` and a `Retry-After` header holding the integer number of seconds until the window resets (minimum 1).
- `/health` (and any non-`/api/` path) is never rate-limited.
- In-memory state only, no persistence needed across restarts.

Constraints: keep the server starting with `node server.js` and honoring the `PORT` env variable, no new dependencies, existing `/api/` responses unchanged when under the limit.
