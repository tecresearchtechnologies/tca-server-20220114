# Contributing Guide

## Code Style
- Use 4 spaces for indentation
- Follow Java naming conventions
- Keep methods focused and under 30 lines when possible
- Add comments only for complex logic

## Testing
- Write unit tests for all services
- Write integration tests for controllers
- Maintain at least 80% code coverage

```bash
mvn test
```

## Commit Messages
Format:
```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: feat, fix, docs, style, refactor, test, chore

Example:
```
feat(auth): add JWT token refresh endpoint

Added endpoint to refresh expired JWT tokens
without requiring re-authentication.

Closes #123
```

## Pull Requests
1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Run tests: `mvn test`
4. Push to branch: `git push origin feature/your-feature`
5. Create a Pull Request with a clear description

## Database Migrations
- Create migration scripts in `src/main/resources/db/migration/`
- Use consistent naming: `V001__Initial_schema.sql`

## Performance Guidelines
- Use database indexes on frequently queried columns
- Implement caching for read-heavy operations
- Use pagination for large result sets
- Profile before optimizing

## Security Checklist
- Never commit secrets or credentials
- Use parameterized queries to prevent SQL injection
- Validate all user input
- Use HTTPS in production
- Keep dependencies updated
