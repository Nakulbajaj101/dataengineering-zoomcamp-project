# Plan terraform stage
plan_local:
	bash ./deploy/gcp/run_plan.sh
	bash ./deploy/gcp/run_plan.sh

# Plan terraform prod
plan_prod:
	bash ./deploy/gcp/run_plan.sh
	bash ./deploy/aws/run_plan.sh

# Apply terraform stage local machine
apply_local:
	bash ./deploy/gcp/run_apply.sh
	bash ./deploy/aws/run_apply.sh

# Apply terraform prod local machine
apply_prod:
	bash ./deploy/gcp/run_apply.sh
	bash ./deploy/aws/run_apply.sh

# Destroy terraform
destroy_prod_aws:
	bash ./deploy/aws/run_apply.sh

destroy_prod_gcp:
	bash ./deploy/gcp/run_destroy.sh

destroy_prod: destroy_prod_gcp destroy_prod_aws

destroy_prod_local: destroy_prod_gcp destroy_prod_aws

# Deploy prefect flows
deploy_prefect_flows:
	bash ./etl/create_prefect_deployments.sh

# For local setup
setup:
	pip install -r requirements.txt
	pre-commit install