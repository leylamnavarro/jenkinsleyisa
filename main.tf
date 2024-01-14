resource "aws_key_pair" "autodeploy" {
  #key_name   = "autodeploy"  # Set a unique name for your key pair
  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
}

resource "aws_instance" "public_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = aws_key_pair.autodeploy.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = var.name_tag,
  }
  
  #key_name = aws_key_pair.autodeploy.key_name  # Link the key pair to the instance
}
#creating a security group with terraform code that allows ssh access to only the members of my teams public IP’s
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = "vpc-0eeda1b52f1b8b78a"

  ingress {
    description      = "Ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["96.90.192.54/32", "76.210.139.68/32"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  tags = {
    Name = "allow_ssh"
  }
}
#adding an additional volume to my instance with terraform
#create the EBS volume
resource "aws_ebs_volume" "add_disk" {
  availability_zone = aws_instance.public_instance.availability_zone
  size              = 10
  tags = {
    Name = "My Volume"
  }
}
#adding additional EBS volume to EC2 instance using terraform
resource "aws_volume_attachment" "ebs" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.add_disk.id
  instance_id = aws_instance.public_instance.id
}