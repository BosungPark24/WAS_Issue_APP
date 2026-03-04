# GitHub Actions CI/CD for WebLogic

## Summary
Push to `main` triggers:
1. Build `target/bosung-app.war`
2. Upload WAR to `10.20.210.239`
3. Execute remote WebLogic deploy script

Workflow file:
- `.github/workflows/deploy-weblogic.yml`

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
- `WLS_HOST` (example: `10.20.210.239`)
- `WLS_USER` (SSH account, example: `bs.park2`)
- `REMOTE_DEPLOY_DIR` (example: `/home/bs.park2/deployments/bosung-app`)
- `REMOTE_WAR_PATH` (example: `/home/bs.park2/deployments/bosung-app/bosung-app.war`)
- `REMOTE_DEPLOY_SCRIPT_PATH` (example: `/home/bs.park2/deployments/bosung-app/deploy_remote.sh`)
- `DOMAIN_HOME` (example: `/u01/oracle/user_projects/domains/base_domain`)
- `ADMIN_URL` (example: `t3://10.20.210.239:7001`)
- `APP_NAME` (example: `bosung-app`)
- `TARGET_NAME` (example: `AdminServer` or cluster name)
- `WLS_ADMIN_USER` (WebLogic admin id)
- `WLS_ADMIN_PASSWORD` (WebLogic admin password)

## First run checklist
1. Confirm self-hosted runner is online with labels `self-hosted`, `linux`
2. Confirm SSH key login works from runner host
3. Push to `main` or trigger `workflow_dispatch`
4. Verify Actions logs and open app URL after deploy

## Kubernetes?
Not required for your current target architecture (existing WebLogic on VM/server).
Kubernetes is only needed if you move to container-native operations.
