# Server Certificates

This directory contains server-side SSL/TLS certificates and keystores.

## Generate Server Keystore

```bash
# Generate server private key and certificate
keytool -genkeypair -alias tca-server \
  -keyalg RSA -keysize 2048 \
  -keystore server-keystore.jks \
  -storepass changeit \
  -keypass changeit \
  -validity 365 \
  -dname "CN=localhost,O=TRT,C=US"

# Export server certificate
keytool -export -alias tca-server \
  -keystore server-keystore.jks \
  -storepass changeit \
  -file server-certificate.cer
```

## Create Server Truststore

```bash
# Create truststore and import client certificate
keytool -import -alias tca-client \
  -file ../client-certificates/client-certificate.cer \
  -keystore server-truststore.jks \
  -storepass changeit \
  -noprompt
```

## Files

- `server-keystore.jks` - Server private key and certificate
- `server-truststore.jks` - Trusted client certificates
- `server-certificate.cer` - Server certificate (for clients)

## Usage in Application

```properties
# In application-ssl.properties
server.ssl.key-store=classpath:keystores/server-keystore.jks
server.ssl.key-store-password=changeit
server.ssl.key-store-type=JKS
server.ssl.trust-store=classpath:keystores/server-truststore.jks
server.ssl.trust-store-password=changeit
server.ssl.client-auth=need
```

## HTTPS Configuration

```properties
# Enable HTTPS
server.ssl.enabled=true
server.port=8443
server.ssl.protocol=TLS
server.ssl.enabled-protocols=TLSv1.2,TLSv1.3
```
