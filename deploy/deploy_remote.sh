#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 7 ]; then
  echo "usage: $0 <DOMAIN_HOME> <ADMIN_URL> <APP_NAME> <TARGET_NAME> <WAR_PATH> <USER_CONFIG_FILE> <USER_KEY_FILE>"
  exit 1
fi

DOMAIN_HOME="$1"
ADMIN_URL="$2"
APP_NAME="$3"
TARGET_NAME="$4"
WAR_PATH="$5"
USER_CONFIG_FILE="$6"
USER_KEY_FILE="$7"

if [ ! -d "$DOMAIN_HOME" ]; then
  echo "[deploy] DOMAIN_HOME not found: $DOMAIN_HOME"
  exit 1
fi

if [ ! -f "$WAR_PATH" ]; then
  echo "[deploy] WAR not found: $WAR_PATH"
  exit 1
fi

if [ ! -f "$USER_CONFIG_FILE" ] || [ ! -f "$USER_KEY_FILE" ]; then
  echo "[deploy] WebLogic user config/key file missing"
  exit 1
fi

source "$DOMAIN_HOME/bin/setDomainEnv.sh" >/dev/null 2>&1 || true

BASE_CMD=(
  java weblogic.Deployer
  -adminurl "$ADMIN_URL"
  -userconfigfile "$USER_CONFIG_FILE"
  -userkeyfile "$USER_KEY_FILE"
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
