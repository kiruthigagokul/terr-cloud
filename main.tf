resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "pub_subnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "public-subnettt"
  }
}

resource "aws_subnet" "pvt_subnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnettt"
  }
}



resource "aws_route_table" "pub_route" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route"
  }
}

resource "aws_route_table_association" "pub_route_ass" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.pub_route.id
}
resource "aws_route_table" "pvt_route" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "private-route"
  }
}
resource "aws_route_table_association" "prt_route_ass" {
  subnet_id      = aws_subnet.pvt_subnet.id
  route_table_id = aws_route_table.pvt_route.id
}




resource "aws_security_group" "pub_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id   # Replace with your VPC resource

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pub-sg"
  }
}


resource "aws_security_group" "pvt_sg" {
  name        = "private-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id   # Replace with your VPC resource

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pvt-sg"
  }
}

resource "aws_instance" "public_ec2" {
  ami           = "ami-087d1c9a513324697"   # Amazon Linux 2023 (ap-south-1)
  instance_type = "t2.small"

  subnet_id = aws_subnet.pub_subnet.id   # Put EC2 in public subnet

  vpc_security_group_ids = [
    aws_security_group.pub_sg.id
  ]

  associate_public_ip_address = true   # Required for internet access

                 # Replace with your EC2 keypair name

  tags = {
    Name = "public-kiru"
  }
}


resource "aws_instance" "private_ec2" {
  ami           = "ami-087d1c9a513324697"   # Amazon Linux 2023 (ap-south-1)
  instance_type = "t2.small"

  subnet_id = aws_subnet.pvt_subnet.id   # Put EC2 in public subnet

  vpc_security_group_ids = [
    aws_security_group.pvt_sg.id
  ]

  associate_public_ip_address = true   # Required for internet access

                 # Replace with your EC2 keypair name

  tags = {
    Name = "private-kiru"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}

resource "aws_eip" "myeip" {
  domain   = "vpc"
}




resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.pub_subnet.id   # NAT must be in PUBLIC subnet

  tags = {
    Name = "nat-gateway"
  }
}