#!/usr/bin/env bash
set -euo pipefail

# usage:
#   deploy_remote.sh <DOMAIN_HOME> <ADMIN_URL> <APP_NAME> <TARGET_NAME> <WAR_PATH> <WLS_ADMIN_USER> <WLS_ADMIN_PASSWORD>

if [ "$#" -ne 7 ]; then
  echo "usage: $0 <DOMAIN_HOME> <ADMIN_URL> <APP_NAME> <TARGET_NAME> <WAR_PATH> <WLS_ADMIN_USER> <WLS_ADMIN_PASSWORD>"
  exit 1
fi

DOMAIN_HOME="$1"
ADMIN_URL="$2"
APP_NAME="$3"
TARGET_NAME="$4"
WAR_PATH="$5"
WLS_ADMIN_USER="$6"
WLS_ADMIN_PASSWORD="$7"

if [ ! -d "$DOMAIN_HOME" ]; then
  echo "[deploy] DOMAIN_HOME not found: $DOMAIN_HOME"
  exit 1
fi

if [ ! -f "$WAR_PATH" ]; then
  echo "[deploy] WAR not found: $WAR_PATH"
  exit 1
fi

if [ -z "$WLS_ADMIN_USER" ] || [ -z "$WLS_ADMIN_PASSWORD" ]; then
  echo "[deploy] WLS_ADMIN_USER/WLS_ADMIN_PASSWORD is empty"
  exit 1
fi

# setDomainEnv.sh can fail under strict shell flags in non-interactive CI.
set +e +u
# shellcheck disable=SC1090
source "$DOMAIN_HOME/bin/setDomainEnv.sh"
SETDOMAIN_RC=$?
set -euo pipefail

if [ "$SETDOMAIN_RC" -ne 0 ]; then
  echo "[deploy] WARNING: setDomainEnv.sh returned non-zero ($SETDOMAIN_RC)"
  echo "[deploy] continuing; if weblogic.Deployer class not found, verify DOMAIN_HOME and env script."
fi

BASE_CMD=(
  java weblogic.Deployer
  -adminurl "$ADMIN_URL"
  -username "$WLS_ADMIN_USER"
  -password "$WLS_ADMIN_PASSWORD"
  -name "$APP_NAME"
  -source "$WAR_PATH"
  -targets "$TARGET_NAME"
  -upload
)

run_with_lock_retry() {
  local action="$1"
  local max_attempts="${2:-8}"
  local sleep_seconds="${3:-15}"
  local attempt=1

  while [ "$attempt" -le "$max_attempts" ]; do
    echo "[deploy] ${action} attempt ${attempt}/${max_attempts}"

    set +e
    local output
    output="$("${BASE_CMD[@]}" "-${action}" 2>&1)"
    local rc=$?
    set -e

    printf '%s\n' "$output"

    if [ "$rc" -eq 0 ]; then
      return 0
    fi

    if printf '%s' "$output" | grep -qiE 'Deployer:149163|edit lock is owned by another session'; then
      if [ "$attempt" -lt "$max_attempts" ]; then
        echo "[deploy] edit lock busy. retry after ${sleep_seconds}s..."
        sleep "$sleep_seconds"
        attempt=$((attempt + 1))
        continue
      fi
    fi

    return "$rc"
  done

  return 1
}

echo "[deploy] trying redeploy"
if run_with_lock_retry "redeploy" 8 15; then
  echo "[deploy] redeploy success"
  exit 0
fi

echo "[deploy] redeploy failed; trying fresh deploy"
run_with_lock_retry "deploy" 8 15
echo "[deploy] deploy success"
