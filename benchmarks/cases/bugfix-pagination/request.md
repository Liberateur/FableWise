Users report a paging bug in this items API:

- `GET /items?page=1&limit=10` should return items 1–10 but returns items 11–20. The first `limit` items are unreachable through paging.
- `total_pages` reports 5 for 57 items with `limit=10`; users expect 6 — the last, partial page counts as a page.

Fix the paging so that page 1 starts at the first item, every page follows without gap or overlap, and `total_pages` counts the final partial page.

Constraints: keep the JSON response shape unchanged, keep the server starting with `node server.js` and honoring the `PORT` env variable, no new dependencies.
