pipeline {
    agent any

    environment {
        JAVA_HOME = '/opt/java/openjdk'  // Docker에서의 Java 경로
    }

    stages {
        stage('Checkout') {
            steps {
                // Git에서 코드 체크아웃
                git branch: 'master', credentialsId: 'paran', url: 'https://github.com/MeteoRiver/paran_msa.git'
            }
        }

        stage('Build') {
            steps {
                script {
                    // Gradle Wrapper를 사용하여 clean 및 bootJar 실행
                    sh '''#!/bin/bash
                    export JAVA_HOME="$JAVA_HOME"

                    # 모듈 리스트
                    all_modules=("server:gateway-server" "server:config-server" "server:eureka-server"
                                 "service:user-service" "service:group-service" "service:chat-service"
                                 "service:file-service" "service:room-service" "service:comment-service")

                    # Gradle clean
                    echo "Cleaning..."
                    ./gradlew clean

                    # Gradle BootJar
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
                script {
                    def modules = ["gateway-server", "config-server", "eureka-server", 
                                   "user-service", "group-service", "chat-service", 
                                   "file-service", "room-service", "comment-service"]
        
                    for (module in modules) {
                        // Docker 이미지 빌드
                        def image = docker.build("meteoriver/${module}:${env.BUILD_ID}", "./${module}")  // ./gateway-server                        // 이미지 푸시
                        image.push("${env.BUILD_ID}")
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Docker Hub에 이미지 푸시
                    docker.withRegistry('https://registry.hub.docker.com', 'paran-docker') {
                        // 모듈 리스트
                        def modules = ["gateway-server", "config-server", "eureka-server", 
                                       "user-service", "group-service", "chat-service", 
                                       "file-service", "room-service", "comment-service"]
        
                        // 각 서비스에 대해 Docker Hub에 푸시
                        for (module in modules) {
                            // Docker 이미지 빌드
                            def image = docker.build("meteoriver/${module}:${env.BUILD_ID}")
                            
                            // 이미지 푸시
                            image.push("${env.BUILD_ID}")
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Kubernetes에 배포
                    def modules = ["gateway-server", "config-server", "eureka-server", 
                                   "user-service", "group-service", "chat-service", 
                                   "file-service", "room-service", "comment-service"]
        
                    for (module in modules) {
                        // 각 모듈의 이미지를 설정
                        sh "kubectl set image deployment/${module} ${module}=meteoriver/${module}:${env.BUILD_ID}"
                    }
                }
            }
        }

    } // stages 종료

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
