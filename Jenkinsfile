pipeline {
    agent any
    
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'BE', credentialsId: 'paran', url: 'https://github.com/MeteoRiver/paran_msa.git'
            }
        }
        
        stage('Build') {
            steps {
                // 빌드 스크립트 실행 (예: Maven, Gradle 등)
                sh 'echo "Building the project..."'
            }
        }
        
        stage('Deploy') {
            steps {
                // 배포 스크립트 실행
                sh 'echo "Deploying the project..."'
            }
        }
    }
}
