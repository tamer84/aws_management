#!/bin/bash
set -e
ACCOUNT_EMAIL=$1

aws organizations list-accounts | jq -r ".Accounts[] | select(.Email == \"${ACCOUNT_EMAIL}\") "
