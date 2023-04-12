#!/bin/bash

#
sed -i "s#replace#${imageName}#g" k8s_deployment_service.yaml

## Lỗi k8s pod không take effect khi sử dụng đoạn bash script này, chỉ có image là thay đổi
# kubectl -n default get deployment ${deploymentName} > /dev/null

# #  output command = 1
# if [[ $? -ne 0 ]]; then
#     echo "deployment ${deploymentName} doesnt exist"
#     kubectl -n default apply -f k8s_deployment_service.yaml
# else
#     echo "deployment ${deployment} exist"
#     echo "image name - ${imageName}"
#     kubectl -n default set image deploy ${deploymentName} ${containerName}=${imageName} --record=true
# fi
kubectl -n default apply -f k8s_deployment_service.yaml
