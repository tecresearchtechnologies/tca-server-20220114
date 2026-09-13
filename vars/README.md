# Environment Configuration Variables

## Folder Structure

```
vars/
├── local/              # Local development environment
│   └── values.properties      # Developer machine configuration
│
├── prod/               # Production environment
│   └── values.properties      # Production server configuration
│
├── docker/             # Docker container environment
│   └── values.properties      # Docker Compose configuration
│
└── cicd/               # CI/CD pipeline environment
    └── values.properties      # GitHub Actions / Jenkins configuration
```

## Usage

### Development Setup

1. **Copy to classpath** (Spring Boot loads these):
```bash
cp vars/local/values.properties src/main/resources/values/local/
cp vars/prod/values.properties src/main/resources/values/prod/
```

2. **Run application**:
```bash
mvn spring-boot:run
```

### Docker Deployment

Mount the properties file in docker-compose.yml:
```yaml
services:
  tca-server:
    build: .
    volumes:
      - ./vars/docker/values.properties:/app/config/values.properties
    environment:
      SPRING_CONFIG_LOCATION: file:/app/config/
```

### CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/build.yml
- name: Copy CI/CD configuration
  run: cp vars/cicd/values.properties src/main/resources/values/local/values.properties
  
- name: Build
  run: mvn clean package
```

## Configuration Files

### Local Configuration (vars/local/values.properties)
- **Profile**: local
- **Log Level**: INFO (verbose)
- **Database**: Local PostgreSQL (localhost:5432)
- **Upload Path**: /tmp/uploads
- **Actuator**: Full exposure (health, metrics, info)
- **DDL**: update (auto-create tables)

```properties
spring.profiles.active=local
logging.level.root=INFO
logging.level.com.application=DEBUG
spring.datasource.url=jdbc:postgresql://localhost:5432/tca-server-20220114
spring.jpa.hibernate.ddl-auto=update
```

### Production Configuration (vars/prod/values.properties)
- **Profile**: prod
- **Log Level**: WARN (minimal)
- **Database**: Remote PostgreSQL
- **Upload Path**: /var/uploads
- **Actuator**: Limited exposure (health, info only)
- **DDL**: validate (no auto-create)
- **SSL/TLS**: Enabled

```properties
spring.profiles.active=prod
logging.level.root=WARN
spring.datasource.url=jdbc:postgresql://prod-db-host:5432/tca-server-20220114
spring.jpa.hibernate.ddl-auto=validate
server.ssl.key-store=file:/config/keystores/server-keystore.jks
```

### Docker Configuration (vars/docker/values.properties)
- **Profile**: local (with docker adjustments)
- **Log Level**: INFO
- **Database**: Docker service name (postgres:5432)
- **Upload Path**: /app/uploads
- **Logs**: /app/logs
- **DDL**: update
- **Thread Limit**: 50

```properties
spring.datasource.url=jdbc:postgresql://postgres:5432/tca-server-20220114
logging.file.path=/app/logs
app.file.upload.path=/app/uploads
server.tomcat.threads.max=50
```

### CI/CD Configuration (vars/cicd/values.properties)
- **Profile**: local
- **Log Level**: WARN (app DEBUG)
- **Database**: Test database (auto-create/drop)
- **Upload Path**: /tmp/uploads
- **DDL**: create-drop (fresh each run)
- **Thread Limit**: 25

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/tca-server-test
spring.jpa.hibernate.ddl-auto=create-drop
logging.level.com.application=DEBUG
server.tomcat.threads.max=25
```

## Environment Variables Reference

### Application
- `app.name` - Application name
- `app.version` - Application version
- `app.environment` - Current environment (local/prod/docker/cicd)
- `spring.profiles.active` - Active Spring profile

### Database
- `spring.datasource.url` - PostgreSQL connection URL
- `spring.datasource.username` - Database user
- `spring.datasource.password` - Database password
- `spring.jpa.hibernate.ddl-auto` - DDL strategy (update/validate/create-drop)

### Server
- `server.port` - Application port
- `server.servlet.context-path` - Context path (/tca)
- `server.ssl.enabled` - SSL/TLS enabled flag
- `server.tomcat.threads.max` - Max threads

### Logging
- `logging.level.root` - Root log level
- `logging.level.com.application` - Application log level
- `logging.file.path` - Log file directory

### Application
- `app.api.timeout` - API timeout in milliseconds
- `app.api.retry.count` - Number of retries
- `app.file.upload.path` - File upload directory

### Actuator
- `management.endpoints.web.exposure.include` - Exposed endpoints
- `management.endpoint.health.show-details` - Health detail level

## Sync with Classpath

The `src/main/resources/values/` folder must contain the same files as `vars/`:
- `src/main/resources/values/local/values.properties` ← from `vars/local/values.properties`
- `src/main/resources/values/prod/values.properties` ← from `vars/prod/values.properties`

Use this script to sync:

**Bash** (Linux/Mac):
```bash
#!/bin/bash
cp vars/local/values.properties src/main/resources/values/local/
cp vars/prod/values.properties src/main/resources/values/prod/
echo "Configuration synced!"
```

**PowerShell** (Windows):
```powershell
Copy-Item vars/local/values.properties src/main/resources/values/local/ -Force
Copy-Item vars/prod/values.properties src/main/resources/values/prod/ -Force
Write-Host "Configuration synced!" -ForegroundColor Green
```

## Security Best Practices

⚠️ **Do NOT commit sensitive values to version control:**
- Database passwords
- API keys
- Private certificates
- Secret tokens

### Local Development
- Use default values for local PostgreSQL
- Store passwords in .env.local (git-ignored)

### Production
- Use environment-specific secure storage:
  - AWS Secrets Manager
  - HashiCorp Vault
  - GitHub Secrets (for CI/CD)
  - Jenkins Credentials
  - Kubernetes Secrets (for K8s)

### CI/CD
- Use CI/CD platform secrets management
- Never commit production credentials
- Rotate credentials regularly

## Development Workflow

1. **Local Development**:
```bash
# Sync configs
cp vars/local/values.properties src/main/resources/values/local/

# Run application
mvn spring-boot:run
```

2. **Testing Changes**:
```bash
# Update vars/local/values.properties
# Rebuild and restart
mvn clean spring-boot:run
```

3. **Prepare for Production**:
```bash
# Update vars/prod/values.properties with production settings
# Update database credentials
# Enable SSL/TLS
# Set correct logging paths
```

4. **Docker Deployment**:
```bash
# Copy docker config
cp vars/docker/values.properties src/main/resources/values/local/
docker-compose up
```

5. **CI/CD Build**:
```bash
# Pipeline automatically uses vars/cicd/values.properties
# Fresh test database each run
# Auto-cleanup after tests
```

