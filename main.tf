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
#creating security groups to allow my teams IP's
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-0eeda1b52f1b8b78a"
  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["71.202.208.227", "76.210.139.68"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  egress {
    from_port        = 22
    to_port          = 22
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "allow_ssh"
  }
}