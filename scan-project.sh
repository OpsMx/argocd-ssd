#!/bin/bash

# Ensure the script stops if any command fails (optional but recommended for debugging)

set -e

#if [ $SSD_URL=="" ]; then
#   echo "SSD_URL environment variable is not found, required to set SSD_URL, SSD_TEAM_TOKEN"
#   exit 1 
#fi

#if [ $SSD_TEAM_TOKEN=="" ]; then
#   echo "SSD_TEAM_TOKE environment variable is not found, required to set SSD_URL, SSD_TEAM_TOKEN"
#   exit 1 
#fi
echo $SSD_URL
echo $SSD_TEAM_TOKEN
#echo $VM_IP
UPLOAD_URL=$SSD_URL
SSD_TOKEN=$SSD_TEAM_TOKEN
#UPLOAD_IP=$VM_IP
DNS=$(echo "$SSD_URL" | awk -F[/:] '{print $4}')
#HOST=$DNS:$UPLOAD_IP

# Check if the correct number of arguments are passed (host and organisationname)
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <giturl> <gitbranch>"
    exit 1
fi

# Assign command-line arguments to variables
GIT_URL=$1
GIT_BRANCH=$2


BUILD_ID=$RANDOM
ARTIFACT_NAME="sample_artifact-$BUILD_ID.dll"
ARTIFACT_TAG="$BUILD_ID"
JOBNAME="sample_job"
BUILD_NUMBER=$BUILD_ID
JENKINS_JOB_URL="Jenkins"
BUILD_USER="anonymous"
SCM_REPO_URL=$GIT_URL
SCM_BRNACH=$GIT_BRANCH
APPLICATION_ENV="dev"
APPLICATION_NAME="$(basename -s .git "$GIT_URL")" #change this to project name from GIT URL
NAMESPACE=$APPLICATION_NAME
ARTIFACT_STRING="sample_artifact-$BUILD_ID|$ARTIFACT_TAG|$ARTIFACT_NAME" 
SERVICE_NAME=$APPLICATION_NAME

SCM_PATH_IN_LOCAL=`pwd`
ARTIFACT_PATH_IN_LOCAL=`pwd`

# check for prereqs
# check for git
command -v git >/dev/null 2>&1 || { echo >&2 "git is required but it's not installed.  Aborting."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo >&2 "docker is required but it's not installed.  Aborting."; exit 1; }

sudo docker run -v $SCM_PATH_IN_LOCAL:/home/scanner/source/ docker.io/opsmx11/ssd-scanner-cli:379a293-29   --scanners=semgrep,trivy,openssf --trivy-scanners=sourcecodesbom,codelicensescan,codesecretscan  --artifact-type=file --artifact-name="$ARTIFACT_NAME"   --artifact-tag="$ARTIFACT_TAG" --artifact-path=/home/scanner/source/ --source-code-path="/home/scanner/source/"   --repository-url="$GIT_URL"   --branch="$GIT_BRANCH"   --build-id="$BUILD_NUMBER"   --offline-mode=false --upload-url="$SSD_URL" --ssd-token="$SSD_TOKEN"


curl --location "$SSD_URL/webhook/v1/ssd" \
--header "Content-Type: application/json" \
--data '{
  "jobname": "'"$JOBNAME"'",
  "buildnumber": "'"$BUILD_NUMBER"'",
  "joburl": "'"$JENKINS_JOB_URL"'",
  "gitcommit": "'"$LATEST_COMMIT_ID"'",
  "builduser": "'"$BUILD_USER"'",
  "giturl": "'"$GIT_URL"'",
  "gitbranch": "'"$GIT_BRANCH"'",
  "account": "'"$APPLICATION_ENV"'",
  "applicationname": "'"$APPLICATION_NAME"'",
  "namespace": "'"$NAMESPACE"'",
  "artifacts": [
    {
      "nonimage": "'"$ARTIFACT_STRING"'",
      "service": "'"$SERVICE_NAME"'"
    }
  ]
}'

