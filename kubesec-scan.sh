#!/bin/bash

# Define variables
RESOURCE_FILE="k8s-deployment-service.yaml"
scan_result=$(curl -sSX POST --data-binary @"$RESOURCE_FILE" https://v2.kubesec.io/scan)
scan_message=$(echo "$scan_result" | jq -r '.[0].message')
scan_score=$(echo "$scan_result" | jq -r '.[0].score')

echo "scanning result: "
echo $scan_result | jq

# Check scan score
if ((scan_score >= 5)); then
    echo "Score is $scan_score"
    echo "Kubesec Scan $scan_message"
else
    echo "Score is $scan_score, which is less than or equal to 5."
    echo "Scanning Kubernetes Resource has Failed"
    exit 1
fi

# Perform checks on the Kubernetes resource file
echo "Performing additional checks on the Kubernetes resource file..."
echo "Checking if the file exists..."
if [[ ! -f "${RESOURCE_FILE}" ]]; then
    echo "The file ${RESOURCE_FILE} does not exist."
    exit 1
fi

echo "Checking if the file is readable..."
if [[ ! -r "${RESOURCE_FILE}" ]]; then
    echo "The file ${RESOURCE_FILE} is not readable."
    exit 1
fi

echo "Checking if the file is not empty..."
if [[ ! -s "${RESOURCE_FILE}" ]]; then
    echo "The file ${RESOURCE_FILE} is empty."
    exit 1
fi

echo "All checks passed successfully."
