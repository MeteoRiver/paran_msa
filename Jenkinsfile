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

        stage('Build Docker Images') {
            steps {
                sh 'pwd'  // 현재 작업 디렉토리 확인
                sh 'ls -al'  // 파일 목록 확인
                dir('./path/to/your/docker-compose') {  // docker-compose.yml 파일이 있는 디렉토리로 이동
                    sh 'docker-compose up -d --build'
                    sh 'docker images' // 현재 빌드된 이미지 확인
                    sh 'docker-compose logs'  // 로그 확인
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'paran-docker') {
                        def modules = ["config", "eureka", "user", "group", "chat", "file", "room", "comment", "gateway"]

                        for (module in modules) {
                            def imageTag = "meteoriver/${module}:${env.BUILD_ID}"

                            sh 'pwd'  // 현재 작업 디렉토리 확인
                            sh 'ls -al'  // 파일 목록 확인
                            // 현재 빌드된 이미지 확인
                            sh "docker images"

                            // 태그와 푸시
                            sh "docker tag meteoriver/${module}:latest ${imageTag}" // 태그를 추가
                            sh "docker push ${imageTag}" // 이미지를 푸시
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def modules = ["gateway", "config", "eureka", "user", "group", "chat", "file", "room", "comment"]

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