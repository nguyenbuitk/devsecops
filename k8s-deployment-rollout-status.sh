#!/bin/bash
# check the status of a Kubernetes Deployment rollout and report if the rollout has succeeded or failed.
# ensure that your application is deployed correctly and avoid issues like downtime or application crashes caused by failed deployments

sleep 10s
deploymentName=devsecops
namespace=default
timeout=60s

if [[ $(kubectl -n "${namespace}" rollout status deploy "${deploymentName}" --timeout "${timeout}") != *"deployment \""${deploymentName}"\" successfully rolled out"* ]]; then
    echo "Deployment ${deploymentName} Rollout has Failed"

    # Rollback the deployment to the previous revision
    kubectl -n "${namespace}" rollout undo deploy "${deploymentName}"

    # Check the rollout status after rollback
    if [[ $(kubectl -n "${namespace}" rollout status deploy "${deploymentName}" --timeout "${timeout}") != *"deployment \""${deploymentName}"\" successfully rolled out"* ]]; then
        echo "Rollback of ${deploymentName} Failed"
        exit 1;
    else
        echo "Rollback of ${deploymentName} Successful"
    fi
else
    echo "Deployment ${deploymentName} Rollout is Success"
fi
