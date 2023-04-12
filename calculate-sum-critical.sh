output=($(grep -oP 'CRITICAL:\s*\K\d+' output-trivy.txt))

# Initialize sum variable
sum=0

# Loop over each number in the array and add to sum
for num in "${output[@]}"; do
    sum=$((sum + num))
done

# Output the sum
echo "Total critical vulnerabilities found: $sum"
