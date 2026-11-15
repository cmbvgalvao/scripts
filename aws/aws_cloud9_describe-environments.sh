#!/bin/bash
# List every Cloud9 environment's ID and name in ide_list.txt.
# describe-environments takes up to 25 IDs per call, so IDs are sent in batches.

LIST="ide_list.txt"
read -r -a ids <<< "$(aws cloud9 list-environments --query "environmentIds" --output text)"

for ((i = 0; i < ${#ids[@]}; i += 25)); do
  aws cloud9 describe-environments --environment-ids "${ids[@]:i:25}" \
    --query "environments[].[id,name]" --output text |
  while IFS=$'\t' read -r env_id env_name; do
    echo "Environment ID: $env_id" >> "$LIST"
    echo "Environment name: $env_name" >> "$LIST"
    echo "" >> "$LIST"
  done
done

echo "Done"
