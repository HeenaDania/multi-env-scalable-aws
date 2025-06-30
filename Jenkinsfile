pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-root-account')      // Replace with your Jenkins AWS credential ID
        AWS_SECRET_ACCESS_KEY = credentials('aws-root-account')      // Replace with your Jenkins AWS credential ID
        TF_VAR_db_password    = credentials('db-password')           // Replace with your Jenkins DB password credential ID
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {
        stage('Check AWS Credentials') {
            steps {
                bat 'aws sts get-caller-identity'
            }
        }
        stage('Check Terraform Version') {
            steps {
                bat 'terraform --version'
            }
        }
        stage('Terraform Init') {
            steps {
                dir('envs/staging') {
                    bat 'terraform init'
                }
            }
        }
    }
}
