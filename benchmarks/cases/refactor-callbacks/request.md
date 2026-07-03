Modernize `store.js`, the file-backed key-value store in this project:

- Expose a promise-based API as `module.exports.promises` — `get(key)`, `set(key, value)`, `del(key)`, `list()`, all async, exact same semantics as the callback versions (missing key → `null`, `list` → sorted keys).
- Refactor the internals to async/await on `fs.promises`; the callback API becomes a thin wrapper over the promise implementation.
- The existing callback API (`get`, `set`, `del`, `list` with a trailing callback) must keep working unchanged.

Hard constraint: **do NOT modify `store.test.js`** — it must pass as-is (`npm test`) after the refactor. No new dependencies.
