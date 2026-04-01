---
name: Auth middleware rewrite driven by compliance
description: Auth middleware rewrite is driven by legal/compliance requirements around session token storage, not tech debt
type: project
---

Auth middleware rewrite is driven by legal/compliance requirements around session token storage, not tech-debt cleanup.

**Why:** Legal flagged the old middleware for storing session tokens in a way that doesn't meet new compliance requirements. This is not optional.

**How to apply:** Scope decisions should favor compliance over ergonomics. Don't simplify the token handling if it means losing audit trail capabilities.
