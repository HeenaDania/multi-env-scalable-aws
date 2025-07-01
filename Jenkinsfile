// Jenkins Pipeline for Multi-Environment Infrastructure Deployment
// This pipeline can deploy to dev, staging, or prod environments

pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Select the environment to deploy'
        )
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select Terraform action'
        )
        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Auto approve Terraform apply/destroy (use with caution)'
        )
    }
    
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_ACCESS_KEY_ID     = credentials('aws-root-account')
        AWS_SECRET_ACCESS_KEY = credentials('aws-root-account')
        TF_VAR_db_password    = credentials('db-password')
        TF_VAR_key_name       = 'my-ec2-keypair'
        }
    
    stages {
        stage('Checkout') {
            steps {
                echo "🚀 Checking out code for ${params.ENVIRONMENT} environment"
                checkout scm
            }
        }
        
        stage('Setup') {
            steps {
                script {
                    echo "🔧 Setting up environment for ${params.ENVIRONMENT}"
                    
                    // Validate environment parameter
                    if (!['dev', 'staging', 'prod'].contains(params.ENVIRONMENT)) {
                        error("Invalid environment: ${params.ENVIRONMENT}")
                    }
                    
                    // Set working directory based on environment
                    env.WORKING_DIR = "envs/${params.ENVIRONMENT}"
                    
                    echo "Working directory: ${env.WORKING_DIR}"
                }
            }
        }

        stage('Debug Workspace') {
            steps {
                dir(env.WORKING_DIR) {
                    bat 'dir'
                }
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir(env.WORKING_DIR) {
                    script {
                        echo "🏗️ Initializing Terraform for ${params.ENVIRONMENT}"
                        
                        // Initialize Terraform
                        bat '''
                            terraform --version
                            terraform init -reconfigure
                        '''
                    }
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                dir(env.WORKING_DIR) {
                    script {
                        echo "✅ Validating Terraform configuration"
                        bat 'terraform validate'
                    }
                }
            }
        }
        
        stage('Terraform Plan') {
            when {
                anyOf {
                    expression { params.ACTION == 'plan' }
                    expression { params.ACTION == 'apply' }
                }
            }
            steps {
                dir(env.WORKING_DIR) {
                    script {
                        echo "📋 Creating Terraform plan for ${params.ENVIRONMENT}"
                        
                        bat '''
                            terraform plan -out=tfplan -detailed-exitcode
                        '''
                        
                        // Archive the plan file
                        archiveArtifacts artifacts: 'tfplan', fingerprint: true
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir(env.WORKING_DIR) {
                    script {
                        echo "🚀 Applying Terraform changes to ${params.ENVIRONMENT}"
                        
                        if (params.AUTO_APPROVE || params.ENVIRONMENT == 'dev') {
                            echo "Auto-approving Terraform apply"
                            bat 'terraform apply -auto-approve tfplan'
                        } else {
                            // Manual approval for staging and prod
                            input message: "Apply Terraform changes to ${params.ENVIRONMENT}?", 
                                  ok: 'Apply',
                                  parameters: [
                                      text(name: 'APPROVAL_REASON', 
                                           description: 'Reason for applying changes', 
                                           defaultValue: '')
                                  ]
                            
                            bat 'terraform apply -auto-approve tfplan'
                        }
                        
                        // Save outputs
                        bat '''
                            terraform output -json > terraform-outputs.json
                            terraform output application_url > application-url.txt
                        '''
                        
                        // Archive outputs
                        archiveArtifacts artifacts: 'terraform-outputs.json,application-url.txt', 
                                       fingerprint: true
                    }
                }
            }
        }
        
        stage('Terraform Destroy Plan') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir(env.WORKING_DIR) {
                    script {
                        echo "💥 Creating Terraform destroy plan for ${params.ENVIRONMENT}"
                        
                        bat 'terraform plan -destroy -out=destroy-plan'
                        
                        // Archive the destroy plan
                        archiveArtifacts artifacts: 'destroy-plan', fingerprint: true
                    }
                }
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir(env.WORKING_DIR) {
                    script {
                        echo "💥 Destroying infrastructure in ${params.ENVIRONMENT}"
                        
                        // Always require manual approval for destroy
                        input message: "⚠️ DESTROY all infrastructure in ${params.ENVIRONMENT}? This action cannot be undone!", 
                              ok: 'DESTROY',
                              parameters: [
                                  text(name: 'DESTROY_CONFIRMATION', 
                                       description: 'Type "DESTROY" to confirm', 
                                       defaultValue: ''),
                                  text(name: 'DESTROY_REASON', 
                                       description: 'Reason for destroying infrastructure', 
                                       defaultValue: '')
                              ]
                        
                        // Validate confirmation
                        script {
                            if (DESTROY_CONFIRMATION != 'DESTROY') {
                                error('Destroy not confirmed. Type "DESTROY" to confirm.')
                            }
                        }
                        
                        // Destroy infrastructure with dependency handling
                        bat '''
                            echo "Starting infrastructure destruction..."
                            terraform apply -auto-approve destroy-plan
                            echo "Infrastructure destroyed successfully"
                        '''
                    }
                }
            }
        }
        
        stage('Health Check') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "🔍 Performing health check on ${params.ENVIRONMENT}"
                    
                    dir(env.WORKING_DIR) {
                        // Wait for infrastructure to be ready
                        sleep time: 2, unit: 'MINUTES'
                        
                        try {
                            // Get the ALB DNS name from Terraform output
                            def albDns = bat(
                                script: 'terraform output -raw alb_dns_name',
                                returnStdout: true
                            ).trim()
                            
                            echo "Application URL: http://${albDns}"
                            
                            // Simple health check
                            def healthCheck = bat(
                                script: "curl -f -s -o /dev/null -w \"%{http_code}\" http://${albDns}",
                                returnStdout: true
                            ).trim()
                            
                            if (healthCheck == '200') {
                                echo "✅ Health check passed! Application is responding."
                            } else {
                                echo "⚠️ Health check returned status: ${healthCheck}"
                            }
                            
                        } catch (Exception e) {
                            echo "⚠️ Health check failed: ${e.getMessage()}"
                            echo "This might be normal if the infrastructure is still starting up."
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "🧹 Cleaning up workspace"
                
                // Clean up plan files
                dir(env.WORKING_DIR) {
                    bat '''
                        if exist tfplan del tfplan
                        if exist destroy-plan del destroy-plan
                        if exist .terraform.lock.hcl del .terraform.lock.hcl
                    '''
                }
            }
        }
        
        success {
            script {
                def actionEmoji = [
                    'plan': '📋',
                    'apply': '🚀',
                    'destroy': '💥'
                ]
                
                echo "${actionEmoji[params.ACTION]} SUCCESS: Terraform ${params.ACTION} completed successfully for ${params.ENVIRONMENT}"
                
                if (params.ACTION == 'apply') {
                    dir(env.WORKING_DIR) {
                        try {
                            def appUrl = readFile('application-url.txt').trim()
                            echo """
                            🎉 Deployment Successful!
                            
                            Environment: ${params.ENVIRONMENT}
                            Application URL: ${appUrl}
                            
                            Your Modern Photo Gallery is now live! 🖼️
                            """
                        } catch (Exception e) {
                            echo "Could not read application URL: ${e.getMessage()}"
                        }
                    }
                }
            }
        }
        
        failure {
            script {
                echo "❌ FAILED: Terraform ${params.ACTION} failed for ${params.ENVIRONMENT}"
                echo "Check the logs above for details."
            }
        }
        
        aborted {
            script {
                echo "⏹️ ABORTED: Terraform ${params.ACTION} was aborted for ${params.ENVIRONMENT}"
            }
        }
    }
}
