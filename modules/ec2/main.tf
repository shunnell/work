# Create an EC2 Instance
resource "aws_instance" "this" {
  ami                  = var.ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  subnet_id            = var.subnet_id            # Associate the instance with the subnet
  monitoring           = var.monitoring           # Enable detailed monitoring
  iam_instance_profile = var.ec2_instance_profile # Attach IAM Role to the EC2 instance

  tags = merge(
    var.tags,
    {
      Name = var.instance_name # Assuming you have a variable for instance name
    }
  )
}