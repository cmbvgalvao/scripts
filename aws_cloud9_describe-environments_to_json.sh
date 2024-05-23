#!/bin/bash

OUTPUT_FILE="ide_list.json"

# Initialize an empty array to hold JSON objects
json_array=()

# Get all Cloud9 environment IDs
environment_ids=$(aws cloud9 list-environments --query "environmentIds" --output text)

# Iterate over each environment ID to get names and usernames
for env_id in $environment_ids; do
  # Get the name for each environment ID
  env_name=$(aws cloud9 describe-environments --environment-ids "$env_id" --query "environments[0].name" --output text)
  
  # Create a JSON object and add it to the array
  json_object="{\"EnvironmentID\": \"$env_id\", \"EnvironmentName\": \"$env_name\"}"
  json_array+=("$json_object")
done

# Join the JSON objects into a JSON array
json_output="["
for i in "${!json_array[@]}"; do
  json_output+="${json_array[$i]}"
  if [[ $i -lt $((${#json_array[@]} - 1)) ]]; then
    json_output+=","
  fi
done
json_output+="]"

# Write the JSON output to the file
echo "$json_output" | jq '.' > "$OUTPUT_FILE"

echo "Outputted environment details to $OUTPUT_FILE in JSON format"

