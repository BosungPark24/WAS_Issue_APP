param(
    [Parameter(Mandatory = $true)][string]$ConfigFile
)

$ErrorActionPreference = "Stop"
. $ConfigFile

if (!(Test-Path $LocalWarPath)) {
    throw "WAR not found: $LocalWarPath"
}

$remote = "$RemoteUser@$RemoteHost"

Write-Host "[upload] ensure remote directory"
& ssh -i $SshKeyPath "$remote" "mkdir -p $RemoteDeployDir"

Write-Host "[upload] copy WAR"
& scp -i $SshKeyPath $LocalWarPath "${remote}:$RemoteWarPath"

Write-Host "[upload] copy deploy script"
& scp -i $SshKeyPath "$PSScriptRoot/deploy_remote.sh" "${remote}:$RemoteDeployScriptPath"

Write-Host "[upload] chmod deploy script"
& ssh -i $SshKeyPath "$remote" "chmod +x $RemoteDeployScriptPath"
