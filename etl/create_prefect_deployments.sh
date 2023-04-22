#!/bin/bash

cd "$(dirname "$0")"

echo "Deploy backfill flows"
python etl_covid_data_backfill_deployment.py

echo "Deploy flows"
python etl_covid_data_deployment.py
