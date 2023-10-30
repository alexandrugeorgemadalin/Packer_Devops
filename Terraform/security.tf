resource "aws_security_group" "sg" {
  ingress {
    cidr_blocks = var.allow_rdp_from_cidrs
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}