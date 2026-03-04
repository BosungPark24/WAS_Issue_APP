#!/usr/bin/env bash
set -euo pipefail

# usage:
#   deploy_remote.sh <DOMAIN_HOME> <ADMIN_URL> <APP_NAME> <TARGET_NAME> <WAR_PATH> <BOOT_PROPERTIES_PATH>

if [ "$#" -ne 6 ]; then
  echo "usage: $0 <DOMAIN_HOME> <ADMIN_URL> <APP_NAME> <TARGET_NAME> <WAR_PATH> <BOOT_PROPERTIES_PATH>"
  exit 1
fi

DOMAIN_HOME="$1"
ADMIN_URL="$2"
APP_NAME="$3"
TARGET_NAME="$4"
WAR_PATH="$5"
BOOT_PROPERTIES_PATH="$6"

if [ ! -d "$DOMAIN_HOME" ]; then
  echo "[deploy] DOMAIN_HOME not found: $DOMAIN_HOME"
  exit 1
fi

if [ ! -f "$WAR_PATH" ]; then
  echo "[deploy] WAR not found: $WAR_PATH"
  exit 1
fi

if [ ! -f "$BOOT_PROPERTIES_PATH" ]; then
  echo "[deploy] boot.properties not found: $BOOT_PROPERTIES_PATH"
  exit 1
fi

WLS_USER_LINE="$(grep -E '^[[:space:]]*username[[:space:]]*=' "$BOOT_PROPERTIES_PATH" | head -n1 || true)"
WLS_PW_LINE="$(grep -E '^[[:space:]]*password[[:space:]]*=' "$BOOT_PROPERTIES_PATH" | head -n1 || true)"

WLS_USER="${WLS_USER_LINE#*=}"
WLS_PW="${WLS_PW_LINE#*=}"

# Trim leading/trailing spaces
WLS_USER="$(printf '%s' "$WLS_USER" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
WLS_PW="$(printf '%s' "$WLS_PW" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

if [ -z "$WLS_USER" ] || [ -z "$WLS_PW" ]; then
  echo "[deploy] username/password not found in boot.properties"
  echo "[deploy] boot.properties path: $BOOT_PROPERTIES_PATH"
  echo "[deploy] file preview:"
  sed -n '1,20p' "$BOOT_PROPERTIES_PATH" | sed 's/password=.*/password=***MASKED***/'
  exit 1
fi

# weblogic.Deployer often requires plaintext password.
# If password is encrypted ({AES}...), this can fail depending on environment.
if [[ "$WLS_PW" == \{AES\}* ]]; then
  echo "[deploy] WARNING: boot.properties password looks encrypted ({AES}...)."
  echo "[deploy] If deploy fails with auth error, use userConfig/userKey or plaintext CI secret."
fi

source "$DOMAIN_HOME/bin/setDomainEnv.sh" >/dev/null 2>&1 || true

BASE_CMD=(
  java weblogic.Deployer
  -adminurl "$ADMIN_URL"
  -username "$WLS_USER"
  -password "$WLS_PW"
  -name "$APP_NAME"
  -source "$WAR_PATH"
  -targets "$TARGET_NAME"
  -upload
)

echo "[deploy] trying redeploy"
if "${BASE_CMD[@]}" -redeploy; then
  echo "[deploy] redeploy success"
  exit 0
fi

echo "[deploy] redeploy failed; trying fresh deploy"
"${BASE_CMD[@]}" -deploy
echo "[deploy] deploy success"
