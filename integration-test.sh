sleep 5s

PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

echo "serviceName: ${serviceName}"
echo "applicationURL: ${applicationURL}"
echo "applicationURI: ${applicationURI}"

echo "PORT: $PORT"
echo "URL: $applicationURL:$PORT$applicationURI"

if [[ ! -z "$PORT" ]];
then
    response=$(curl -s $applicationURL:$PORT$applicationURI)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" $applicationURL:$PORT$applicationURI)

    echo "response: $response"
    echo "http_code: $http_code"

    if [[ "$response" == 100 ]];
        then
            echo "Increment Test Passed"
        else
            echo "Increment Test Failed"
            exit 1;
    fi;
    echo "http_code: $http_code"
    if [[ "$http_code" == 200 ]];
        then
            echo "HTTP Status Code Test Passed"
        else
            echo "HTTP Status code is not 200"
            exit 1;
    fi;

else
        echo "The Service does not have a NodePort"
        exit 1;
fi;
