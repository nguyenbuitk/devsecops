opa_output=$(docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile)
# echo $opa_output
number_of_failures=$(echo $opa_output | grep -oP '\d+ failures' | awk '{print $1}' | cut -d' ' -f1)

if (( number_of_failures > 0 )); then
  echo "OPA Conftest found policy violations"
  exit 1
else
  echo "OPA Conftest passed - no policy violations found"
fi
