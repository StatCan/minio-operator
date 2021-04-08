#!/bin/bash

# Default Credentials
export STANDARD_TENANT_1="${STANDARD_TENANT_1:=DEFAULT}"
export PREMIUM_TENANT_1="${PREMIUM_TENANT_1:=DEFAULT}"
export OPENID_CLIENT_ID="${OPENID_CLIENT_ID:=default}"
export OPENID_CONFIG_URL="${OPENID_CONFIG_URL:-default}"
export CONFIG_FILE="${CONFIG_FILE:-instances/base/tenant.yaml}"
export CONSOLE_HMAC_JWT_SECRET="${CONSOLE_HMAC_JWT_SECRET:-YOURJWTSIGNINGSECRET}"
export CONSOLE_PBKDF_PASSPHRASE="${CONSOLE_PBKDF_PASSPHRASE:-SECRET}"
export CONSOLE_PBKDF_SALT="${CONSOLE_PBKDF_SALT:-SECRET}"
export CONSOLE_ACCESS_KEY="${CONSOLE_ACCESS_KEY:-YOURCONSOLEACCESS}"
export CONSOLE_SECRET_KEY="${CONSOLE_SECRET_KEY:-YOURCONSOLESECRET}"
export AUDITLOGS_HOST="${AUDITLOGS_HOST:-http://localhost:9200}"
export AUDITLOGS_USER="${AUDITLOGS_USER:-AUDITLOGS_USER}"
export AUDITLOGS_PASSWORD="${AUDITLOGS_PASSWORD:-AUDITLOGS_PASSWORD}"
export IMAGE_PULL_SECRET="${IMAGE_PULL_SECRET:-IMAGE_PULL_SECRET}"

envsubst < instances/standard/tenant-1/secret-console.tmpl > instances/standard/tenant-1/secret-console.txt
envsubst < instances/standard/tenant-1/secret-minio.tmpl > instances/standard/tenant-1/secret-minio.txt
envsubst < instances/standard/tenant-1/secret-image-pull-secret.tmpl > instances/standard/tenant-1/secret-image-pull-secret.txt
envsubst < instances/premium/tenant-1/secret-console.tmpl > instances/premium/tenant-1/secret-console.txt
envsubst < instances/premium/tenant-1/secret-minio.tmpl > instances/premium/tenant-1/secret-minio.txt
envsubst < instances/premium/tenant-1/secret-image-pull-secret.tmpl > instances/premium/tenant-1/secret-image-pull-secret.txt

envsubst < logstash/secret.tmpl > logstash/secret.env

# OIDC
yq -d5 w -i ${CONFIG_FILE} 'spec.env[2].value' ${OPENID_CLIENT_ID}
yq -d5 w -i ${CONFIG_FILE} 'spec.env[3].value' ${OPENID_CONFIG_URL}

# Domain
export DOMAIN_NAME="${DOMAIN_NAME:=default.example.ca}"
for patch in instances/*/tenant*/patch-minio-ing*; do
  val=$(yq r $patch '[0].value')
  yq w -i $patch '[0].value' ${val/example.ca/$DOMAIN_NAME}
done
for patch in instances/*/tenant*/patch-console-ing*; do
  val=$(yq r $patch '[0].value')
  yq w -i $patch '[0].value' ${val/example.ca/$DOMAIN_NAME}
done
