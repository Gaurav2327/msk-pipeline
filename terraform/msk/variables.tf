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

variable "plugin_bucket" {
  default = "aws-msk-resources-bucket"
  description = "S3 bucket for MSK connector plugins"
  type = string
}

## Variables for MSK Connector

variable "kafkaconnect_version" {
  default = "3.7.x"
  description = "Kafka Connect version for the MSK Connector"
  type = string  
}

variable "mcu_count" {
  default = "2"
  description = "Number of MCUs for the MSK Connector"
  type = number
}

variable "worker_count" {
  default = "1"
  description = "Number of workers for the MSK Connector"
  type = number
}

variable "client_authentication_type" {
  default = "NONE"
  description = "Client authentication type for the MSK Connector"
  type = string
}

variable "encryption_type" {
  default = "PLAINTEXT"
  description = "Encryption type for the MSK Connector"
  type = string
}