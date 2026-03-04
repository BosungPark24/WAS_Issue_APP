$MvnCmd = "mvn"

$RemoteHost = "10.20.210.239"
$RemoteUser = "bs.park2"
$SshKeyPath = "$env:USERPROFILE\.ssh\id_rsa"

$RemoteDeployDir = "/home/bs.park2/apps/deployments/bosung-app"
$RemoteWarPath = "$RemoteDeployDir/bosung-app.war"
$RemoteDeployScriptPath = "$RemoteDeployDir/deploy_remote.sh"

$DomainHome = "/home/bs.park2/weblogic1411/wls14110/domains/base_domain"
$AdminUrl = "t3://10.20.210.239:20001"
$TargetName = "Cluster-0"
$AppName = "bosung-app"

$BootPropertiesPath = "/home/bs.park2/weblogic1411/wls14110/domains/base_domain/boot.properties"

$LocalWarPath = "target/bosung-app.war"
