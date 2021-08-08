variable "instance_ami"{
    default="ami-0d26eb3972b7f8c96"
}

variable "instance_type"{
    type = string
    default="t2.micro"
}

variable "instance_keyname"{
    default="deployer-key"
}

variable "nat_instance_ami"{
    default="ami-00fe444797752bd96"
}
