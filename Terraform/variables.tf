variable "ami_name_filter" {
  description = "Filter to use to find the AMI by name"
  default     = "takehome-application-windows-image"
}

variable "ami_owner" {
  description = "Filter for the AMI owner"
  default     = "self"
}

variable "instance_type" {
  description = "Type of EC2 instance"
  default     = "t2.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances to deploy"
  default     = 1
}

variable "allow_rdp_from_cidrs" {
  description = "List of CIDRs allowed to connect to RDP"
  default     = ["0.0.0.0/0"]
}
