param(
    [string]$MvnCmd = "mvn",
    [string]$WorkDir = "."
)

$ErrorActionPreference = "Stop"

if ($MvnCmd -eq "mvn" -and (Test-Path "C:\Users\USER\maven-portable\apache-maven-3.9.9\bin\mvn.cmd")) {
    $MvnCmd = "C:\Users\USER\maven-portable\apache-maven-3.9.9\bin\mvn.cmd"
}

Push-Location $WorkDir
try {
    Write-Host "[build] using maven: $MvnCmd"
    & $MvnCmd -DskipTests package
}
finally {
    Pop-Location
}
