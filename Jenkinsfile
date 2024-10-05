pipeline {
    agent any
    
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'master', credentialsId: 'paran', url: 'https://github.com/MeteoRiver/paran_msa.git'
            }
        }
        
        stage('Build') {
            steps {
                script {
                    def modules = ['gateway-server', 'config-server', 'eureka-server', 'chat-service', 'comment-service', 'file-service', 'group-service', 'room-service', 'user-service'] // 모듈 이름으로 리스트를 수정하세요
                    
                    for (module in modules) {
                        dir(module) {
                            sh 'chmod +x ./gradlew'
                            sh './gradlew clean'
                            sh './gradlew build'
                        }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                // 배포 스크립트 실행
                sh 'docker-compose up -d'
            }
        }
    }
}
