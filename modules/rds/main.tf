resource "aws_db_instance" "this" {
  # Unique identifier for the DB instance
  identifier = var.db_instance_identifier

  # Storage configuration
  allocated_storage = var.allocated_storage
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  username          = var.username
  password          = var.password
  db_name           = var.db_name

  # Skip final snapshot on deletion
  skip_final_snapshot = true # Set to false to create a final snapshot on deletion
  # skip_final_snapshot = var.skip_final_snapshot

  # VPC security group IDs
  vpc_security_group_ids = var.vpc_security_group_ids

  # New parameters
  backup_retention_period = var.backup_retention_period
  kms_key_id              = var.kms_key_id
  multi_az                = var.multi_az
  storage_encrypted       = var.storage_encrypted

  # Monitoring parameters
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  # Tags for the RDS instance
  tags = var.tags
}

# Optional: Create a DB subnet group only if subnet_ids are provided
resource "aws_db_subnet_group" "this" {
  count = length(var.subnet_ids) > 0 ? 1 : 0 # Create only if subnet_ids is not empty

  name       = var.db_instance_identifier
  subnet_ids = var.subnet_ids

  tags = var.tags
}