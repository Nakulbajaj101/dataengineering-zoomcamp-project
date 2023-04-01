#!/bin/bash

cd "$(dirname "$0")"

echo "Initialising terraform"
terraform init -backend-config="prefix=terraform/state/project-covid.tfstate" --reconfigure

echo "Running terraform apply"
terraform apply --auto-approve
