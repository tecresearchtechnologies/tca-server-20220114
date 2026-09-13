# Environment Variables Documentation

## Folder Structure

```
vars/
├── local/              # Local development environment
│   └── .env.local      # Developer machine configuration
│
├── prod/               # Production environment
│   └── .env.prod       # Production server configuration
│
├── docker/             # Docker container environment
│   └── .env.docker     # Docker Compose configuration
│
└── cicd/               # CI/CD pipeline environment
    └── .env.cicd       # GitHub Actions / Jenkins configuration
```

## Usage

### Local Development
```bash
# Load local environment
set -a
source vars/local/.env.local
set +a

# Run Maven
mvn spring-boot:run
```

### Docker Deployment
```bash
# Docker Compose will automatically load vars/docker/.env.docker
docker-compose --env-file vars/docker/.env.docker up
```

### CI/CD Pipeline (GitHub Actions)
```yaml
# .github/workflows/build.yml
env:
  - name: Load CI/CD environment
    run: cat vars/cicd/.env.cicd >> $GITHUB_ENV
```

### Production Deployment
```bash
# Load production environment
export $(cat vars/prod/.env.prod | xargs)
java -jar target/tca-server.jar
```

## Environment Variables Reference

### Common Variables
- `APP_NAME` - Application name
- `APP_VERSION` - Application version
- `APP_ENVIRONMENT` - Current environment (local/prod/docker/cicd)
- `SPRING_PROFILES_ACTIVE` - Active Spring profile

### Database
- `SPRING_DATASOURCE_URL` - Database connection URL
- `SPRING_DATASOURCE_USERNAME` - Database user
- `SPRING_DATASOURCE_PASSWORD` - Database password

### Server
- `SERVER_PORT` - Application port
- `SERVER_SERVLET_CONTEXT_PATH` - Context path

### Logging
- `LOGGING_LEVEL_ROOT` - Root log level
- `LOGGING_LEVEL_COM_APPLICATION` - Application log level
- `LOGGING_FILE_PATH` - Log file directory

### Application
- `APP_API_TIMEOUT` - API timeout in milliseconds
- `APP_API_RETRY_COUNT` - Number of retries
- `APP_FILE_UPLOAD_PATH` - File upload directory

## Security Best Practices

⚠️ **Never commit sensitive values to version control:**
- Database passwords
- API keys
- Private certificates
- Secret tokens

Use CI/CD secrets management:
- GitHub Secrets
- Jenkins Credentials
- GitLab CI Variables
- HashiCorp Vault

## Environment-Specific Behavior

### Local Environment
- Log level: INFO (verbose)
- Database: Local PostgreSQL
- Upload path: `/tmp/uploads`
- Actuator: Full exposure (health, metrics, info)

### Production Environment
- Log level: WARN (minimal)
- Database: Remote PostgreSQL
- Upload path: `/var/uploads`
- Actuator: Limited exposure (health, info only)
- SSL/TLS: Enabled

### Docker Environment
- Log level: INFO
- Database: Docker service (`postgres:5432`)
- Upload path: `/app/uploads`
- Memory: 512MB max, 256MB min
- Logs: `/app/logs`

### CI/CD Environment
- Log level: WARN (except app DEBUG)
- Database: Test database (auto-created)
- DDL: create-drop (fresh each run)
- Sonar integration enabled
- Memory: 1024MB max, 512MB min
