
resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Private subnets for Order Saga PostgreSQL"
  subnet_ids  = [for subnet in aws_subnet.main : subnet.id if startswith(subnet.tags["Tier"], "database") || subnet.tags["Tier"] == "db"]

  tags = {
    Name    = "${var.project_name}-db-subnet-group"
    Project = var.project_name
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = "arn:aws:kms:us-east-1:824225573600:key/3c33b2e9-1feb-411c-8216-8f14506cf828"

  db_name  = "order_db"
  username = "appadmin"

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  multi_az                   = false
  backup_retention_period    = 1
  auto_minor_version_upgrade = true
  apply_immediately          = true

  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project_name}-final-snapshot"

  tags = {
    Name    = "${var.project_name}-postgres"
    Project = var.project_name
  }
}

