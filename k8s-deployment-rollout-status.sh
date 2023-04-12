#!/bin/bash
# check the status of a Kubernetes Deployment rollout and report if the rollout has succeeded or failed.
# đảm bảo application được deploy không có lỗi và tránh những issue như downtime hoặc application crash
ensure that your application is deployed correctly and avoid issues like downtime or application crashes caused by failed deployments
sleep 10s

if [[ $(kubectl -n default rollout status deploy ${deploymentName} --timeout 5s) != *"successfully rolled out"* ]]; then
    echo "Deployment ${deploymentName} Rollout has Failed"
    kubectl -n default rollout undo deploy ${deploymentName}
    exit 1;

else
    echo "Deployment ${deploymentName} Rollout is Success"
fi
