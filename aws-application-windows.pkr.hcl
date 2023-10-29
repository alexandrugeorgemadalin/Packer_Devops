packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variables {  
  access_key=""
  secret_key=""
  instance_type=""
  region=""
  winrm_password=""
  winrm_username=""
}

source "amazon-ebs" "takehome-application-windows-image" {
  access_key    = var.access_key
  secret_key    = var.secret_key
  ami_name      = "takehome-application-windows-image"
  communicator  = "winrm"
  instance_type = var.instance_type
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "takehome-base-windows-image"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners = ["self"]
  }
   
  user_data_file  = "./bootstrap_win.txt"
  winrm_password  = var.winrm_password
  winrm_username  = var.winrm_username
}

build {
  name    = "takehome-devops"
  sources = [
    "source.amazon-ebs.takehome-application-windows-image"
  ]
  
  provisioner "file" {
    source      = "./DevopsWebApp.zip"
    destination = "C:\\DevopsWebApp.zip"
  }

  provisioner "powershell" {
    script            = "./install_dotnet_application.ps1"
    elevated_user     = var.winrm_username
    elevated_password = var.winrm_password
  }
}

