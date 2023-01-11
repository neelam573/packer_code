variable "subnet_id" {
  type    = string
  default = "subnet-00769ef2cfac06631"
}
variable "ami_name" {
  type    = string
  default = "golden_initial_ami"
}
variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "vpc_id" {
  type    = string
  default = "vpc-0ebd4dd0bcca2de34"
}

source "amazon-ebs" "initial_ami" {
  ami_name                    = "${var.ami_name}-{{timestamp}}"
  communicator                = "ssh"
  instance_type               = "t2.large"
  region                      = var.region
  subnet_id                   = var.subnet_id
  vpc_id                      = var.vpc_id
  tags = {
    Name = "Sohan"
    OS   = "Packer"
    env  = "Packer_Builder"
  }
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.initial_ami"
  ]
    provisioner "shell" {
     pause_after = "10s"
    inline = [
        "sudo systemctl daemon-reload",
        "sudo systemctl restart node.service",
        "sudo systemctl status node.service",
        "sudo pm2 list"    
    ]
  }
  post-processor "manifest" {
  output = "manifest.json"
  }
}
