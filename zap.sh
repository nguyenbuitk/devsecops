#!/bin/bash
# Because of zap run when application is running, so we need nodePort to do that.
PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

chmod 777 $(pwd)
echo $(id -u):$(id -g)
# docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -t $applicationURL:$PORT/v3/api-docs -f openapi -r zap_report.html
# -v $(pwd):/zap/wrk/:rw : mount volume nhằm mount data của report ra machine
# `-t owasp/zap2docker-weekly` it's the owasp/zap2docker-weekly image
# `-t $applicationURL:$PORT/v3/api-docs` This specifies the target API to scan.
# `zap-api-scan.py` is a Python script that is included with the OWASP ZAP Docker image. It is used to run automated scans on RESTful APIs using the ZAP tool.
# `-f openapi` This specifies the format of the API documentation. In this case, it's OpenAPI.
# `-c zap_rules` This specifies the ruleset to use for the scan. In this case, it's the zap_rules ruleset, which is a collection of predefined rules for ZAP scans.
docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -t $applicationURL:$PORT/v3/api-docs -f openapi -c zap_rules -r zap_report.html
sudo mkdir -p owasp-zap-report
sudo mv zap_report.html owasp-zap-report

exit_code=$?

echo "Exit code: $exit_code"

    if [[ ${exit_code} -ne 0 ]]; then
        echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
        exit 1;
        else
            echo "OWASP ZAP did not report any Risk"
    fi;
