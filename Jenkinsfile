pipeline {

    agent {
        label 'DOCKER'
    }

    environment {
        GIT_COMMIT = sh(
            script: "git rev-parse HEAD",
            returnStdout: true
        ).trim()
        REGISTRY_CREDENTIALS = "ods-nexus-user"
        DOCKER_REPOSITORY_NAME = "dataplatform-docker"
        DOCKER_REPOSITORY_URL = "nexus.concardis.local:18082"
        PROJECT_PREFIX = "dataplatform-docker"
        IMAGE_NAME="collectd-prometheus-exporter"
    }

	stages {
        stage('Build Snapshot') {
            when {
                not {
                    anyOf {
                        branch 'master'
                        tag "*"
                    }
                }
            }

            steps {
				withDockerRegistry(credentialsId: "${env.REGISTRY_CREDENTIALS}", url: "http://${env.DOCKER_REPOSITORY_URL}") {
					sh """
                        #!/bin/bash
                        set -eu
                        IMAGE_TAG=latest-\$(echo -en \$GIT_BRANCH | tr -c '[:alnum:]_.-' '-')
                        docker build \
                        	--tag "${env.DOCKER_REPOSITORY_URL}/${env.IMAGE_NAME}:${env.GIT_COMMIT}" \
                        	--tag "${env.DOCKER_REPOSITORY_URL}/${env.IMAGE_NAME}:\$IMAGE_TAG" \
                        	.
                        docker push "${env.DOCKER_REPOSITORY_URL}/${env.IMAGE_NAME}:${env.GIT_COMMIT}"
                        docker push "${env.DOCKER_REPOSITORY_URL}/${env.IMAGE_NAME}:\$IMAGE_TAG"

                    """.stripIndent().trim()
				}
            }
		}

		stage('Build Release') {
            when {
                anyOf {
                    branch 'master'
                    tag "*"
                }
            }
            steps {
                withDockerRegistry(credentialsId: "${env.REGISTRY_CREDENTIALS}", url: "http://${env.DOCKER_REPOSITORY_URL}") {
					sh """
                        #!/bin/bash
                        set -eu
                        IMAGE_TAG=\$(cat VERSION)
                        docker build \
                        	--tag "${env.DOCKER_REPOSITORY_URL}/${env.IMAGE_NAME}:${env.GIT_COMMIT}" \
                        	--tag "${env.DOCKER_REPOSITORY_URL}/${env.IMAGE_NAME}:\$IMAGE_TAG" \
                        	.
                        docker push "${env.DOCKER_REPOSITORY_URL}/${env.IMAGE_NAME}:${env.GIT_COMMIT}"
                        docker push "${env.DOCKER_REPOSITORY_URL}/${env.IMAGE_NAME}:\$IMAGE_TAG"

                    """.stripIndent().trim()
                }
            }
        }
	}
}