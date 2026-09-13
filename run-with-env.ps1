<#
.SYNOPSIS
  Loads backend/.env into the current process's environment variables, then starts the
  Spring Boot jar. Spring Boot does NOT read .env files on its own - this script is what
  bridges that gap so the values in .env actually take effect.

.USAGE
  cd backend
  .\run-with-env.ps1
#>

$envFile = Join-Path $PSScriptRoot '.env'

if (-not (Test-Path $envFile)) {
    Write-Error ".env not found at $envFile - copy .env.example to .env and fill in real values first."
    exit 1
}

Write-Host "Loading environment variables from $envFile ..."

Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq '' -or $line.StartsWith('#')) { return }

    $idx = $line.IndexOf('=')
    if ($idx -lt 1) { return }

    $key = $line.Substring(0, $idx).Trim()
    $value = $line.Substring($idx + 1).Trim()

    if ($value -eq '') { return }  # don't set empty vars - let application.properties defaults apply

    [System.Environment]::SetEnvironmentVariable($key, $value, 'Process')
    Write-Host "  set $key"
}

$jar = Join-Path $PSScriptRoot 'target\pms.jar'
if (-not (Test-Path $jar)) {
    Write-Host "target\pms.jar not found - building first..."
    & mvn -q -f (Join-Path $PSScriptRoot 'pom.xml') clean package -DskipTests
}

Write-Host "Starting backend..."
& java -jar $jar
