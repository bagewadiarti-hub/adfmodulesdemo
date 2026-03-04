pipeline {
    agent any

    tools {
        terraform 'terraform'
    }

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'prod'],
            description: 'Select environment to deploy'
        )
    }

    stages {

        stage('Azure Login (Bootstrap)') {
            steps {
                withCredentials([
                    string(credentialsId: 'azure-client-id', variable: 'SP_CLIENT_ID'),
                    string(credentialsId: 'azure-client-secret', variable: 'SP_CLIENT_SECRET'),
                    string(credentialsId: 'azure-tenant-id', variable: 'SP_TENANT_ID')
                ]) {
                    bat 'az login --service-principal --username %SP_CLIENT_ID% --password %SP_CLIENT_SECRET% --tenant %SP_TENANT_ID%'
                }
            }
        }

        stage('Fetch Secrets from Key Vault') {
    steps {
        script {

            env.ARM_CLIENT_ID = bat(
                script: '@az keyvault secret show --vault-name ADFDemoKeyVault177 --name azure-client-id --query value -o tsv',
                returnStdout: true
            ).trim()

            env.ARM_CLIENT_SECRET = bat(
                script: '@az keyvault secret show --vault-name ADFDemoKeyVault177 --name azure-client-secret --query value -o tsv',
                returnStdout: true
            ).trim()

            env.ARM_TENANT_ID = bat(
                script: '@az keyvault secret show --vault-name ADFDemoKeyVault177 --name azure-tenant-id --query value -o tsv',
                returnStdout: true
            ).trim()

            env.ARM_SUBSCRIPTION_ID = bat(
                script: '@az keyvault secret show --vault-name ADFDemoKeyVault177 --name azure-subscription-id --query value -o tsv',
                returnStdout: true
            ).trim()
        }
    }
}
        stage('Terraform Format Check') {
            steps {
                dir("env/${params.ENV}") {
                    bat 'terraform fmt -check -recursive'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir("env/${params.ENV}") {
                    bat 'terraform init -backend-config=resource_group_name=tf-rg -backend-config=storage_account_name=tfstorageprod177 -backend-config=container_name=tfstate -backend-config=key=adf-%ENV%.tfstate'
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
