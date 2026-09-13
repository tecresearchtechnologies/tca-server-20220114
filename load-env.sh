#!/bin/bash
# Load environment variables from vars folder

ENVIRONMENT=${1:-local}
ENV_FILE="vars/${ENVIRONMENT}/.env.${ENVIRONMENT}"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment file not found: $ENV_FILE"
    exit 1
fi

echo "Loading environment: $ENVIRONMENT from $ENV_FILE"

# Load environment variables
set -a
source "$ENV_FILE"
set +a

echo "Environment variables loaded successfully"
echo "Active Environment: $APP_ENVIRONMENT"
echo "Spring Profile: $SPRING_PROFILES_ACTIVE"
