# Apache Superset — Developer Lessons & Best Practices

This document chronicles the gotchas, operational rigor, and architecture quirks learned while developing native features (such as the Scenario chart plugin) for Apache Superset.

---

## 1. Backend: Flask APIs & Authentication

- **Securing Custom Endpoints:** Custom API routes must inherit from `BaseSupersetView` and utilize the `@has_access_api` decorator to ensure that Flask AppBuilder (FAB) enforces token/cookie-based permissions.
- **Permission Syncing (The "403 Forbidden" Trap):** Merely defining a new class with `@expose` is not enough. If you get `403 Forbidden` accessing your new endpoint as an Admin, **you must run `superset init`**. This syncs your newly defined views with the FAB permission tables in the database so that the `Admin` role is granted access string rules like `can_writeback` on `ScenarioWritebackView`.
- **Safe View Registration (`FLASK_APP_MUTATOR`):** Never import your custom views directly at the top level of `superset_config.py`. It will trigger premature evaluation and crash the app with `"RuntimeError: Working outside of application context"` or missing module errors. Instead, use a deferred mutator pattern:

  ```python
  def FLASK_APP_MUTATOR(app):
      from superset.extensions import appbuilder
      from superset.views.scenario_writeback import ScenarioWritebackView
      appbuilder.add_view_no_menu(ScenarioWritebackView)
  ```

- **Fetching the Active User:** After decorators succeed, the user's data can be plucked dynamically from `flask_login.current_user`. However, fallback handling is needed as attribute shapes vary if they differ based on the auth proxy in use (e.g., checking `email`, `username`, then `id`).

## 2. Frontend: `@superset-ui` React Plugin Architecture

- **TypeScript Build Traps (`plugin:build`):** When building via `npm run plugins:build`, TypeScript strictly enforces usage. In `buildQuery.ts`, merging arrays directly (e.g. `[...columns, ...groupby]`) often triggers `TS2488 (Numeric argument required/must have a [Symbol.iterator]())`. Always wrap arrays safely with `@superset-ui/core`'s `ensureIsArray` and explicitly cast the return type:

  ```typescript
  columns: [
    ...ensureIsArray(baseQueryObject.columns),
    ...ensureIsArray(baseQueryObject.groupby),
  ] as QueryFormColumn[]
  ```

- **Error Handling on `SupersetClient.post`:** When catching a failed promise from `SupersetClient`, the API response is wrapped. Check `error?.json?.message` instead of just `error.message` to avoid showing obscure `[object Object]` strings to the user in `notification.error`.
- **Optimistic UI Requires Stable Data Structures:** Superset passes down data via `queriesData`. It is read-only. For an editable feature, copy this data into local `useState` objects (or mapping dictionaries) on intercept inside `transformProps.ts` and component `useEffect` triggers.

## 3. Playwright E2E Testing

- **Catching Network Responses:** Native playwright `page.waitForResponse` must be established *before* the action that triggers the network request (blurring an input field or clicking a submit button).

  ```typescript
  const requestPromise = page.waitForResponse(r => r.url().includes('/api/v1/scenario/writeback'));
  await input.fill('70');
  await input.blur();
  const response = await requestPromise;
  expect(response.status()).toBe(200);
  ```

- **State Expiraton Fallbacks:** Utilizing `storageState: 'playwright/.auth/user.json'` is fast, but CI checks might invalidate cookies. Always add a programmatic fallback inside the test to re-fill login info gracefully if `page.url().includes('login')` is caught.

## 4. Configuration & Runtime Nuances (`superset_config.py`)

- **PYTHONPATH Hell:** Do not globally set or override the `PYTHONPATH` context variable when running your customized `superset run` server. Doing so forces `import superset` to evaluate the open workspace root as a namespace folder, ignoring the installed editable `.venv` files under it, which shatters dependency mappings.
- **Symlinking the Config:** For local configurations held cleanly outside the git folder boundaries (e.g. `../superset_config.py`), it is much cleaner to dynamically symbol-link (`ln -sf`) it into the main backend `superset/` folder during startup in a bash bootloader than fighting with absolute path python overrides.
- **Handling Empty Strings vs NULL in SQL `ON CONFLICT` constraints:** When constructing backend UPSERT models, specifically for SQLite, ensure that column constraints heavily depend on strict non-NULL unique signatures. E.g., defaulting missing strings to `''` instead of `None` prevents unpredictable constraint bypasses.

## 5. Custom View Registration (The Two-Step Trap)

- **Always register in `initialization/__init__.py`**, not in `FLASK_APP_MUTATOR`. The `FLASK_APP_MUTATOR` in `superset_config.py` is unreliable for view registration -- it may not execute during the Flask reloader's subprocess lifecycle.
- Add the import alongside existing views (line ~225 area) and the `appbuilder.add_view_no_menu()` call alongside existing registrations (line ~454 area).
- **After adding a new view**, run `superset init` to sync the FAB permission tables. Without this, the Admin role won't have `can_<method_name>` permissions and all requests return 403 "Access is Denied".
- **`FLASK_APP_MUTATOR` catches**: If you use `except ImportError`, be aware that Superset's import chain can raise generic `Exception` (e.g., `"App not initialized yet"`), not `ImportError`. Use `except Exception` if you must catch in the mutator.
- **JWT vs Session auth**: `@has_access_api` on `BaseSupersetView` does NOT work with JWT Bearer tokens from curl. It requires session cookies (which `SupersetClient` handles automatically in the browser). Use form-based login for curl testing.

## 6. Security & Dev Mode CORS

- Ensure `SUPERSET_SECRET_KEY` is loaded from the environment defensively; do not provide a fallback in code strings.
- Be highly targeted with CORS configuration. During UI local development (`localhost:9000` interacting with `localhost:8088`), specify exact `origins` within `CORS_OPTIONS` if `supports_credentials: True` is enabled. Setting cross-origin `*` alongside authorized credentials will be blocked by major browser preflight checks.
