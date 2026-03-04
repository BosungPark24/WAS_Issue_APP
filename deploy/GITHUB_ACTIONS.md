# GitHub Actions CI/CD for WebLogic

## Summary
Push to `main` triggers:
1. Build `target/bosung-app.war`
2. Upload WAR to `10.20.210.239`
3. Run remote WebLogic deploy script

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
- `WLS_USER` (example: `weblogic`)
- `REMOTE_DEPLOY_DIR` (example: `/home/weblogic/deployments/bosung-app`)
- `REMOTE_WAR_PATH` (example: `/home/weblogic/deployments/bosung-app/bosung-app.war`)
- `REMOTE_DEPLOY_SCRIPT_PATH` (example: `/home/weblogic/deployments/bosung-app/deploy_remote.sh`)
- `DOMAIN_HOME` (example: `/u01/oracle/user_projects/domains/base_domain`)
- `ADMIN_URL` (example: `t3://10.20.210.239:7001`)
- `APP_NAME` (example: `bosung-app`)
- `TARGET_NAME` (example: `AdminServer` or cluster name)
- `BOOT_PROPERTIES_PATH` (example: `/u01/oracle/user_projects/domains/base_domain/servers/AdminServer/security/boot.properties`)

## First run checklist
1. Confirm `BOOT_PROPERTIES_PATH` exists on target server
2. Confirm self-hosted runner is online with labels `self-hosted`, `linux`
3. Confirm SSH key login works from runner host
4. Push to `main` or trigger `workflow_dispatch`
5. Verify Actions logs and open app URL after deploy

## boot.properties caution
`weblogic.Deployer` commonly expects plaintext password.
If `boot.properties` contains encrypted password (`{AES}...`), authentication may fail.
In that case, switch to:
1. `userConfig/userKey` 방식
2. 또는 GitHub Secret 기반 plaintext 계정/비밀번호 전달

## Kubernetes?
Not required for your current target architecture (existing WebLogic on VM/server).
Kubernetes is only needed if you move to container-native operations.
