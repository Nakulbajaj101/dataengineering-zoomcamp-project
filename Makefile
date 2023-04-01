# Plan terraform stage
plan_local:
	bash ./deploy/run_plan.sh

# Plan terraform prod
plan_prod:
	bash ./deploy/run_plan.sh

# Apply terraform stage local machine
apply_local:
	bash ./deploy/run_apply.sh

# Apply terraform prod local machine
apply_prod:
	bash ./deploy/run_apply.sh

# For local setup
setup:
	pip install -r requirements.txt
	pre-commit install