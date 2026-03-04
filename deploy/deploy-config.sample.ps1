$MvnCmd = "mvn"

$RemoteHost = "10.20.210.239"
$RemoteUser = "weblogic"
$SshKeyPath = "$env:USERPROFILE\.ssh\id_rsa"

$RemoteDeployDir = "/home/weblogic/deployments/bosung-app"
$RemoteWarPath = "$RemoteDeployDir/bosung-app.war"
$RemoteDeployScriptPath = "$RemoteDeployDir/deploy_remote.sh"

$DomainHome = "/u01/oracle/user_projects/domains/base_domain"
$AdminUrl = "t3://10.20.210.239:7001"
$TargetName = "AdminServer"
$AppName = "bosung-app"

$WlsUserConfigFile = "/home/weblogic/.wls/userConfig.secure"
$WlsUserKeyFile = "/home/weblogic/.wls/userKey.secure"

$LocalWarPath = "target/bosung-app.war"
