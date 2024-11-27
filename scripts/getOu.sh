#!/bin/bash

OU_ID=$1

# Get the root ID
ROOT_ID=$(aws organizations list-roots --query "Roots[0].Id" --output text)

# Check if ROOT_ID was retrieved successfully
if [ -z "$ROOT_ID" ]; then
  echo "Error: Unable to retrieve root ID."
  exit 1
fi

# Get the OU from the AWS CLI based on the root ID and ou id
aws organizations list-organizational-units-for-parent --parent-id "$ROOT_ID" | jq ".OrganizationalUnits[] | select(.Id == \"$OU_ID\")"
