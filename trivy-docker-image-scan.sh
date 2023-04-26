#!/bin/bash
# openjdk   0
# openjdk:8       200 vulneribility
# openjdk:8-alpine  200
# openjdk:8-jdk-alpine  40
# adoptopenjdk/openjdk8:alpine-slim 0

# dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
# echo "docker image will scannaed: " $dockerImageName
# echo "cuurrent directory: $pwd"

# # Nếu tìm thấy HIGH severity thì return 0, critical return 1
# docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.18.3 -q image --exit-code 0 --severity HIGH --light $dockerImageName
# docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.18.3 -q image --exit-code 1 --severity CRITICAL --light $dockerImageName


#     # Trivy scan result processing
#     exit_code=$?
#     echo "Exit Code : $exit_code"

#     # Check scan results
#     if [[ "${exit_code}" == 1 ]]; then
#         echo "Image scanning failed. Vulnerabilities found"
#         exit 1;
#     else
#         echo "Image scanning passed. No CRITICAL vulnerabilities found"
#     fi;

#!/bin/bash

#!/bin/bash

# Define the image to scan
dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo "Scanning image: ${dockerImageName}"

# Set up the output directory for reports
REPORT_DIR="${WORKSPACE}/trivy-reports"
mkdir -p "${REPORT_DIR}"

# Set up the log file for scan output
LOG_FILE="${REPORT_DIR}/trivy-scan.log"

# Run the scan with Trivy
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "${REPORT_DIR}:/root/.cache/trivy" \
    aquasec/trivy:latest \
    --severity HIGH,CRITICAL \
    --ignore-unfixed \
    --format json \
    "${dockerImageName}" \
    | tee "${LOG_FILE}"

# Check if any vulnerabilities were found
if grep -q '"Vulnerabilities":\[\]' "${LOG_FILE}"; then
    echo "No vulnerabilities found"
else
    # Generate HTML report
    trivy --format html --output "${REPORT_DIR}/trivy-report.html" "${dockerImageName}"

    # Upload report to Jenkins
    if [[ -n "${JENKINS_HOME}" ]]; then
        echo "Uploading report to Jenkins"
        ${WORKSPACE}/trivy-reports-trivy-upload.sh "${REPORT_DIR}"
    fi

    # Check if any critical vulnerabilities were found
    if grep -q '"Severity":"CRITICAL"' "${LOG_FILE}"; then
        echo "Critical vulnerabilities found"
        exit 1
    fi
fi

# Clean up reports
rm -rf "${REPORT_DIR}"
