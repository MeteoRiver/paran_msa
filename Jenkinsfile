pipeline {
    agent any

    // 환경 설정
    environment {
        // 사용 환경에 맞게 JAVA_HOME을 설정하세요.
        // Docker에서 실행 중일 때
        JAVA_HOME = '/opt/java/openjdk'  // Docker에서의 Java 경로
        
        // MacOS에서 실행 중일 때
        // JAVA_HOME = '/Library/Java/JavaVirtualMachines/corretto-17.0.11.jdk/Contents/Home'
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
                    all_modules=("server:api-gateway" "server:config-server" "server:eureka-server"
                                 "service:user-service" "service:auth-service" "service:chat-service"
                                 "service:admin-service" "service:post-service" "service:shop-service"
                                 "service:community-service" "service:review-service")

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

        stage('Deploy') {
            steps {
                // Docker Compose로 배포
                sh 'docker-compose up -d'
            }
        }
    }
}
