# PostgreSQL Database Configuration for TCA Server

## Database Setup

### Initial Setup
```sql
-- Create database
CREATE DATABASE "tca-server-20220114";

-- Connect to the database
\c tca-server-20220114

-- Create schema (optional, recommended for multi-tenant scenarios)
CREATE SCHEMA public;
```

### User Setup
```sql
-- User already created as 'postgres'
-- Change password if needed
ALTER USER postgres WITH PASSWORD 'ps@admin';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE "tca-server-20220114" TO postgres;
```

## Connection String
```
jdbc:postgresql://localhost:5432/tca-server-20220114
User: postgres
Password: ps@admin
```

## Backup and Restore

### Backup
```bash
pg_dump -U postgres -d tca-server-20220114 > backup.sql
```

### Restore
```bash
psql -U postgres -d tca-server-20220114 < backup.sql
```

## Performance Tuning

### Connection Pool Settings (in application.properties)
```properties
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=20000
spring.datasource.hikari.idle-timeout=300000
spring.datasource.hikari.max-lifetime=1200000
```

### Indexes to Create
```sql
-- Add indexes as needed based on query patterns
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_created_at ON audit_logs(created_at);
```

## Monitoring

### Check Database Size
```sql
SELECT pg_size_pretty(pg_database_size('tca-server-20220114'));
```

### Check Table Sizes
```sql
SELECT tablename, pg_size_pretty(pg_total_relation_size(tablename)) 
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(tablename) DESC;
```

### Active Connections
```sql
SELECT count(*) FROM pg_stat_activity WHERE datname = 'tca-server-20220114';
```
