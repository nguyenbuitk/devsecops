#!/bin/bash

#
# sed -i "s#replace#${imageName}#g" k8s-deployment-service.yaml
# # kubectl -n default apply -f k8s-deployment-service.yaml

# ## Error bash script don't take effect when apply this
# kubectl -n default get deployment ${deploymentName} > /dev/null

# #  output command = 1
# if [[ $? -ne 0 ]]; then
#     echo "deployment ${deploymentName} doesnt exist"
#     kubectl -n default apply -f k8s-deployment-service.yaml
# else
#     echo "deployment ${deployment} exist"
#     echo "image name - ${imageName}"
#     kubectl -n default set image deploy ${deploymentName} ${containerName}=${imageName} --record=true
# fi
#!/bin/bash

deploymentFile="k8s-deployment-service.yaml"
namespace="default"
timestamp=$(date +%Y%m%d%H%M%S)

# Backup the original deployment file
backupFile="${deploymentFile}.bak.${timestamp}"
cp "${deploymentFile}" "${backupFile}"

# Replace the placeholder with the image name
sed -i "s#replace#${imageName}#g" "${deploymentFile}"

# Apply the modified deployment file to the Kubernetes cluster
kubectl -n "${namespace}" apply -f "${deploymentFile}"

if [ $? -eq 0 ]; then
  echo "Deployment completed successfully."
else
  echo "Deployment failed."
  echo "Restoring the original deployment file..."
  mv "${backupFile}" "${deploymentFile}"
fi
