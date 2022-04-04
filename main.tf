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

resource "aws_security_group" "sg_ssh" {
  name        = "sg_ssh"
  description = "Allow SSH access"
  vpc_id      = "vpc-dcd765a7"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["201.68.58.93/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sp_ssh"
  }
}

resource "aws_security_group" "sg_app" {
  name        = "sp_app"
  description = "Allow access in app"
  vpc_id      = "vpc-dcd765a7"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["201.68.58.93/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sp_app"
  }
}

resource "aws_security_group" "sg_db" {
  name        = "sp_db"
  description = "Allow access in db"
  vpc_id      = "vpc-dcd765a7"

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups = ["${aws_security_group.sg_app.id}"]
  }  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sp_db"
  }
}

resource "aws_instance" "wordpress" {
    ami = "ami-0c02fb55956c7d316"
    instance_type = "t2.micro"
    subnet_id = "subnet-0eedc321"
    key_name = "admin-teste"
    vpc_security_group_ids = [ "${aws_security_group.sg_ssh.id}", "${aws_security_group.sg_app.id}"  ]
    tags = {
      "Name" = "wordpress"
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

resource "aws_instance" "db" {
    ami = "ami-0c02fb55956c7d316"
    instance_type = "t2.micro"
    subnet_id = "subnet-0eedc321"
    key_name = "admin-teste"
    vpc_security_group_ids = [ "${aws_security_group.sg_ssh.id}", "${aws_security_group.sg_db.id}" ]
    tags = {
      "Name" = "db"
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

