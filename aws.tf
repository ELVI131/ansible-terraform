
# Configure the AWS Provider
provider "aws" {
   region     = "us-east-1"
   access_key = "AKIAT3TNWFCWTDRUODUD"
   secret_key = "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"
}

# Provides EC2 key pair
resource "aws_key_pair" "terraformkey" {
  key_name   = "terraform_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8+iCtwBhfXHOGAzmaZspFtdIV8YIUykoEWER63Vi7xZ1V+vgaW4LKejKxqo9f5EKB+RzZDvrk8JzyyMbiiQrTvSCZaCwRlmN1qGRbfTofpW5fwO2LMOaKjsp8nL/KdwjhB29hTck1QSVGuHICZnsx8utL6Y/5tLeNiuSZUICpNZ+ZRs3WsObhe4H0JopRJe1KAEDKkuyeTctNIGZiua6xL6I4GV/9j5KqHMVOZ4+0VyNJCXOLzM06l3QL3Px6VleDgiYGAxqd8VyRO6+1SnfYvjCcbudw5HKoN+r+JfNNeI6n/xf1z3Db97CptbgFBUUDPadr/Vr8iemuL1AbA3zDRpqMvhjUIeQmLhMyK05JehcM7Ed0hV80Scyb6TzMuruLlxcTZ/RMje87wTFByOne8oBeEWMova2ZW4rh1RdvNNR2PWCmKUIol0yZmduHbguRmGppeb8gkwiD4rTddsYKKhWf5evzinDwGg19XGJ/J8cJ0oCORww4XoSeBYelmvZTptKRPv5N6TAnoPCkXXVMreEnS+dCgVYMu9ClWlOkizSJIH1gsUhRCLG9zPGm8EIPZSTttN+tcGvHozAx6sOLiG4SpEUhZXWeImtw2p1OnRqPfvy/yIAC4JDH1z+mWnrhtfa6Lh52S8XTsfE+fJ8w4VgxZsF+gmqmzZSQgGWCNQ=="
}
# Create VPC

resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.0.0.0/16"
}
# Create Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.k8s_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public Subnet"
  }
}
# Create Internet Gateway
resource "aws_internet_gateway" "k8s_gw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "K8S GW"
  }
}
# Create Routing table
resource "aws_route_table" "k8s_route" {
    vpc_id = aws_vpc.k8s_vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.k8s_gw.id
    }
        
        tags = {
            Name = "K8S Route"
        }
}
# Associate Routing table
resource "aws_route_table_association" "k8s_asso" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.k8s_route.id
}
# Create security group
resource "aws_security_group" "allow_ssh_http" {
  name        = "Web_SG"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.k8s_vpc.id
  ingress {
    description      = "Allow All"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = [ "0.0.0.0/0" ]
  }
  ingress {
    description      = "Allow All"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = [ "0.0.0.0/0" ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "K8S SG"
  }
}
# Launch EC2 instnace for Master Node
resource "aws_instance" "k8s" {
  ami                   = "ami-0b0ea68c435eb488d"
  instance_type         = "t2.micro"
  key_name              = aws_key_pair.terraformkey.key_name
  associate_public_ip_address = true
  subnet_id             = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [ aws_security_group.allow_ssh_http.id ] 
  tags = {
    Name = "Master Node"
  }
}
# Launch EC2 instnace for worker1 Node
resource "aws_instance" "worker1" {
  ami                   = "ami-0b0ea68c435eb488d"
  instance_type         = "t2.micro"
  key_name              = aws_key_pair.terraformkey.key_name
  associate_public_ip_address = true
  subnet_id             = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [ aws_security_group.allow_ssh_http.id ] 
  tags = {
    Name = "worker1 Node"
  }
}
# Launch EC2 instnace for worker2 Node
resource "aws_instance" "worker2" {
  ami                   = "ami-0b0ea68c435eb488d"
  instance_type         = "t2.micro"
  key_name              = aws_key_pair.terraformkey.key_name
  associate_public_ip_address = true
  subnet_id             = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [ aws_security_group.allow_ssh_http.id ] 
  tags = {
    Name = "worker2 Node"
  }
}