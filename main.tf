terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.27"
        }
    }

    required_version = ">= 0.14.9"
}

provider "aws" {
    profile = "default"
    region = "us-east-1"
}

resource "aws_instance" "wordpress" {
    ami = "ami-0c02fb55956c7d316"
    instance_type = "t2.micro"
    subnet_id = "subnet-0eedc321"
    key_name = "admin-teste"
    vpc_security_group_ids = [ "sg-0cfb9e992c8b0619e" ]
    tags = {
      "name" = "wordpress"
    }
    provisioner "file" {
      source = "authorized_keys"
      destination = "/home/ec2-user/.ssh/authorized_keys"   

      connection {
          type = "ssh"
          host = self.public_ip 
          user = "ec2-user"
          private_key = "${file("/opt/admin-teste.pem")}"
      }
    
    }
}