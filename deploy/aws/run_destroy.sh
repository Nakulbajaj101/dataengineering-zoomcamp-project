#!/bin/bash

cd "$(dirname "$0")"

echo "Initialising terraform"
terraform init -backend-config="key=de-zoomcamp-prod.tfstate" --reconfigure

echo "Running terraform destroy"
terraform destroy --auto-approve
