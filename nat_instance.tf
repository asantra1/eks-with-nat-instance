// Create SG for VPC
resource "aws_security_group" "allow_all_from_nat_sg" {
  name        = "allow_all_from_nat_sg"
  description = "allow all connections from nat"
  vpc_id      = module.vpc.vpc_id
  ingress = [
    {
      description = "all connection from private net"
      from_port = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
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
    Name = "nat_sg"
  }
}

// create a bastion host
resource "aws_instance" "nat" {
  ami           = var.nat_instance_ami
  instance_type = var.instance_type

  // create one NAt per subnet
  count = length(module.vpc.private_subnets)

  associate_public_ip_address = true
  source_dest_check = false

  //To be defined security id
  vpc_security_group_ids = ["${aws_security_group.allow_all_from_nat_sg.id}"]
  // To be defined
  subnet_id = module.vpc.public_subnets[count.index]

  //The key pair must be created first  from AWS console
  // Or cerate a profiler command job to create a ssh key and add the public key ( base 64 encoded value)
  // to the aws_key_pair resource
  key_name = var.instance_keyname

  tags = {
    Name = "nat"
  }
}

// Add rules for the private subnet
resource "aws_route" "route_outbound_nat" {
  count = length(module.vpc.private_route_table_ids)

  route_table_id              = "${module.vpc.private_route_table_ids[count.index]}"
  destination_cidr_block = "0.0.0.0/0"
  instance_id       = aws_instance.nat.*.id[count.index % length(aws_instance.nat.*.id)]
}
