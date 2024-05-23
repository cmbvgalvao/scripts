#!/bin/bash

# Function to fetch and modify environment preferences
reset_environment_layout() {
    # Fetch current environment details
    environment_info=$(aws cloud9 describe-environments --environment-id "$1")
    echo $environment_info
    # Extract managed IDE preferences JSON
    preferences=$(echo "$environment_info" | jq -r '.environments.managedCredentials | fromjson')
    echo $preferences
    # Remove windowLayout preferences
    modified_preferences=$(echo "$preferences" | jq 'del(.windowLayout)')
    $modified_preferences
    # Update environment with modified preferences
    aws cloud9 update-environment --environment-id "$1" --cli-input-json "{\"managedCredentials\":$modified_preferences}"
}

# Main script
if [ -z "$1" ]; then
    echo "Usage: $0 <environment-id>"
    exit 1
fi

environment_id="$1"
reset_environment_layout "$environment_id"

