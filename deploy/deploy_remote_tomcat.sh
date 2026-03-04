#!/usr/bin/env bash
set -euo pipefail

# usage:
#   deploy_remote_tomcat.sh <UPLOADED_WAR_TMP_PATH> <REMOTE_WAR_PATH>
#
# Deploy policy:
# - Keep deployment strictly based on REMOTE_WAR_PATH.
# - Create backup of current REMOTE_WAR_PATH if exists.
# - Atomically replace REMOTE_WAR_PATH from uploaded tmp war.

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <UPLOADED_WAR_TMP_PATH> <REMOTE_WAR_PATH>"
  exit 1
fi

UPLOADED_WAR_TMP_PATH="$1"
REMOTE_WAR_PATH="$2"

if [ ! -f "$UPLOADED_WAR_TMP_PATH" ]; then
  echo "[deploy] uploaded tmp war not found: $UPLOADED_WAR_TMP_PATH"
  exit 1
fi

TARGET_DIR="$(dirname "$REMOTE_WAR_PATH")"
if [ ! -d "$TARGET_DIR" ]; then
  echo "[deploy] target dir not found: $TARGET_DIR"
  exit 1
fi

TS="$(date +%Y%m%d-%H%M%S)"

if [ -f "$REMOTE_WAR_PATH" ]; then
  cp -f "$REMOTE_WAR_PATH" "$REMOTE_WAR_PATH.bak.$TS"
  echo "[deploy] backup created: $REMOTE_WAR_PATH.bak.$TS"
fi

mv -f "$UPLOADED_WAR_TMP_PATH" "$REMOTE_WAR_PATH"
echo "[deploy] war replaced at: $REMOTE_WAR_PATH"
