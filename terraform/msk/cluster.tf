resource "aws_cloudwatch_log_group" "msk_log_group" {
  name              = "/aws/msk/${var.cluster_name}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_msk_configuration" "cluster_configuration" {
  name          = "${var.cluster_name}-configuration"
  kafka_versions = [var.kafka_version]
  description   = "MSK cluster configuration"
  server_properties = <<EOF
auto.create.topics.enable=true
delete.topic.enable=true
log.retention.hours=168
min.insync.replicas=2
num.partitions=1
num.replica.fetchers=2
num.io.threads=8
num.network.threads=5
num.replica.fetchers=2
replica.lag.time.max.ms=30000
socket.receive.buffer.bytes=102400
socket.send.buffer.bytes=102400
unclean.leader.election.enable=false
zookeeper.session.timeout.ms=18000
EOF
}

resource "aws_msk_cluster" "msk_cluster" {
  cluster_name           = var.cluster_name
  kafka_version         = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  
  broker_node_group_info {
    instance_type   = var.broker_instance_type
    client_subnets  = [data.aws_subnets.public_subnets.ids[0], data.aws_subnets.public_subnets.ids[1], data.aws_subnets.public_subnets.ids[3]]
    security_groups = [data.aws_security_group.msk_sg.id]

    storage_info {
    ebs_storage_info {
      volume_size = var.ebs_volume_size
    }
  }
}
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled         = true
        log_group       = aws_cloudwatch_log_group.msk_log_group.name
      }
      s3 {
        enabled = true
        bucket = var.log_bucket
        prefix = "logs/"
      }
    }
  }
  

  client_authentication {
    unauthenticated = true
    sasl {
      iam = true
      scram = false
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
      in_cluster = true
    }
  }
  
  

  tags = merge(local.default_tags,{
    Name = var.cluster_name
  })
}