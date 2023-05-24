POLICY_FILE=opa-k8s-security.rego
opa_output=$(docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy ${POLICY_FILE} k8s-deployment-service.yaml)
exit_code=$?
echo $opa_output
# number_of_failures=$(echo $opa_output | grep -oP '\d+ failures' | awk '{print $1}' | cut -d' ' -f1)

# Check the exit code of the OPA Conftest command
if [[ "${exit_code}" == 1 ]]; then
  echo "OPA Conftest found policy violations with K8s resources"
  exit 1
elif [[ "${exit_code}" == 2 ]]; then
  echo "OPA Conftest encountered an error with K8s resources"
  exit 1
else
  echo "OPA Conftest passed - no policy violations found"
fi
