resource "aws_iam_role" "msk_role" {
  name               = "${var.cluster_name}-msk-connector-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "assumeRoleStatement"
        Effect = "Allow"
        Principal = {
          Service = "kafkaconnect.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for MSK Connector
resource "aws_iam_policy" "msk_policy" {
  name        = "${var.cluster_name}-msk-connector-policy"
  description = "Policy for MSK Connector"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "kafka-cluster:Connect",
          "kafka-cluster:AlterCluster",
          "kafka-cluster:DescribeCluster"
        ]
        Resource = [
          "arn:aws:kafka:us-east-1:*:cluster/*/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "kafka-cluster:*Topic*",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData"
        ]
        Resource = [
          "arn:aws:kafka:us-east-1:*:topic/*/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ]
        Resource = [
          "arn:aws:kafka:us-east-1:*:group/*/*"
        ]
      },
      {
        Sid      = "logsPolicy"
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "*"
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:us-east-1:*:*:*"
          }
        }
      },
      {
        Sid      = "kafkaConnectPermissions"
        Effect   = "Allow"
        Action   = [
          "logs:DescribeLogGroups",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "s3:GetBucketPolicy",
          "logs:GetLogDelivery",
          "ec2:DescribeSecurityGroups",
          "logs:ListLogDeliveries",
          "ec2:CreateNetworkInterface",
          "logs:CreateLogDelivery",
          "kafkaconnect:*",
          "s3:GetObject",
          "logs:PutResourcePolicy",
          "iam:PassRole",
          "ec2:DescribeVpcs",
          "s3:PutBucketPolicy",
          "firehose:TagDeliveryStream",
          "logs:DeleteLogDelivery",
          "ec2:DescribeSubnets",
          "logs:DescribeResourcePolicies"
        ]
        Resource = "*"
      },
      {
        Sid      = "predefinedServiceLinkedRoles"
        Effect   = "Allow"
        Action   = "iam:CreateServiceLinkedRole"
        Resource = "*"
        Condition = {
          StringLike = {
            "iam:AWSServiceName" = "kafkaconnect.amazonaws.com"
          }
        }
      },
      {
        Sid      = "predefinedLogDeliveryServiceLinkedRoles"
        Effect   = "Allow"
        Action   = "iam:CreateServiceLinkedRole"
        Resource = "*"
        Condition = {
          StringLike = {
            "iam:AWSServiceName" = "delivery.logs.amazonaws.com"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = [
          "kafka:*",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeVpcAttribute",
          "kms:DescribeKey",
          "kms:CreateGrant",
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups",
          "S3:GetBucketPolicy",
          "firehose:TagDeliveryStream"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ec2:CreateVpcEndpoint"
        ]
        Resource = [
          "arn:*:ec2:*:*:vpc/*",
          "arn:*:ec2:*:*:subnet/*",
          "arn:*:ec2:*:*:security-group/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "ec2:CreateVpcEndpoint"
        ]
        Resource = [
          "arn:*:ec2:*:*:vpc-endpoint/*"
        ]
        Condition = {
          StringEquals = {
            "aws:RequestTag/AWSMSKManaged" = "true"
          }
          StringLike = {
            "aws:RequestTag/ClusterArn" = "*"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = [
          "ec2:CreateTags"
        ]
        Resource = "arn:*:ec2:*:*:vpc-endpoint/*"
        Condition = {
          StringEquals = {
            "ec2:CreateAction" = "CreateVpcEndpoint"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = [
          "ec2:DeleteVpcEndpoints"
        ]
        Resource = "arn:*:ec2:*:*:vpc-endpoint/*"
        Condition = {
          StringEquals = {
            "ec2:ResourceTag/AWSMSKManaged" = "true"
          }
          StringLike = {
            "ec2:ResourceTag/ClusterArn" = "*"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "kafka.amazonaws.com"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = "iam:CreateServiceLinkedRole"
        Resource = "arn:aws:iam::*:role/aws-service-role/kafka.amazonaws.com/AWSServiceRoleForKafka*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "kafka.amazonaws.com"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = "iam:CreateServiceLinkedRole"
        Resource = "arn:aws:iam::*:role/aws-service-role/delivery.logs.amazonaws.com/AWSServiceRoleForLogDelivery*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "delivery.logs.amazonaws.com"
          }
        }
      },
      {
        Sid      = "rdsConnectPermission"
        Effect   = "Allow"
        Action   = "rds-db:connect"
        Resource = "*"
      },
      {
        Sid      = "secretsManagerPermission"
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:us-east-1:*:secret:rds!cluster-*"
      }
    ]
  })
}
############# attach policy and role ###########
resource "aws_iam_role_policy_attachment" "attach_msk_policy" {
  policy_arn = aws_iam_policy.msk_policy.arn
  role       = aws_iam_role.msk_role.name
}