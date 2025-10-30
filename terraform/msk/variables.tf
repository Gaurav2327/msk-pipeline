variable "cluster_name" {
  default = "msk-cluster"
  description = "msk cluster name"
  type = string
}

variable "log_retention_in_days" {
  default = 14
  description = "Number of days to retain CloudWatch logs"
  type = number
}

variable "kafka_version" {
  default = "3.8.x"
  description = "Kafka version for the MSK cluster"
  type = string
}

variable "number_of_broker_nodes" {
  default = 3
  description = "Number of broker nodes in the MSK cluster"
  type = number
}

variable "broker_instance_type" {
  default = "kafka.t3.small"
  description = "Instance type for the broker nodes"
  type = string
}

variable "log_bucket" {
  default = "aws-msk-resources-bucket"
  description = "S3 bucket for MSK logs"
  type = string
}

variable "ebs_volume_size" {
  default = "10"
  description = "EBS volume size in GB for each broker node"
  type = number
}