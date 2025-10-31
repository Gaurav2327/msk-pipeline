pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Select action to perform: apply (create) or destroy (delete) resources'
        )
        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Auto approve terraform apply/destroy without manual confirmation'
        )
    }
    
    environment {
        AWS_REGION = 'us-east-1'
        TF_VERSION = '1.11'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Validate Terraform Version') {
            steps {
                sh '''
                    echo "Checking Terraform version..."
                    terraform version
                '''
            }
        }
        
        // =========================================
        // APPLY STAGES (Creation Order)
        // =========================================
        
        stage('Create Security Groups') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    dir('terraform/sg') {
                        echo "============================================"
                        echo "Creating Security Groups"
                        echo "============================================"
                        
                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform plan -out=tfplan'
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform apply -auto-approve tfplan'
                        } else {
                            input message: 'Approve Security Groups creation?', ok: 'Apply'
                            sh 'terraform apply tfplan'
                        }
                        
                        echo "Security Groups created successfully!"
                    }
                }
            }
        }
        
        stage('Create RDS') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    dir('terraform/rds') {
                        echo "============================================"
                        echo "Creating RDS Database"
                        echo "============================================"
                        
                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform plan -out=tfplan'
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform apply -auto-approve tfplan'
                        } else {
                            input message: 'Approve RDS creation?', ok: 'Apply'
                            sh 'terraform apply tfplan'
                        }
                        
                        echo "RDS Database created successfully!"
                    }
                }
            }
        }
        
        stage('Create MSK Cluster') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    dir('terraform/msk') {
                        echo "============================================"
                        echo "Creating MSK Cluster"
                        echo "============================================"
                        
                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform plan -target=aws_cloudwatch_log_group.msk_log_group -target=aws_msk_configuration.cluster_configuration -target=aws_msk_cluster.msk_cluster -target=aws_iam_role.msk_role -target=aws_iam_policy.msk_policy -target=aws_iam_role_policy_attachment.attach_msk_policy -out=tfplan-cluster'
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform apply -auto-approve tfplan-cluster'
                        } else {
                            input message: 'Approve MSK Cluster creation?', ok: 'Apply'
                            sh 'terraform apply tfplan-cluster'
                        }
                        
                        echo "MSK Cluster created successfully!"
                    }
                }
            }
        }
        
        stage('Create MSK Connector') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    dir('terraform/msk') {
                        echo "============================================"
                        echo "Creating MSK Connector"
                        echo "============================================"
                        
                        sh 'terraform plan -target=aws_mskconnect_custom_plugin.connector_plugin_debezium -target=aws_mskconnect_worker_configuration.connector_configuration -target=aws_mskconnect_connector.msk_cdc_connector -out=tfplan-connector'
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform apply -auto-approve tfplan-connector'
                        } else {
                            input message: 'Approve MSK Connector creation?', ok: 'Apply'
                            sh 'terraform apply tfplan-connector'
                        }
                        
                        echo "MSK Connector created successfully!"
                    }
                }
            }
        }
        
        // =========================================
        // DESTROY STAGES (Reverse Order)
        // =========================================
        
        stage('Destroy MSK Connector') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    dir('terraform/msk') {
                        echo "============================================"
                        echo "Destroying MSK Connector"
                        echo "============================================"
                        
                        sh 'terraform init'
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform destroy -target=aws_mskconnect_connector.msk_cdc_connector -target=aws_mskconnect_worker_configuration.connector_configuration -target=aws_mskconnect_custom_plugin.connector_plugin_debezium -auto-approve'
                        } else {
                            input message: 'Approve MSK Connector destruction?', ok: 'Destroy'
                            sh 'terraform destroy -target=aws_mskconnect_connector.msk_cdc_connector -target=aws_mskconnect_worker_configuration.connector_configuration -target=aws_mskconnect_custom_plugin.connector_plugin_debezium -auto-approve'
                        }
                        
                        echo "MSK Connector destroyed successfully!"
                    }
                }
            }
        }
        
        stage('Destroy MSK Cluster') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    dir('terraform/msk') {
                        echo "============================================"
                        echo "Destroying MSK Cluster"
                        echo "============================================"
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform destroy -target=aws_msk_cluster.msk_cluster -target=aws_msk_configuration.cluster_configuration -target=aws_cloudwatch_log_group.msk_log_group -auto-approve'
                        } else {
                            input message: 'Approve MSK Cluster destruction?', ok: 'Destroy'
                            sh 'terraform destroy -target=aws_msk_cluster.msk_cluster -target=aws_msk_configuration.cluster_configuration -target=aws_cloudwatch_log_group.msk_log_group -auto-approve'
                        }
                        
                        echo "MSK Cluster destroyed successfully!"
                    }
                }
            }
        }
        
        stage('Destroy IAM Resources') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    dir('terraform/msk') {
                        echo "============================================"
                        echo "Destroying IAM Resources"
                        echo "============================================"
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform destroy -target=aws_iam_role_policy_attachment.attach_msk_policy -target=aws_iam_policy.msk_policy -target=aws_iam_role.msk_role -auto-approve'
                        } else {
                            input message: 'Approve IAM Resources destruction?', ok: 'Destroy'
                            sh 'terraform destroy -target=aws_iam_role_policy_attachment.attach_msk_policy -target=aws_iam_policy.msk_policy -target=aws_iam_role.msk_role -auto-approve'
                        }
                        
                        echo "IAM Resources destroyed successfully!"
                    }
                }
            }
        }
        
        stage('Destroy RDS') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    dir('terraform/rds') {
                        echo "============================================"
                        echo "Destroying RDS Database"
                        echo "============================================"
                        
                        sh 'terraform init'
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform destroy -auto-approve'
                        } else {
                            input message: 'Approve RDS destruction?', ok: 'Destroy'
                            sh 'terraform destroy -auto-approve'
                        }
                        
                        echo "RDS Database destroyed successfully!"
                    }
                }
            }
        }
        
        stage('Destroy Security Groups') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    dir('terraform/sg') {
                        echo "============================================"
                        echo "Destroying Security Groups"
                        echo "============================================"
                        
                        sh 'terraform init'
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform destroy -auto-approve'
                        } else {
                            input message: 'Approve Security Groups destruction?', ok: 'Destroy'
                            sh 'terraform destroy -auto-approve'
                        }
                        
                        echo "Security Groups destroyed successfully!"
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "============================================"
            echo "Pipeline completed successfully!"
            echo "Action performed: ${params.ACTION}"
            echo "============================================"
        }
        failure {
            echo "============================================"
            echo "Pipeline failed!"
            echo "Please check the logs for errors."
            echo "============================================"
        }
        always {
            cleanWs()
        }
    }
}

