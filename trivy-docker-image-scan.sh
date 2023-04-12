#!/bin/bash
# openjdk   0
# openjdk:8       200 vulneribility
# openjdk:8-alpine  200
# openjdk:8-jdk-alpine  40
# adoptopenjdk/openjdk8:alpine-slim 0

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo "docker image will scannaed: " $dockerImageName
whoami
pwd

# Nếu tìm thấy HIGH severity thì return 0, critical return 1
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.18.3 -q image --exit-code 0 --severity HIGH --light $dockerImageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.18.3 -q image --exit-code 1 --severity CRITICAL --light $dockerImageName


    # Trivy scan result processing
    exit_code=$?
    echo "Exit Code : $exit_code"

    # Check scan results
    if [[ "${exit_code}" == 1 ]]; then
        echo "Image scanning failed. Vulnerabilities found"
        exit 1;
    else
        echo "Image scanning passed. No CRITICAL vulnerabilities found"
    fi;
