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
                // 빌드 스크립트 실행
                sh './gradlew build'
            }
        }
        
        stage('Deploy') {
            steps {
                // 배포 스크립트 실행
                sh 'docker-compose up'
            }
        }
    }
}
