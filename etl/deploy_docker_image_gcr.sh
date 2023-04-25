#!/bin/bash
PROJECT_ID=dataengineeringzoomcamp-2023
docker build -t prefect:covid .
docker tag prefect:covid asia.gcr.io/$PROJECT_ID/prefect:covid
docker push asia.gcr.io/$PROJECT_ID/prefect:covid
