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
        // AWS credentials from Jenkins credential store
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "============================================"
                echo "Repository checked out successfully"
                echo "============================================"
            }
        }
        
        stage('Verify AWS Access') {
            steps {
                script {
                    echo "============================================"
                    echo "Verifying AWS credentials..."
                    echo "============================================"
                    try {
                        sh '''
                            aws sts get-caller-identity
                            echo "✓ AWS credentials are configured correctly"
                        '''
                    } catch (Exception e) {
                        error """
                         AWS credentials not found or invalid!
                        
                        Please configure AWS credentials using one of these methods:
                        1. Run 'aws configure' on the Jenkins machine
                        2. Set up Jenkins credentials (see AWS_CREDENTIALS_SETUP.md)
                        3. Configure environment variables in Jenkins
                        
                        For detailed instructions, see: AWS_CREDENTIALS_SETUP.md
                        """
                    }
                }
            }
        }
        
        stage('Validate Terraform') {
            steps {
                sh '''
                    echo "============================================"
                    echo "Checking Terraform version..."
                    echo "============================================"
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
                        echo " Step 1/4: Creating Security Groups"
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
                        
                        echo " Security Groups created successfully!"
                    }
                }
            }
        }
        
        stage('Create RDS Database') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    dir('terraform/rds') {
                        echo "============================================"
                        echo "🗄️  Step 2/4: Creating RDS Database"
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
                        echo "Step 3/4: Creating MSK Cluster"
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
                        echo "🔌 Step 4/4: Creating MSK Connector"
                        echo "============================================"
                        
                        sh 'terraform plan -target=aws_mskconnect_custom_plugin.connector_plugin_debezium -target=aws_mskconnect_worker_configuration.connector_configuration -target=aws_mskconnect_connector.msk_cdc_connector -out=tfplan-connector'
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform apply -auto-approve tfplan-connector'
                        } else {
                            input message: 'Approve MSK Connector creation?', ok: 'Apply'
                            sh 'terraform apply tfplan-connector'
                        }
                        
                        echo " MSK Connector created successfully!"
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
                        echo " Step 1/5: Destroying MSK Connector"
                        echo "============================================"
                        
                        sh 'terraform init'
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform destroy -target=aws_mskconnect_connector.msk_cdc_connector -target=aws_mskconnect_worker_configuration.connector_configuration -target=aws_mskconnect_custom_plugin.connector_plugin_debezium -auto-approve'
                        } else {
                            input message: 'Approve MSK Connector destruction?', ok: 'Destroy'
                            sh 'terraform destroy -target=aws_mskconnect_connector.msk_cdc_connector -target=aws_mskconnect_worker_configuration.connector_configuration -target=aws_mskconnect_custom_plugin.connector_plugin_debezium -auto-approve'
                        }
                        
                        echo " MSK Connector destroyed successfully!"
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
                        echo "  Step 2/5: Destroying MSK Cluster"
                        echo "============================================"
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform destroy -target=aws_msk_cluster.msk_cluster -target=aws_msk_configuration.cluster_configuration -target=aws_cloudwatch_log_group.msk_log_group -auto-approve'
                        } else {
                            input message: 'Approve MSK Cluster destruction?', ok: 'Destroy'
                            sh 'terraform destroy -target=aws_msk_cluster.msk_cluster -target=aws_msk_configuration.cluster_configuration -target=aws_cloudwatch_log_group.msk_log_group -auto-approve'
                        }
                        
                        echo " MSK Cluster destroyed successfully!"
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
                        echo " Step 3/5: Destroying IAM Resources"
                        echo "============================================"
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform destroy -target=aws_iam_role_policy_attachment.attach_msk_policy -target=aws_iam_policy.msk_policy -target=aws_iam_role.msk_role -auto-approve'
                        } else {
                            input message: 'Approve IAM Resources destruction?', ok: 'Destroy'
                            sh 'terraform destroy -target=aws_iam_role_policy_attachment.attach_msk_policy -target=aws_iam_policy.msk_policy -target=aws_iam_role.msk_role -auto-approve'
                        }
                        
                        echo " IAM Resources destroyed successfully!"
                    }
                }
            }
        }
        
        stage('Destroy RDS Database') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    dir('terraform/rds') {
                        echo "============================================"
                        echo "  Step 4/5: Destroying RDS Database"
                        echo "============================================"
                        
                        sh 'terraform init'
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform destroy -auto-approve'
                        } else {
                            input message: 'Approve RDS destruction?', ok: 'Destroy'
                            sh 'terraform destroy -auto-approve'
                        }
                        
                        echo " RDS Database destroyed successfully!"
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
                        echo " Step 5/5: Destroying Security Groups"
                        echo "============================================"
                        
                        sh 'terraform init'
                        
                        if (params.AUTO_APPROVE) {
                            sh 'terraform destroy -auto-approve'
                        } else {
                            input message: 'Approve Security Groups destruction?', ok: 'Destroy'
                            sh 'terraform destroy -auto-approve'
                        }
                        
                        echo " Security Groups destroyed successfully!"
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "============================================"
            echo " Pipeline completed successfully!"
            echo "Action performed: ${params.ACTION}"
            echo "Timestamp: ${new Date()}"
            echo "============================================"
            
            script {
                if (params.ACTION == 'apply') {
                    echo """
                     Infrastructure deployed successfully!
                    
                    Next steps:
                    1. Verify resources in AWS Console
                    2. Check CloudWatch logs for MSK cluster
                    3. Test CDC connector is streaming data
                    
                    Estimated cost: ~\$210-285/month
                    Remember to destroy when not in use!
                    """
                } else {
                    echo """
                     Infrastructure destroyed successfully!
                    
                    All resources have been cleaned up.
                    Verify in AWS Console that all resources are gone.
                    """
                }
            }
        }
        failure {
            echo "============================================"
            echo " Pipeline failed!"
            echo "============================================"
            echo """
            Troubleshooting steps:
            1. Check the console output above for error details
            2. Verify AWS credentials are configured
            3. Check Terraform state is not locked
            4. Review AWS_CREDENTIALS_SETUP.md for credential setup
            5. Check if resources already exist or have dependencies
            
            Common issues:
            - AWS credentials not configured
            - Insufficient IAM permissions
            - Terraform state lock
            - Resource dependencies not met
            - Network/VPC configuration issues
            """
        }
        always {
            echo "Cleaning up workspace..."
            cleanWs()
        }
    }
}
