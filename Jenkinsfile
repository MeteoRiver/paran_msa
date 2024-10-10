pipeline {
    agent any

    environment {
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        repository = "meteoriver/paran"
        DOCKERHUB_CREDENTIALS = credentials('paran-docker')
        dockerImage = ''
    }

    stages {
        stage('Build') {
            steps {
                script {
                    sh '''#!/bin/bash
                    set -e
                    export JAVA_HOME="$JAVA_HOME"

                    all_modules=("server:gateway-server" "server:config-server" "server:eureka-server"
                                 "service:user-service" "service:group-service" "service:chat-service"
                                 "service:file-service" "service:room-service" "service:comment-service")

                    echo "Cleaning..."
                    ./gradlew clean

                    for module in "${all_modules[@]}"
                    do
                      echo "Building BootJar for $module"
                      ./gradlew :$module:bootJar || { echo "Build failed for $module"; exit 1; }
                    done
                    '''
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    def containerName = 'f2a88899c679_file'
                    def containerExists = sh(script: "docker ps -aq -f name=${containerName}", returnStdout: true).trim()
                    if (containerExists) {
                        sh "docker rm -f ${containerExists}"
                    }
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                sh 'pwd'
                sh 'ls -al'
                sh 'docker-compose up -d --build'
                sh 'docker images'
            }
        }

        stage('Login') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    def modules = ["config", "eureka", "user", "group", "chat", "file", "room", "comment", "gateway"]
                    for (module in modules) {
                        def imageTag = "${repository}:${module}-${env.BUILD_ID}"
                        echo "Tagging and pushing ${imageTag}"
                        sh "docker push ${imageTag}" || { echo "Failed to push ${imageTag}"; exit 1; }
                    }
                }
            }
        }

        stage('Cleaning up') {
            steps {
                sh "docker rmi ${repository}:${env.BUILD_ID}" || echo "No image found to remove."
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def modules = ["gateway", "config", "eureka", "user", "group", "chat", "file", "room", "comment"]
                    for (module in modules) {
                        sh "kubectl set image deployment/${module} ${module}=${repository}:${module}-${env.BUILD_ID}" || { echo "Failed to update image for ${module}"; exit 1; }
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}