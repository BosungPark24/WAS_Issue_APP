# GitHub Actions CI/CD for Tomcat

## Summary
Push to `main` triggers:
1. Build `target/bosung-app.war`
2. Upload WAR to `10.20.210.239`
3. Copy WAR into Tomcat `webapps` via remote deploy script

Workflow file:
- `.github/workflows/deploy-weblogic.yml` (name changed to "Deploy to Tomcat")

## Important network note
If `10.20.210.239` is private/internal, GitHub-hosted runner may not reach it.
Use one of these:
1. Self-hosted GitHub Runner inside your network
2. VPN/Direct connectivity from runner to server

Current workflow is configured for:
- `runs-on: [self-hosted, linux]` in deploy job

## Required GitHub Secrets
Set in: `Repo Settings > Secrets and variables > Actions`

- `SSH_PRIVATE_KEY`
- `WLS_HOST` (deploy target host, example: `10.20.210.239`)
- `WLS_USER` (SSH account, example: `bs.park2`)
- `REMOTE_DEPLOY_DIR` (example: `/home/bs.park2/deployments/bosung-app`)
- `REMOTE_WAR_PATH` (example: `/home/bs.park2/deployments/bosung-app/bosung-app.war`)
- `REMOTE_DEPLOY_SCRIPT_PATH` (example: `/home/bs.park2/deployments/bosung-app/deploy_remote_tomcat.sh`)
- `TOMCAT_WEBAPPS_DIR` (example: `/home/bs.park2/apache-tomcat-9.0.xx/webapps`)
- `APP_CONTEXT_NAME` (example: `was-issue-test`)

## First run checklist
1. Confirm self-hosted runner is online with labels `self-hosted`, `linux`
2. Confirm SSH key login works from runner host
3. Confirm `TOMCAT_WEBAPPS_DIR` is writable by `WLS_USER`
4. Push to `main` or trigger `workflow_dispatch`
5. Verify app URL:
   - `http://10.20.210.239:8080/<APP_CONTEXT_NAME>/`

## Kubernetes?
Not required for current architecture (single Tomcat server deployment).
