pipeline {
    agent any

    environment {
        JAVA_HOME = '/opt/java/openjdk'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', credentialsId: 'paran', url: 'https://github.com/MeteoRiver/paran_msa.git'
            }
        }

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
                      ./gradlew :$module:bootJar
                    done
                    '''
                }
            }
        }

        stages {
                stage('Build Docker Images') {
                    steps {
                        sh 'pwd'  // 현재 작업 디렉토리 확인
                        sh 'ls -al'  // 파일 목록 확인
                        sh 'docker-compose -f docker-compose.yml up -d --build'
                        sh 'docker-compose -f docker-compose.yml logs'  // 로그 확인
                    }
                }

                stage('Push to Docker Hub') {
                    steps {
                        script {
                            docker.withRegistry('https://registry.hub.docker.com', 'paran-docker') {
                                def modules = ["gateway-server", "config-server", "eureka-server",
                                               "user-service", "group-service", "chat-service",
                                               "file-service", "room-service", "comment-service"]

                                for (module in modules) {
                                    try {
                                        def image = docker.build("meteoriver/${module}:${env.BUILD_ID}", "./${module}")
                                        image.push("latest")
                                        image.push("${env.BUILD_ID}")
                                    } catch (Exception e) {
                                        echo "Error building or pushing image for ${module}: ${e.getMessage()}"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def modules = ["gateway-server", "config-server", "eureka-server",
                                   "user-service", "group-service", "chat-service",
                                   "file-service", "room-service", "comment-service"]

                    for (module in modules) {
                        sh "kubectl set image deployment/${module} ${module}=meteoriver/${module}:${env.BUILD_ID}"
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