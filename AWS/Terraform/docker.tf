provider "aws" {
    region = "ap-south-1"
    access_key = "AKIA5FTZFAE3VDZOQJWK"
    secret_key = "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"
}

resource "aws_vpc" "VPC-1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Key = "Name"
    Name = "Demo"
  }
}


# Subnets
# Public
resource "aws_subnet" "Public" {
  vpc_id = aws_vpc.VPC-1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Key = "Name"
    Name = "Public"
  }
}

resource "aws_subnet" "Public-2" {
  vpc_id = aws_vpc.VPC-1.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Key = "Name"
    Name = "Public-2"
  }
}



# Internet Gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC-1.id
  tags = {
    Key = "Name"
    Name = "gateway"
  }
}


# Route Table
# Public
resource "aws_route_table" "Public" {
  vpc_id = aws_vpc.VPC-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Key = "Name"
    Name = "Public"
  }
}



# Route table Association
# Public
resource "aws_route_table_association" "RT_Aso" {
  route_table_id = aws_route_table.Public.id
  subnet_id = aws_subnet.Public.id
}

resource "aws_route_table_association" "RT_Aso-2" {
  route_table_id = aws_route_table.Public.id
  subnet_id = aws_subnet.Public-2.id
}

resource "aws_security_group" "SW-vpc" {
  name = "web-server"
  description = "allow traffic over the server"
  vpc_id = aws_vpc.VPC-1.id

  ingress {
    description = "http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "all traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "website" {
  ami = "ami-0522ab6e1ddcc7055"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  subnet_id = aws_subnet.Public.id
  key_name = "VPC"
  associate_public_ip_address = true
  security_groups = [aws_security_group.SW-vpc.id]
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update
                sudo apt-get install docker-ce docker-ce-cli containerd.io -y
                sudo docker pull evo0/webserver:latest
                sudo docker run -d -p 300:80 --name webserver evo0/webserver
                sudo apt-get install apache2 -y
                EOF

    tags = {
    Key = "Name"
    Name = "nginx-website"
    }
}

resource "aws_instance" "website-2" {
  ami = "ami-0522ab6e1ddcc7055"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1b"
  subnet_id = aws_subnet.Public-2.id
  key_name = "VPC"
  associate_public_ip_address = true
  security_groups = [aws_security_group.SW-vpc.id]
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update
                sudo apt-get install docker-ce docker-ce-cli containerd.io -y
                sudo docker pull evo0/webserver:latest
                sudo docker run -d -p 300:80 --name webserver evo0/webserver
                sudo apt-get install apache2 -y
                EOF

    tags = {
    Key = "Name"
    Name = "nginx-website-2"
    }
}