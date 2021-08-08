// Create data 
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_instance" "bastion"{
  instance_id = "${aws_instance.bastion.id}"
}


// create a bastion host
resource "aws_instance" "bastion" {
  ami           = var.instance_ami
  instance_type = var.instance_type

  associate_public_ip_address = true
  availability_zone           = "eu-west-2a"

  //To be defined, allow SSH from my iP
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]

  // To be defined
  subnet_id = module.vpc.public_subnets[0]

  //The key pair must be created first  from AWS console
  // Or cerate a profiler command job to create a ssh key and add the public key ( base 64 encoded value)
  // to the aws_key_pair resource
  key_name = var.instance_keyname

  tags = {
    Name = "bastion"
  }
}

// create secuti group 

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh to bastion host from my ip"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    {
      description = "SSH from my IP"
      from_port = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      security_groups = null
      self = null
    }
  ]
  egress = [
    {
      description = "egress from bastion"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = module.vpc.private_subnets_cidr_blocks
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      security_groups = null
      self = null
    }
  ]

  tags = {
    Name = "allow_ssh"
  }
}
