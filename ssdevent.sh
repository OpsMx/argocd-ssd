stage('Notify SSD') {
    steps {
        sh """
            curl --location '<SSDURL>/webhook/v1/ssd' \\
            --header 'Content-Type: application/json' \\
            --header 'X-OpsMx-Auth: <Token>' \\
            --data '{
              "jobname": "${JOB_NAME}",
              "buildnumber": "${BUILD_NUMBER}",
              "joburl": "${JOB_URL}",
              "builduser": "BuildUser",
              "giturl": "${GIT_URL}",
              "gitbranch": "main",
              "account": "dev",
              "applicationname": "AppName",
              "namespace": "default",
              "artifacts": [
                { "image": "${ECR_REGISTRY}/docker-swarm:${BUILD_NUMBER}", "service": "$ServiceName", "sourcecodepath": "$ServiceName" },
                { "image": "${ECR_REGISTRY}/buildme:${BUILD_NUMBER}", "service": "$ServiceName", "sourcecodepath": "$ServiceName" },
                { "image": "${ECR_REGISTRY}/mongo:${BUILD_NUMBER}", "service": "$ServiceName", "sourcecodepath": "$ServiceName" },
                { "image": "${ECR_REGISTRY}/petclinic:${BUILD_NUMBER}", "service": "$ServiceName", "sourcecodepath": "$ServiceName" },
                { "image": "${ECR_REGISTRY}/scout:${BUILD_NUMBER}", "service": "$ServiceName", "sourcecodepath": "$ServiceName" }
              ]
            }'
        """
    }
}
