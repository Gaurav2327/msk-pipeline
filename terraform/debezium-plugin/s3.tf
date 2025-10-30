resource "aws_s3_bucket" "msk_resources" {
  bucket = var.bucket_name
  tags   = merge(local.default_tags)
}

resource "aws_s3_bucket_versioning" "msk_resources" {
  bucket = aws_s3_bucket.msk_resources.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "null_resource" "download_and_process" {
  provisioner "local-exec" {
    command = <<EOT
      sudo apt-get update
      sudo apt-get install -y zip unzip
      mkdir -p /tmp/extracted_files
      curl -L https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/2.7.4.Final/debezium-connector-mysql-2.7.4.Final-plugin.tar.gz -o /tmp/extracted_files/debezium-connector-mysql-2.7.4.Final-plugin.tar.gz
      curl -L https://d2p6pa21dvn84.cloudfront.net/api/plugins/jcustenborder/kafka-config-provider-aws/versions/0.1.2/jcustenborder-kafka-config-provider-aws-0.1.2.zip -o /tmp/extracted_files/jcustenborder-kafka-config-provider-aws-0.1.2.zip

      tar -xzf /tmp/extracted_files/debezium-connector-mysql-2.7.4.Final-plugin.tar.gz -C /tmp/extracted_files
      unzip /tmp/extracted_files/jcustenborder-kafka-config-provider-aws-0.1.2.zip -d /tmp/extracted_files
      rm /tmp/extracted_files/debezium-connector-mysql-2.7.4.Final-plugin.tar.gz
      rm /tmp/extracted_files/jcustenborder-kafka-config-provider-aws-0.1.2.zip
      cd /tmp/extracted_files
      zip -r /tmp/extracted_files/debezium-mysql-plugin.zip .
      ls /tmp/extracted_files/debezium-mysql-plugin.zip
    EOT
  }
}

resource "aws_s3_object" "upload_zipped_files" {
  bucket     = var.bucket_name
  key        = "plugins/debezium-mysql-plugin.zip"
  source     = "/tmp/extracted_files/debezium-mysql-plugin.zip"
  acl        = "private"
  depends_on = [null_resource.download_and_process]
}