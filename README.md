"# TCA : TRT-Service Central Administration Server 20220114

Production-ready Spring Boot starter template for TCA Server with comprehensive configuration management, security, and logging.

## Quick Start

### Prerequisites
- Java 17+
- Maven 3.6+
- PostgreSQL 12+

### Local Development

1. **Setup Database**
```bash
# Create PostgreSQL database
createdb tca-server-20220114
psql -U postgres -d tca-server-20220114 -c "ALTER USER postgres WITH PASSWORD 'ps@admin';"
```

2. **Build & Run**
```bash
mvn clean install
mvn spring-boot:run
```

Application: `http://localhost:8080/tca`

## Project Structure

```
├── config/
│   ├── logback-local.xml        # Local logging (DEBUG, console + file)
│   ├── logback-prod.xml         # Production logging (WARN, file only)
│   └── keystores/
│       ├── client-certificates/  # Client SSL/TLS certificates
│       └── server-certificates/  # Server SSL/TLS certificates
├── vars/
│   ├── local/
│   │   └── values.properties    # Local environment config
│   └── prod/
│       └── values.properties    # Production environment config
├── src/main/java/com/trt/
│   ├── framework/               # Shared framework components
│   │   ├── config/              # Security & application configs
│   │   ├── dto/                 # API response DTOs
│   │   └── exception/           # Global exception handling
│   └── ...                      # Application-specific code
├── pom.xml                      # Maven dependencies
└── README.md
```

## Configuration

### Environment Profiles
- **Local**: `spring.profiles.active=local` (DEBUG logging, dev database)
- **Production**: `spring.profiles.active=prod` (WARN logging, prod database)

### Key Features
- ✅ Spring Security with JWT support
- ✅ PostgreSQL database integration
- ✅ Global exception handling
- ✅ Standardized API responses
- ✅ Environment-specific logging
- ✅ SSL/TLS certificate support
- ✅ Spring Boot Actuator monitoring
- ✅ Lombok for reduced boilerplate
- ✅ CORS configuration
- ✅ Input validation

## API Response Format

### Success
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { },
  "timestamp": "2026-09-14T03:15:00"
}
```

### Error
```json
{
  "timestamp": "2026-09-14T03:15:00",
  "status": 400,
  "error": "Validation Failed",
  "message": "Input validation failed",
  "validationErrors": { "field": "error message" },
  "path": "/api/v1/endpoint"
}
```

## Documentation

- **[SETUP.md](SETUP.md)** - Detailed setup and deployment guide
- **[DATABASE.md](DATABASE.md)** - Database configuration and management
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Code standards and contribution guidelines
- **[config/keystores/client-certificates/README.md](config/keystores/client-certificates/README.md)** - Client SSL/TLS setup
- **[config/keystores/server-certificates/README.md](config/keystores/server-certificates/README.md)** - Server SSL/TLS setup

## Available Endpoints

- Health Check: `/health`
- Metrics: `/actuator/metrics`
- Info: `/actuator/info`

## Database

- **Type**: PostgreSQL
- **Database**: `tca-server-20220114`
- **User**: `postgres`
- **Password**: `ps@admin` (change in production)
- **Host**: `localhost:5432` (local) / `prod-db-host:5432` (prod)

## SSL/TLS Configuration

### Generate Certificates

```bash
# Server certificates
cd config/keystores/server-certificates/
# Follow instructions in README.md

# Client certificates  
cd config/keystores/client-certificates/
# Follow instructions in README.md
```

### Enable HTTPS

Update `vars/prod/values.properties`:
```properties
server.ssl.enabled=true
server.port=8443
server.ssl.key-store=file:config/keystores/server-keystore.jks
server.ssl.key-store-password=changeit
```

## Technologies

- Spring Boot 3.3.5
- Spring Security
- Spring Data JPA
- PostgreSQL
- JWT (JJWT 0.12.6)
- Lombok
- Logback
- Maven

## License

Proprietary - TRT Technologies

## Support

For issues and questions, please contact the development team.
" 

