# rules/security.md
---
name: security
description: Security requirements
---

NEVER:
- Hardcode API keys or secrets
- Use eval() or exec()
- Trust user input without validation
- Store passwords in plain text

ALWAYS:
- Use environment variables
- Validate and sanitize inputs
- Use parameterized queries
- Implement rate limiting
