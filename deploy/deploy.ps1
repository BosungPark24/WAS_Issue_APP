param(
    [string]$ConfigFile = "$PSScriptRoot/deploy-config.ps1"
)

$ErrorActionPreference = "Stop"

if (!(Test-Path $ConfigFile)) {
    throw "Config not found: $ConfigFile (copy deploy-config.sample.ps1 -> deploy-config.ps1)"
}

. $ConfigFile

Write-Host "[pipeline] 1) build"
& "$PSScriptRoot/build.ps1" -MvnCmd $MvnCmd -WorkDir "$PSScriptRoot/.."

Write-Host "[pipeline] 2) upload"
& "$PSScriptRoot/upload.ps1" -ConfigFile $ConfigFile

Write-Host "[pipeline] 3) remote deploy"
$remote = "$RemoteUser@$RemoteHost"
$remoteCmd = @"
bash '$RemoteDeployScriptPath' '$DomainHome' '$AdminUrl' '$AppName' '$TargetName' '$RemoteWarPath' '$WlsUserConfigFile' '$WlsUserKeyFile'
"@
& ssh -i $SshKeyPath "$remote" $remoteCmd

Write-Host "[pipeline] done"
