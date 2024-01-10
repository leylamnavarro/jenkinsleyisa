resource "aws_key_pair" "autodeploy" {
  #key_name   = "autodeploy"  # Set a unique name for your key pair
  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
}

resource "aws_instance" "public_instance" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = var.name_tag,
  }
  
  key_name = aws_key_pair.autodeploy.key_name  # Link the key pair to the instance
}
#creating a security group with terraform code that allows ssh access to only the members of my teams public IP’s
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "configure instance so members can login via ssh"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 22
    to_port          = 22
    protocol         = "-1"
    cidr_blocks      = ["71.202.208.227"], ["76.210.139.68”]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
