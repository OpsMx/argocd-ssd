#!/bin/bash

NAMESPACE="ssd"
OUTPUT_FILE="namespace_logs.txt"

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Get all pod names in the namespace
for pod in $(sudo kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}'); do
  # Get all containers in the pod
  for container in $(sudo kubectl get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.spec.containers[*].name}'); do
    echo "========== Logs from Pod: $pod, Container: $container ==========" >> "$OUTPUT_FILE"
    sudo kubectl logs -n "$NAMESPACE" -c "$container" "$pod" >> "$OUTPUT_FILE" 2>&1
    echo -e "\n\n" >> "$OUTPUT_FILE"
  done
done

echo "Logs have been saved to $OUTPUT_FILE"
