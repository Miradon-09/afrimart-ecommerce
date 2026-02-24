pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = sh(script: 'aws sts get-caller-identity --query Account --output text', returnStdout: true).trim()
        AWS_REGION     = 'us-east-1'
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        BACKEND_REPO   = 'afrimart-backend'
        FRONTEND_REPO  = 'afrimart-frontend'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('backend') {
                    sh 'npm install --engine-strict=false'
                }
                dir('frontend') {
                    sh 'npm install --engine-strict=false'
                }
            }
        }

        stage('Security Scan') {
            steps {
                sh 'trivy fs .'
            }
        }

        stage('Build & Push Backend') {
            steps {
                dir('backend') {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}"
                    sh "docker build -t ${ECR_URL}/${BACKEND_REPO}:latest ."
                    sh "docker push ${ECR_URL}/${BACKEND_REPO}:latest"
                }
            }
        }

        stage('Build & Push Frontend') {
            steps {
                dir('frontend') {
                    sh "docker build -t ${ECR_URL}/${FRONTEND_REPO}:latest ."
                    sh "docker push ${ECR_URL}/${FRONTEND_REPO}:latest"
                }
            }
        }

        stage('Deploy to Staging') {
            steps {
                echo 'Deploying to staging environment...'
                // This will be handled by Ansible in later phases
                sh 'ansible-playbook ansible/playbooks/site.yml --limit webservers'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Build Successful!'
        }
        failure {
            echo 'Build Failed!'
        }
    }
}
