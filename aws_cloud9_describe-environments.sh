#!/bin/bash

LIST="ide_list.txt"
# Get all Cloud9 environment IDs
environment_ids=$(aws cloud9 list-environments --query "environmentIds" --output text)

# Iterate over each environment ID to get usernames
for env_id in $environment_ids; do
  # Get the name for each environment ID
  env_name=$(aws cloud9 describe-environments --environment-id "$env_id" --query "environments[0].name" --output text)
  
  echo "Environment ID: $env_id" >> $LIST 
  echo "Environment name: $env_name" >> $LIST
  echo "" >> $LIST
done

echo "Done"
