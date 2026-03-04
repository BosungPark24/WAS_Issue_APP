#!/usr/bin/env bash
set -euo pipefail

# usage:
#   deploy_remote_tomcat.sh <UPLOADED_WAR_PATH> <TOMCAT_WEBAPPS_DIR> <APP_CONTEXT_NAME>
#
# example:
#   deploy_remote_tomcat.sh /home/bs.park2/deployments/bosung-app/bosung-app.war /opt/tomcat/webapps was-issue-test

if [ "$#" -ne 3 ]; then
  echo "usage: $0 <UPLOADED_WAR_PATH> <TOMCAT_WEBAPPS_DIR> <APP_CONTEXT_NAME>"
  exit 1
fi

UPLOADED_WAR_PATH="$1"
TOMCAT_WEBAPPS_DIR="$2"
APP_CONTEXT_NAME="$3"

if [ ! -f "$UPLOADED_WAR_PATH" ]; then
  echo "[deploy] uploaded war not found: $UPLOADED_WAR_PATH"
  exit 1
fi

if [ ! -d "$TOMCAT_WEBAPPS_DIR" ]; then
  echo "[deploy] tomcat webapps dir not found: $TOMCAT_WEBAPPS_DIR"
  exit 1
fi

TARGET_WAR="$TOMCAT_WEBAPPS_DIR/$APP_CONTEXT_NAME.war"
TARGET_EXPLODED="$TOMCAT_WEBAPPS_DIR/$APP_CONTEXT_NAME"
TS="$(date +%Y%m%d-%H%M%S)"

echo "[deploy] target war: $TARGET_WAR"

if [ -f "$TARGET_WAR" ]; then
  cp -f "$TARGET_WAR" "$TARGET_WAR.bak.$TS"
  echo "[deploy] backup created: $TARGET_WAR.bak.$TS"
fi

cp -f "$UPLOADED_WAR_PATH" "$TARGET_WAR.tmp"
mv -f "$TARGET_WAR.tmp" "$TARGET_WAR"
echo "[deploy] war replaced"

# Remove exploded dir so Tomcat expands fresh content.
if [ -d "$TARGET_EXPLODED" ]; then
  rm -rf "$TARGET_EXPLODED"
  echo "[deploy] removed exploded app dir: $TARGET_EXPLODED"
fi

echo "[deploy] tomcat deploy file copy completed"
