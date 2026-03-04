# First-Time Setup (WebLogic Server)

## 1) Upload helper script to server
From local project root:

```powershell
scp -i $env:USERPROFILE\.ssh\id_rsa .\deploy\wlst_store_userconfig.py weblogic@10.20.210.239:/home/weblogic/deployments/bosung-app/
```

## 2) SSH to server and generate secure login files

```bash
ssh -i ~/.ssh/id_rsa weblogic@10.20.210.239
mkdir -p /home/weblogic/.wls
chmod 700 /home/weblogic/.wls
```

Run WLST (domain path may differ in your environment):

```bash
/u01/oracle/oracle_common/common/bin/wlst.sh /home/weblogic/deployments/bosung-app/wlst_store_userconfig.py
```

WLST will prompt for admin username/password once.

## 3) Verify files

```bash
ls -l /home/weblogic/.wls/userConfig.secure
ls -l /home/weblogic/.wls/userKey.secure
chmod 600 /home/weblogic/.wls/userConfig.secure /home/weblogic/.wls/userKey.secure
```

## 4) Run deployment from local

```powershell
.\deploy\deploy.ps1 -ConfigFile .\deploy\deploy-config.ps1
```

## 5) Smoke check
Open:

```text
http://10.20.210.239:7001/was-issue-test/
```

or your front web/proxy URL.
