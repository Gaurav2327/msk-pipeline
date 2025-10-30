resource "aws_security_group" "rds_security_group" {
  name        = "rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = data.aws_vpc.default_vpc.id

  # RDS allows inbound MySQL traffic from Connector 
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.connector_security_group.id]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [data.aws_security_group.vpc_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  tags = merge(local.default_tags, {
    name = "rds-sg"
  })
}

################################################
##################### MSK ######################
################################################

resource "aws_security_group" "msk_security_group" {
  name        = "msk-sg"
  description = "Security group for MSK cluster"
  vpc_id      = data.aws_vpc.default_vpc.id

  # MSK allows inbound traffic from Connectors
  ingress {
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [aws_security_group.connector_security_group.id]
  }

  ingress {
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [data.aws_security_group.vpc_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  tags = merge(local.default_tags, {
    name = "msk-sg"
  })
}

################################################
################### CONNECTOR ##################
################################################

resource "aws_security_group" "connector_security_group" {
  name        = "connector-sg"
  description = "Security group for MSK Connectors"
  vpc_id      = data.aws_vpc.default_vpc.id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags, {
    name = "connector-sg"
  })

}