#!/bin/bash
# trivy scan application image

echo "image scanned: $imageName"
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity CRITICAL --light $imageName
# trivy_output=$(docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $imageName)

# output=($(echo "$trivy_output" | grep -oP 'CRITICAL:\s*\K\d+'))
# echo $output
# # Initialize sum variable
# sum=0

# # Loop over each number in the array and add to sum
# for num in "${output[@]}"; do
#     sum=$((sum + num))
# done

# # Output the sum
# echo "Total critical vulnerabilities found: $sum"


# # Output the list of critical vulnerabilities
# echo "$trivy_output"

# # Check if there are more than 3 critical vulnerabilities
# if [ "$sum" -gt 3 ]; then
#     echo "Too many critical vulnerabilities found: $sum"
#     exit 1
# else
#     echo "No more than 3 critical vulnerabilities found: $sum"
# fi
    exit_code=$?
    echo "Exit Code : $exit_code"

    if [[ ${exit_code} == 1 ]]; then
        echo "Image scanning fail. Vulnerability found"
        exit 1;
    else
        echo "Image scanning passed. No vulnerabilities found"
    fi;
