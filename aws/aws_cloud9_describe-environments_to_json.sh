#!/bin/bash
# Save every Cloud9 environment's ID and name to ide_list.json.
# describe-environments takes up to 25 IDs per call, so IDs are sent in batches;
# AWS and jq build the JSON, so names with quotes can't break it.

OUTPUT_FILE="ide_list.json"
read -r -a ids <<< "$(aws cloud9 list-environments --query "environmentIds" --output text)"

for ((i = 0; i < ${#ids[@]}; i += 25)); do
  aws cloud9 describe-environments --environment-ids "${ids[@]:i:25}" \
    --query "environments[].{EnvironmentID: id, EnvironmentName: name}" --output json
done | jq -s 'add // []' > "$OUTPUT_FILE"

echo "Outputted environment details to $OUTPUT_FILE in JSON format"
