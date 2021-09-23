terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
    region = "us-west-2"
    access_key = "AKIA3ZC7ID2V5QZ67SN4"
    secret_key = "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"
}

#variable "subnetprefix" {
 #   description = "cidr block for subnet"
    
  
#}
#create a VPC

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "production"
  }
}
#create internet GW

resource "aws_internet_gateway" "my-gw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "prod-gateway"
  }
}

#create subnet 

resource "aws_subnet" "my-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "prod subnet-1"
  }
}


#create a route table 

resource "aws_route_table" "my-route" {
  vpc_id = aws_vpc.my-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.my-gw.id
    }
    route {
      ipv6_cidr_block        = "::/0"
      gateway_id = aws_internet_gateway.my-gw.id
    }

  tags = {
    Name = "prod-route"
  }
}

#Assosiation of subnet to route table 

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-route.id
}

#create security group allows 80,8080,22

resource "aws_security_group" "sg1" {
  name        = "sg1"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
      description      = "https"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
      description      = "http"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
     ingress {
      description      = "ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  tags = {
    Name = "allow_web"
  }
}
#Create network interface and assign the IP from subnet

resource "aws_network_interface" "my-nic" {
  subnet_id       = aws_subnet.my-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.sg1.id]
}

#Assign an EIP

resource "aws_eip" "my-eip" {
  network_interface = aws_network_interface.my-nic.id
  associate_with_private_ip = "10.0.1.50"
  vpc      = true
  depends_on = [aws_internet_gateway.my-gw]
  tags = {
    "Name" = "Prod-eip"
  }
}
output "Public_IP" {
    value = aws_eip.my-eip.public_ip
}
#Create ubuntu server and apache2

resource "aws_instance" "my-ec2" {
    ami = "ami-03d5c68bab01f3496" 
    instance_type = "t2.micro"
    availability_zone = "us-west-2a"
    key_name = "my-key"

    network_interface {

        device_index = 0
        network_interface_id  = aws_network_interface.my-nic.id 
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo This is my first website with terraform > /var/www/html/index.html'
                EOF
    tags = {

        Name = "my EC2"
    }            
  
}
output "Server_IP" {
    value = aws_instance.my-ec2.private_ip
  
}
#terraform {
  #backend "s3" {
   # bucket = "my-backend-tf"
    #key    = "terraform.tfstate"
    #region = "us-west-2"
    #access_key = "AKIA3ZC7ID2V5QZ67SN4"
    #secret_key = "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"
  #}
#}
