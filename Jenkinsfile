pipeline {
    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'prod'],
            description: 'Select environment to deploy'
        )
    }

    environment {
        ARM_CLIENT_ID       = credentials('azure-client-id')
        ARM_CLIENT_SECRET   = credentials('azure-client-secret')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_TENANT_ID       = credentials('azure-tenant-id')
    }

    stages {

        stage('Terraform Init') {
            steps {
                dir("env/${params.ENV}") {
                    bat 'terraform init -backend-config="resource_group_name=tf-rg" -backend-config="storage_account_name=tfstorageprod177" -backend-config="container_name=tfstate" -backend-config="key=adf-%ENV%.tfstate"'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("env/${params.ENV}") {
                    bat 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("env/${params.ENV}") {
                    bat 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Manual Approval') {
            when {
                expression { params.ENV == 'prod' }
            }
            steps {
                input message: "Approve deployment to PROD?", ok: "Deploy"
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("env/${params.ENV}") {
                    bat 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    post {
        success {
            echo "Deployment to ${params.ENV} completed successfully!"
        }
        failure {
            echo "Deployment failed. Check logs."
        }
    }
}
