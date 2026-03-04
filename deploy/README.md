# Deploy Automation (WebLogic on 10.20.210.239)

## 1) Prepare config
1. `deploy-config.ps1` is already created.
   - If needed, recreate from `deploy-config.sample.ps1`.
2. Fill your real values:
   - SSH user/key
   - `DOMAIN_HOME`
   - `ADMIN_URL`
   - `TARGET_NAME` (AdminServer or cluster)
   - WebLogic `userConfig/userKey` file paths

## 2) Prepare WebLogic secure credential files (on server, once)
Use WLST `storeUserConfig` to generate:
- `userConfig.secure`
- `userKey.secure`

Keep these files private and readable only by the deployment user.
Detailed guide: `deploy/FIRST_TIME_SETUP.md`

## 3) Run full pipeline
```powershell
.\deploy\deploy.ps1 -ConfigFile .\deploy\deploy-config.ps1
```

Pipeline steps:
1. Build WAR (`mvn -DskipTests package`)
2. Upload WAR and remote deploy script via SSH/SCP
3. Execute remote WebLogic deploy (`redeploy` then fallback `deploy`)

## 4) Manual split run
```powershell
.\deploy\build.ps1 -MvnCmd "mvn" -WorkDir .
.\deploy\upload.ps1 -ConfigFile .\deploy\deploy-config.ps1
```

Then remote deploy is executed by:
```bash
bash /home/weblogic/deployments/bosung-app/deploy_remote.sh \
  <DOMAIN_HOME> <ADMIN_URL> <APP_NAME> <TARGET_NAME> <WAR_PATH> <USER_CONFIG_FILE> <USER_KEY_FILE>
```

## Notes
- Script assumes OpenSSH (`ssh`, `scp`) is available on Windows.
- If your Maven is not in PATH, set `MvnCmd` in config.
- Keep `deploy-config.ps1` out of VCS if it contains sensitive data.

## GitHub Actions flow
If you want CI/CD from GitHub push, use:
- `.github/workflows/deploy-weblogic.yml`
- `deploy/GITHUB_ACTIONS.md`
