
resource "aws_security_group" "allow_ssh_from_bastion_sg" {
  name        = "allow_ssh_from_bastion_sg"
  description = "allow ssh from bastion host private ip"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    {
      description = "SSH from bastion private IP"
      from_port = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${data.aws_instance.bastion.private_ip}/32"]
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      security_groups = null
      self = null
    }
  ]
  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = null
      security_groups = null
      self = null
      description = "egress everything"
    }
  ]

  tags = {
    Name = "allow_ssh_from_bastion_sg"
  }
}

// create a bastion host
resource "aws_instance" "private_insatnce" {
  ami           = var.instance_ami
  instance_type = var.instance_type

  associate_public_ip_address = false
  availability_zone           = "eu-west-2a"

  //To be defined, allow SSH from my iP
  vpc_security_group_ids = ["${aws_security_group.allow_ssh_from_bastion_sg.id}"]

  // To be defined
  subnet_id = module.vpc.private_subnets[0]

  //The key pair must be created first  from AWS console
  // Or cerate a profiler command job to create a ssh key and add the public key ( base 64 encoded value)
  // to the aws_key_pair resource
  key_name = var.instance_keyname

  tags = {
    Name = "private_insatnce"
  }
}