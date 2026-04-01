---
name: Integration tests must use real database
description: Never mock the database in integration tests — prior incident where mock/prod divergence masked a broken migration
type: feedback
---

Integration tests must hit a real database, not mocks.

**Why:** Last quarter, mocked tests passed but the prod migration failed — mock/prod divergence masked a broken schema change. Took 2 days to diagnose.

**How to apply:** When writing or reviewing test files in `tests/integration/`, verify they use the test database connection, not mock objects. If a test needs DB isolation, use transactions with rollback.
