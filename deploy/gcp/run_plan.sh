#!/bin/bash

cd "$(dirname "$0")"

echo "Initialising terraform"
terraform init -backend-config="prefix=terraform/state/project-covid.tfstate" --reconfigure

echo "Running terraform plan"
terraform plan