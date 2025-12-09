#!/bin/bash

# Load parameters
source params.env

# Get Docker socket group ID (macOS)
DOCKER_GID=$(stat -f '%g' /var/run/docker.sock)

# Path where scan-results should exist
SCAN_RESULTS_DIR="${LOCAL_SOURCE_PATH}/scan-results"

# Check if LOCAL_SOURCE_PATH exists
if [[ ! -d "$LOCAL_SOURCE_PATH" ]]; then
    echo "❌ ERROR: LOCAL_SOURCE_PATH does NOT exist: $LOCAL_SOURCE_PATH"
    echo "Please create it manually before running this script."
    exit 1
fi

echo "✔ LOCAL_SOURCE_PATH exists: $LOCAL_SOURCE_PATH"

# Create scan-results folder only if missing
if [[ -d "$SCAN_RESULTS_DIR" ]]; then
    echo "✔ scan-results folder already exists: $SCAN_RESULTS_DIR"
else
    echo "📁 scan-results missing → creating: $SCAN_RESULTS_DIR"
    mkdir -p "$SCAN_RESULTS_DIR"
    chmod 777 "$SCAN_RESULTS_DIR"
    echo "🎉 scan-results folder created with 777 permissions"
fi

# Run container
sudo docker run -it --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --group-add ${DOCKER_GID} \
    -v "$HOME/.docker/config.json:/home/scanner/.docker/config.json" \
    -v "${SCAN_RESULTS_DIR}:/home/scanner/.local/bin/ssd-scan-results" \
    -v "${LOCAL_SOURCE_PATH}:/home/scanner/source" \
    opsmx11/ssd-scanner-cli:arm-v1.4 \
    --scanners=trivy,grype \
    --build-id="${BUILD_ID}" \
    --artifact-type=image \
    --artifact-name="${ARTIFACT_NAME}" \
    --artifact-tag="${ARTIFACT_TAG}" \
    --trivy-scanners=imagelicensescan,imagesecretscan \
    --grype-scanners=sbom \
    --offline-mode \
    --firewall-evaluate
