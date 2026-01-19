# skills/backend-patterns.md
---
name: backend-patterns
description: API and backend best practices
---

## API Design
- RESTful conventions
- JSON response format:
  {
    "data": {},
    "error": null,
    "meta": {}
  }

## Error Handling
- Try-catch everywhere
- Structured error responses
- Logging

## Database
- Use ORM (SQLAlchemy/Prisma)
- Migrations for schema changes
- Connection pooling

## Security
- Input validation
- SQL injection prevention
- CORS configuration
