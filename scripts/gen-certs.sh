#!/bin/bash
# Generate mTLS certificates for Chitinwall

set -e

CERT_DIR="certs"
mkdir -p "$CERT_DIR"

echo "Generating CA certificate..."
openssl req -x509 -newkey rsa:4096 -days 365 -nodes \
    -keyout "$CERT_DIR/ca-key.pem" \
    -out "$CERT_DIR/ca.pem" \
    -subj "/CN=Chitinwall CA"

echo "Generating server certificate..."
openssl req -newkey rsa:4096 -nodes \
    -keyout "$CERT_DIR/server-key.pem" \
    -out "$CERT_DIR/server-req.pem" \
    -subj "/CN=chitinwall-server"

openssl x509 -req -in "$CERT_DIR/server-req.pem" \
    -CA "$CERT_DIR/ca.pem" \
    -CAkey "$CERT_DIR/ca-key.pem" \
    -CAcreateserial -days 365 \
    -out "$CERT_DIR/server.pem"

echo "✅ Certificates generated in $CERT_DIR/"
