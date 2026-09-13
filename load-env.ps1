# Load environment variables from vars folder

$ENVIRONMENT = $args[0] ?? "local"
$ENV_FILE = "vars/$ENVIRONMENT/.env.$ENVIRONMENT"

if (-not (Test-Path $ENV_FILE)) {
    Write-Host "Error: Environment file not found: $ENV_FILE" -ForegroundColor Red
    exit 1
}

Write-Host "Loading environment: $ENVIRONMENT from $ENV_FILE" -ForegroundColor Green

# Read and parse the .env file
$envVars = @{}
Get-Content $ENV_FILE | ForEach-Object {
    if ($_ -and -not $_.StartsWith("#")) {
        $key, $value = $_.Split("=", 2)
        if ($key) {
            $envVars[$key.Trim()] = $value.Trim()
        }
    }
}

# Set environment variables
$envVars.GetEnumerator() | ForEach-Object {
    [Environment]::SetEnvironmentVariable($_.Key, $_.Value, "Process")
    Write-Host "$($_.Key)=$($_.Value)" -ForegroundColor Cyan
}

Write-Host "Environment variables loaded successfully" -ForegroundColor Green
Write-Host "Active Environment: $($envVars['APP_ENVIRONMENT'])" -ForegroundColor Yellow
Write-Host "Spring Profile: $($envVars['SPRING_PROFILES_ACTIVE'])" -ForegroundColor Yellow
