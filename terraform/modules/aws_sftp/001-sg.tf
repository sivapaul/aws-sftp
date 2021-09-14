resource "aws_security_group" "sg_rol_sftp_manage" {
  name        = "sg_rol_sftp_manages"
  description = "SFTP SG for API"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_rol_sftp_manages"
    Role = "API SG sftp end point"
  }
}
