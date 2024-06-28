#!/bin/bash

# Path to the CSV file containing usernames and hostnames
CSV_FILE=$1

# Path to the script that should be executed on remote hosts
REMOTE_SCRIPT=$2

# Check if the CSV file exists
if [ ! -f "$CSV_FILE" ]; then
  echo "CSV file not found: $CSV_FILE"
  exit 1
fi

# Read the CSV file line by line
while IFS=, read -r username hostname
do
  # Skip the header line
  if [[ "$username" == "username" && "$hostname" == "hostname" ]]; then
    continue
  fi

  echo "Connecting to $hostname as $username..."

  # Establish SSH connection and execute the remote script
  ssh "$username@$hostname" "bash -s" < "$REMOTE_SCRIPT"

  # Check if SSH command was successful
  if [ $? -eq 0 ]; then
    echo "Successfully executed script on $hostname"
  else
    echo "Failed to execute script on $hostname"
  fi

done < "$CSV_FILE"
