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

## Architecture Overview: Hexagonal (Ports & Adapters)

The application follows **Hexagonal Architecture** (Ports & Adapters pattern) to decouple the core business logic from external dependencies.

### Core Principles
- **Core Domain**: Pure business logic independent of frameworks
- **Ports**: Interfaces defining boundaries
- **Adapters**: Implementations connecting to external systems
- **Testability**: Easy to test with mock adapters
- **Flexibility**: Swap implementations without changing core logic

### Technology Stack
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

## Project Structure: Hexagonal Architecture

```
src/
├── main/
│   ├── java/com/trt/
│   │   ├── framework/                      # Shared infrastructure
│   │   │   ├── config/                     # Security & application configs
│   │   │   ├── dto/                        # Common DTOs
│   │   │   └── exception/                  # Global exception handling
│   │   │
│   │   ├── domain/                         # Core business logic (innermost hexagon)
│   │   │   ├── entity/                     # Domain entities (pure POJOs)
│   │   │   ├── value-object/               # Value objects
│   │   │   ├── service/                    # Domain services (business rules)
│   │   │   └── repository/                 # Repository port interfaces
│   │   │       ├── UserRepository.java     # (Interface/Port)
│   │   │       └── OrderRepository.java    # (Interface/Port)
│   │   │
│   │   ├── application/                    # Application/Use case layer
│   │   │   ├── port/                       # Port definitions
│   │   │   │   ├── in/                     # Input ports (Interfaces)
│   │   │   │   │   ├── CreateUserUseCase.java
│   │   │   │   │   └── GetUserUseCase.java
│   │   │   │   └── out/                    # Output ports (Interfaces)
│   │   │   │       ├── UserPersistencePort.java
│   │   │   │       └── EmailNotificationPort.java
│   │   │   │
│   │   │   └── service/                    # Use case implementations
│   │   │       ├── CreateUserService.java  # Implements CreateUserUseCase
│   │   │       └── GetUserService.java     # Implements GetUserUseCase
│   │   │
│   │   └── adapter/                        # Adapters (outermost hexagon)
│   │       ├── in/                         # Input adapters
│   │       │   ├── rest/                   # REST API adapters
│   │       │   │   ├── UserController.java
│   │       │   │   └── UserRequest.java
│   │       │   ├── graphql/                # GraphQL adapters (optional)
│   │       │   ├── grpc/                   # gRPC adapters (optional)
│   │       │   └── messaging/              # Message adapters (Kafka, RabbitMQ)
│   │       │
│   │       └── out/                        # Output adapters
│   │           ├── persistence/            # Database adapters
│   │           │   ├── UserJpaRepository.java  # Implements UserRepository
│   │           │   ├── UserJpaEntity.java
│   │           │   └── UserPersistenceAdapter.java
│   │           │
│   │           ├── external/               # External service adapters
│   │           │   ├── EmailServiceAdapter.java
│   │           │   ├── PaymentGatewayAdapter.java
│   │           │   └── NotificationAdapter.java
│   │           │
│   │           └── cache/                  # Cache adapters
│   │               └── CacheAdapter.java
│   │
│   └── resources/
│       ├── application.properties
│       └── (logback configs in config/)
│
└── test/
    └── java/com/trt/
        ├── domain/                         # Domain logic tests
        ├── application/                    # Use case tests
        ├── adapter/
        │   ├── in/                         # Input adapter tests
        │   └── out/                        # Output adapter tests
        └── integration/                    # Integration tests
```

## Hexagonal Architecture Patterns

### 1. Input Ports (Use Cases)
Interfaces that define what external systems can request from the core:

```java
public interface CreateUserUseCase {
    UserResponse createUser(CreateUserRequest request);
}
```

### 2. Output Ports
Interfaces that define external dependencies needed by the core:

```java
public interface UserPersistencePort {
    void save(User user);
    Optional<User> findById(String id);
}
```

### 3. Input Adapters
Convert external requests (REST, GraphQL) to domain models:

```java
@RestController
@RequestMapping("/api/v1/users")
public class UserController {
    private final CreateUserUseCase createUserUseCase;
    
    @PostMapping
    public ResponseEntity<UserResponse> createUser(@RequestBody CreateUserRequest request) {
        return ResponseEntity.ok(createUserUseCase.createUser(request));
    }
}
```

### 4. Output Adapters
Implement ports to communicate with external systems:

```java
@Component
public class UserPersistenceAdapter implements UserPersistencePort {
    private final UserJpaRepository repository;
    
    @Override
    public void save(User user) {
        repository.save(UserJpaEntity.from(user));
    }
}
```

## Dependency Flow

```
REST Request
    ↓
Input Adapter (Controller)
    ↓
Input Port (Use Case Interface)
    ↓
Use Case Service (Application Service)
    ↓
Domain Service (Business Logic)
    ↓
Output Port (Repository Interface)
    ↓
Output Adapter (JPA Repository)
    ↓
Database
```

## Benefits of Hexagonal Architecture

✅ **Decoupling**: Core logic independent of frameworks  
✅ **Testability**: Easy to mock external dependencies  
✅ **Flexibility**: Swap adapters without changing core  
✅ **Maintainability**: Clear separation of concerns  
✅ **Scalability**: Multiple adapters for same port  
✅ **Technology Agnostic**: Switch databases, APIs easily  

## Example: Adding New Feature

1. Define input port in `application/port/in/`
2. Define output port in `application/port/out/`
3. Implement service in `application/service/`
4. Create REST adapter in `adapter/in/rest/`
5. Create persistence adapter in `adapter/out/persistence/`
6. Write tests at each layer
