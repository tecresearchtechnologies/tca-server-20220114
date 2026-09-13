# Client Certificates

This directory contains client-side SSL/TLS certificates and keystores.

## Generate Client Keystore

```bash
# Generate client private key and certificate
keytool -genkeypair -alias tca-client \
  -keyalg RSA -keysize 2048 \
  -keystore client-keystore.jks \
  -storepass changeit \
  -keypass changeit \
  -validity 365 \
  -dname "CN=tca-client,O=TRT,C=US"

# Export client certificate
keytool -export -alias tca-client \
  -keystore client-keystore.jks \
  -storepass changeit \
  -file client-certificate.cer
```

## Import Server Certificate into Client Truststore

```bash
# Import server certificate to client truststore
keytool -import -alias tca-server \
  -file ../server-certificates/server-certificate.cer \
  -keystore client-truststore.jks \
  -storepass changeit \
  -noprompt
```

## Files

- `client-keystore.jks` - Client private key and certificate
- `client-truststore.jks` - Trusted server certificates
- `client-certificate.cer` - Client certificate (for server)

## Usage in Application

```properties
# In application-ssl.properties
server.ssl.key-store=classpath:keystores/client-keystore.jks
server.ssl.key-store-password=changeit
server.ssl.key-store-type=JKS
server.ssl.trust-store=classpath:keystores/client-truststore.jks
server.ssl.trust-store-password=changeit
```
