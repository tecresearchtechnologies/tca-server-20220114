# Properties Files - Usage & Security Guide

## Where Properties Are Used

### 1. Application Properties Loaded by Spring Boot

**File**: `src/main/resources/application.properties`

```properties
spring.config.import=classpath:values/local/values.properties
spring.application.name=${app.name}
spring.application.version=${app.version}

# Server
server.port=${server.port}
server.servlet.context-path=${server.servlet.context-path}

# Database
spring.datasource.url=${spring.datasource.url}
spring.datasource.username=${spring.datasource.username}
spring.datasource.password=${spring.datasource.password}
# ... etc
```

### 2. Code Usage - Where Values Are Injected

**SecurityConfig.java**:
- Uses Spring Security settings
- Loads SSL/TLS certificates

**LoggingConfiguration** (logback-spring.xml):
- `logging.file.path` - Log directory
- `logging.level.root` - Root log level
- `logging.level.com.application` - App log level

**Database Connection** (HikariCP):
- `spring.datasource.url` - Connection string
- `spring.datasource.username` - DB user
- `spring.datasource.password` - DB password

**Server Configuration** (Tomcat):
- `server.port` - Listen port
- `server.servlet.context-path` - Context path

**Actuator**:
- `management.endpoints.web.exposure.include` - Which endpoints to expose
- `management.endpoint.health.show-details` - Health detail level

---

## Sensitive vs Non-Sensitive Values

### ❌ SHOULD NOT PUSH TO GIT (Sensitive)

```properties
# Database passwords
spring.datasource.password=ps@admin                    # NEVER COMMIT

# SSL/TLS passwords
server.ssl.key-store-password=changeit                 # NEVER COMMIT
server.ssl.trust-store-password=changeit               # NEVER COMMIT

# API credentials
sonar.login=${SONAR_TOKEN}                             # NEVER COMMIT
app.api.key=secret-key-12345                           # NEVER COMMIT

# Private keystore paths
server.ssl.key-store=file:/config/keystores/server-keystore.jks  # MAYBE (path only)
```

### ✅ CAN PUSH TO GIT (Non-Sensitive)

```properties
# Application metadata
app.name=TCA Server                                     # OK - public name
app.version=1.0.0                                       # OK - version info
app.environment=local                                  # OK - environment indicator

# Server settings
server.port=8080                                        # OK - standard port
server.servlet.context-path=/tca                        # OK - public path

# Database host (no credentials)
spring.datasource.url=jdbc:postgresql://localhost:5432/tca-server-20220114  # OK - no password

# Logging
logging.level.root=INFO                                 # OK - log level
logging.file.path=logs                                  # OK - path pattern

# Timeouts
app.api.timeout=30000                                   # OK - timeout value
app.api.retry.count=3                                   # OK - retry count

# Actuator (controlled exposure)
management.endpoints.web.exposure.include=health,metrics,info  # OK
```

---

## Recommended Security Setup

### 1. Create Secrets-Only Properties Files

Create `vars/secrets/` folder (git-ignored) for sensitive values:

```
vars/
├── local/
│   └── values.properties           # Non-sensitive (PUSH to git)
├── prod/
│   └── values.properties           # Non-sensitive (PUSH to git)
├── docker/
│   └── values.properties           # Non-sensitive (PUSH to git)
├── cicd/
│   └── values.properties           # Non-sensitive (PUSH to git)
└── secrets/
    ├── local-secrets.properties    # Sensitive (DO NOT PUSH)
    ├── prod-secrets.properties     # Sensitive (DO NOT PUSH)
    ├── docker-secrets.properties   # Sensitive (DO NOT PUSH)
    └── cicd-secrets.properties     # Sensitive (DO NOT PUSH)
```

### 2. Update .gitignore

```gitignore
# Environment and secrets
.env
.env.*
*.env
vars/secrets/
vars/**/*secrets*
vars/**/*password*
vars/**/*key*
vars/**/*token*
vars/**/*credential*

# CI/CD secrets
.github/secrets/
.jenkins/secrets/

# Local overrides
application-local.properties
application-prod.properties
```

### 3. Split Properties Files

**vars/local/values.properties** (PUSH to git):
```properties
app.name=TCA Server
app.version=1.0.0
app.environment=local
server.port=8080
server.servlet.context-path=/tca

# Database host only (no password)
spring.datasource.url=jdbc:postgresql://localhost:5432/tca-server-20220114

# Logging
logging.level.root=INFO
logging.file.path=logs

# Timeouts
app.api.timeout=30000
app.api.retry.count=3
```

**vars/secrets/local-secrets.properties** (DO NOT PUSH):
```properties
# Database credentials
spring.datasource.username=postgres
spring.datasource.password=ps@admin

# SSL/TLS
server.ssl.key-store-password=changeit

# API keys
app.api.key=secret-key-12345
sonar.token=abcd1234...
```

### 4. Load Multiple Properties Files

Update `src/main/resources/application.properties`:
```properties
# Load non-sensitive properties
spring.config.import=classpath:values/local/values.properties

# Optionally load secrets if available
spring.config.import+=optional:file:./vars/secrets/local-secrets.properties
```

### 5. CI/CD Secret Management

**GitHub Actions** (.github/workflows/build.yml):
```yaml
- name: Create secrets file
  env:
    DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  run: |
    mkdir -p vars/secrets
    cat > vars/secrets/cicd-secrets.properties << EOF
    spring.datasource.password=${DB_PASSWORD}
    sonar.login=${SONAR_TOKEN}
    EOF
```

**Jenkins** (Jenkinsfile):
```groovy
pipeline {
    stages {
        stage('Create Secrets') {
            steps {
                withCredentials([
                    string(credentialsId: 'db-password', variable: 'DB_PASSWORD'),
                    string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')
                ]) {
                    sh '''
                        mkdir -p vars/secrets
                        echo "spring.datasource.password=${DB_PASSWORD}" > vars/secrets/cicd-secrets.properties
                        echo "sonar.login=${SONAR_TOKEN}" >> vars/secrets/cicd-secrets.properties
                    '''
                }
            }
        }
    }
}
```

---

## Recommended File Structure

### vars/local/values.properties (PUSH to git)
```properties
# Application
app.name=TCA Server
app.version=1.0.0
app.environment=local

# Server
server.port=8080
server.servlet.context-path=/tca

# Database (URL only, no password)
spring.datasource.url=jdbc:postgresql://localhost:5432/tca-server-20220114
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect

# Logging
logging.level.root=INFO
logging.level.com.application=DEBUG
logging.file.path=logs

# Actuator
management.endpoints.web.exposure.include=health,metrics,info
management.endpoint.health.show-details=always

# Application
app.api.timeout=30000
app.api.retry.count=3
app.file.upload.path=/tmp/uploads
```

### vars/secrets/local-secrets.properties (DO NOT PUSH)
```properties
# Database credentials
spring.datasource.username=postgres
spring.datasource.password=ps@admin

# SSL/TLS
server.ssl.key-store-password=changeit
server.ssl.trust-store-password=changeit

# Keystore paths (if using local files)
server.ssl.key-store=file:./config/keystores/server-keystore.jks
server.ssl.trust-store=file:./config/keystores/server-truststore.jks
```

### vars/prod/values.properties (PUSH to git)
```properties
# Application
app.name=TCA Server
app.version=1.0.0
app.environment=production

# Server
server.port=8080
server.servlet.context-path=/tca
server.ssl.enabled=true

# Database (URL only)
spring.datasource.url=jdbc:postgresql://prod-db-host:5432/tca-server-20220114
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect

# Logging
logging.level.root=WARN
logging.level.com.application=INFO
logging.file.path=/var/logs

# Actuator
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=when-authorized

# Application
app.api.timeout=60000
app.api.retry.count=5
app.file.upload.path=/var/uploads
```

### vars/secrets/prod-secrets.properties (DO NOT PUSH)
```properties
# Database credentials
spring.datasource.username=postgres
spring.datasource.password=ENCRYPTED_PASSWORD_12345

# SSL/TLS
server.ssl.key-store-password=ENCRYPTED_KEYSTORE_PASS
server.ssl.trust-store-password=ENCRYPTED_TRUSTSTORE_PASS
server.ssl.key-store=file:/etc/tca/keystores/server-keystore.jks
server.ssl.trust-store=file:/etc/tca/keystores/server-truststore.jks

# API credentials
sonar.login=SONAR_TOKEN_PRODUCTION
app.external.api.key=API_KEY_PRODUCTION
```

---

## Where Each Value Is Used

| Property | Location Used | Type | Should Push? |
|----------|---------------|------|-------------|
| `app.name` | Application startup logs, actuator/info | Non-sensitive | ✅ YES |
| `app.version` | Application startup logs | Non-sensitive | ✅ YES |
| `app.environment` | Logs, monitoring | Non-sensitive | ✅ YES |
| `spring.profiles.active` | Spring Profile activation | Non-sensitive | ✅ YES |
| `server.port` | Tomcat configuration | Non-sensitive | ✅ YES |
| `server.servlet.context-path` | Application routing | Non-sensitive | ✅ YES |
| `server.ssl.enabled` | SSL/TLS activation | Non-sensitive | ✅ YES |
| `spring.datasource.url` | Database connection string | Non-sensitive | ✅ YES |
| `spring.datasource.username` | Database authentication | **SENSITIVE** | ❌ NO |
| `spring.datasource.password` | Database authentication | **SENSITIVE** | ❌ NO |
| `server.ssl.key-store` | SSL/TLS certificate location | Non-sensitive | ✅ YES |
| `server.ssl.key-store-password` | SSL/TLS certificate access | **SENSITIVE** | ❌ NO |
| `logging.level.root` | Log level configuration | Non-sensitive | ✅ YES |
| `logging.file.path` | Log directory | Non-sensitive | ✅ YES |
| `management.endpoints.web.exposure.include` | Actuator endpoints | Non-sensitive | ✅ YES |
| `app.api.timeout` | Request timeout | Non-sensitive | ✅ YES |
| `app.api.retry.count` | Retry logic | Non-sensitive | ✅ YES |
| `app.file.upload.path` | File storage path | Non-sensitive | ✅ YES |

---

## Best Practices Summary

### ✅ DO:
- Commit non-sensitive configuration (names, versions, paths, URLs without passwords)
- Use .gitignore to protect sensitive files
- Store secrets in CI/CD platform secrets management
- Use encryption for sensitive data
- Document which properties are secrets
- Rotate secrets regularly
- Use environment-specific secret files

### ❌ DON'T:
- Commit database passwords
- Commit SSL/TLS keystore passwords
- Commit API keys or tokens
- Commit private certificates
- Use default passwords in production
- Store secrets in code comments
- Commit .env files with secrets
- Share secrets across environments

### 🔐 External Secrets Management:
- **AWS**: Secrets Manager, Systems Manager Parameter Store
- **Azure**: Key Vault
- **Google Cloud**: Secret Manager
- **HashiCorp**: Vault
- **GitHub**: GitHub Secrets
- **GitLab**: CI/CD Variables
- **Jenkins**: Credentials Plugin
- **Kubernetes**: Secrets

This approach ensures your repository is safe while maintaining configuration flexibility!
