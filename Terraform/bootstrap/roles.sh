#! /usr/bin/env bash

set -e

# Helpers for readability.
bold=$(tput bold)
normal=$(tput sgr0)
function _info() {
    echo "${bold}${1}${normal}"
}

function assume_role() {
    OUT=$(aws sts assume-role --profile $1 --role-arn arn:aws:iam::$2:role/Padok-Root --role-session-name bootstrap);\
    export AWS_ACCESS_KEY_ID=$(echo $OUT | jq -r '.Credentials''.AccessKeyId');\
    export AWS_SECRET_ACCESS_KEY=$(echo $OUT | jq -r '.Credentials''.SecretAccessKey');\
    export AWS_SESSION_TOKEN=$(echo $OUT | jq -r '.Credentials''.SessionToken');
}

function create_role() {
    aws iam create-role \
        --role-name $1 \
        --assume-role-policy-document file://trust_relationship.json \
        --description "Padok role used to administrate infrastructure." \
        --no-cli-pager \
        --max-session-duration 43200 # 12 hours

    aws iam attach-role-policy \
        --policy-arn arn:aws:iam::aws:policy/AdministratorAccess \
        --role-name $1
}

# Run script from directory where the script is stored.
cd "$( dirname "${BASH_SOURCE[0]}" )"

for account_id in "$@"
do
    _info "Using role in account $account_id..."
    assume_role "root" $account_id
    _info "Creating Padok's role in target account..."
    create_role "Padok-Ops"
    _info "Role created for account $account_id."

    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
done


_info "🥳 All accounts are ready ! Happy Terragrunting !"

