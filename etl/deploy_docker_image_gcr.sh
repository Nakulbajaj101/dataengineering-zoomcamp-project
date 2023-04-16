#!/bin/bash
PROJECT_ID=$1
docker build -t prefect:covid .
docker tag prefect:covid asia.gcr.io/$1/prefect:covid
docker push asia.gcr.io/$1/prefect:covid
