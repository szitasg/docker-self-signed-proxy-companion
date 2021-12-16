#!/bin/bash

CA_PATH="/etc/nginx/certs"
CA_CERT="${CA_PATH}/ca.crt"
CA_KEY="${CA_PATH}/ca.crt"

if [[ "$*" == "/bin/bash /app/start.sh" && ! -f "${CA_CERT}" ]]; then
    echo "==== Generating a new Certificate Authority -> ca.crt ===="

    openssl genrsa -out "${CA_KEY}" 2048
    openssl req -x509 -new -nodes -key "${CA_KEY}" -sha256 \
        -days "${EXPIRATION}" \
        -subj "/CN=Nginx-Proxy Companion Self-Signed CA $(date +%s)-$RANDOM" \
        -out "${CA_CERT}"
fi

exec "$@"
