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

# Set the name of the Docker image to scan
dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo "Docker image to scan: $dockerImageName"

# Print the current user and working directory
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"

# Pull the Trivy image
docker pull aquasec/trivy:0.18.3

# Define the path for the scan report
scanHighReportPath="$WORKSPACE/trivy-output-high.json"
scanCriticalReportPath="$WORKSPACE/trivy-output-critical.json"

# Scan the Docker image for vulnerabilities with Trivy
# docker run --rm -v "$WORKSPACE:/root/.cache/" aquasec/trivy:0.18.3 image --light --format json -o "$scanReportPath" "$dockerImageName"
docker run --rm -v "$WORKSPACE:/root/.cache/" aquasec/trivy:0.18.3 -q image --exit-code 0 --severity HIGH --light --format json -o /root/.cache/trivy-output-high.json $dockerImageName
docker run --rm -v "$WORKSPACE:/root/.cache/" aquasec/trivy:0.18.3 -q image --exit-code 0 --severity CRITICAL --light --format json -o /root/.cache/trivy-output-critical.json $dockerImageName

# Extract the vulnerability counts from the scan report
if [ -s "trivy-output-high.json" ]; then
  highVulnCount=$(jq '[.[] | select(.Vulnerabilities) | .Vulnerabilities[] | select(.Severity == "HIGH")] | length' trivy-output-high.json)
else
  highVulnCount=0
fi

if [ -s "trivy-output-critical.json" ]; then
  criticalVulnCount=$(jq '[.[] | select(.Vulnerabilities) | .Vulnerabilities[] | select(.Severity == "CRITICAL")] | length' trivy-output-critical.json)
else
  criticalVulnCount=0
fi

# Print the vulnerability counts
echo "High severity vulnerabilities found: $highVulnCount"
echo "Critical severity vulnerabilities found: $criticalVulnCount"

# Check if any critical vulnerabilities were found
if (( criticalVulnCount > 3 )); then
  echo "Image scanning failed. Critical vulnerabilities found."
  exit 1
else
  echo "Image scanning passed. No critical vulnerabilities found."
fi

# /var/lib/jenkins/jobs/devsecops-numeric-application/builds/277/archive/trivy-scan-report-critical.json
# Save the scan report artifact in Jenkins
if [[ -f "$scanHighReportPath" ]]; then
  echo "Archiving scan report artifact..."
  archiveName="trivy-scan-report-high.json"
  archivePath="$WORKSPACE/$archiveName"
  cp "$scanHighReportPath" "$archivePath"
  echo "Archived scan report artifact to: $archivePath"
  # echo "Fingerprinting scan report artifact..."
  # fingerprint "$archivePath"
else
  echo "Scan report not found. Skipping archive and fingerprint steps."
fi

if [[ -f "$scanCriticalReportPath" ]]; then
  echo "Archiving scan report artifact..."
  archiveName="trivy-scan-report-critical.json"
  archivePath="$WORKSPACE/$archiveName"
  cp "$scanCriticalReportPath" "$archivePath"
  echo "Archived scan report artifact to: $archivePath"
  # echo "Fingerprinting scan report artifact..."
  # fingerprint "$archivePath"
else
  echo "Scan report not found. Skipping archive and fingerprint steps."
fi


# # Clean up the scan report file
# rm "$scanReportPath"
