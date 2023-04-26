if [ -s "trivy-output.json" ]; then
  highVulnCount=$(jq '[.[] | select(.Vulnerabilities) | .Vulnerabilities[] | select(.Severity == "HIGH")] | length' trivy-output.json)
else
  highVulnCount=0
fi
echo "highVul: $highVulnCount"
