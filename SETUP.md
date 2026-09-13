# TCA Server Setup Guide

## Environment Variables

Copy `.env.example` to `.env` and configure the following:

```bash
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=tca-server-20220114
POSTGRES_USER=postgres
POSTGRES_PASSWORD=ps@admin
```

## Local Development

### Prerequisites
- Java 17+
- Maven 3.6+
- PostgreSQL 12+

### Setup
1. Clone the repository
2. Configure PostgreSQL database
3. Copy `.env.example` to `.env`
4. Run: `mvn clean install`
5. Run: `mvn spring-boot:run`

Application will be available at: `http://localhost:8080/tca`

## Production Deployment

### Configuration
- Update `vars/prod/values.properties` with production credentials
- Ensure PostgreSQL is accessible
- Configure logging paths

### Building
```bash
mvn clean package -DskipTests
```

### Docker Deployment
```bash
docker-compose -f docker-compose.yml up -d
```

## Architecture Overview

- **Security**: Spring Security with JWT authentication
- **Database**: PostgreSQL with JPA/Hibernate
- **Logging**: Logback with rolling file appenders
- **Monitoring**: Spring Boot Actuator endpoints
- **Error Handling**: Global exception handler with standardized responses

## API Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {},
  "timestamp": "2026-09-14T03:15:00"
}
```

### Error Response
```json
{
  "timestamp": "2026-09-14T03:15:00",
  "status": 400,
  "error": "Validation Failed",
  "message": "Input validation failed",
  "validationErrors": {
    "field": "error message"
  },
  "path": "/api/v1/endpoint"
}
```

## Available Endpoints

- Health Check: `/health`
- Metrics: `/actuator/metrics`
- Info: `/actuator/info`

## Project Structure

```
src/
├── main/
│   ├── java/com/trt/
│   │   ├── config/          # Configuration classes
│   │   ├── controller/      # REST controllers
│   │   ├── dto/            # Data Transfer Objects
│   │   ├── entity/         # JPA entities
│   │   ├── exception/      # Exception classes
│   │   ├── repository/     # JPA repositories
│   │   ├── service/        # Business logic
│   │   └── util/           # Utility classes
│   └── resources/
│       ├── application.properties
│       └── logback-spring.xml
└── test/
    └── java/com/trt/
        ├── controller/     # Controller tests
        └── service/        # Service tests
```
