terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.60"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ceph_vpc.id

  tags = {
    Name = "main"
  }
}

# VPC
resource "aws_vpc" "ceph_vpc" {
  cidr_block = "10.10.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# Subnet A
resource "aws_subnet" "subneta" {
  vpc_id                  = aws_vpc.ceph_vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "${var.availability_zonea}"

  tags = {
    Name = "subnet-a"
  }
}

# Subnet B
resource "aws_subnet" "subnetb" {
  vpc_id                  = aws_vpc.ceph_vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "${var.availability_zoneb}"

  tags = {
    Name = "subnet-b"
  }
}

# Subnet C
resource "aws_subnet" "subnetc" {
  vpc_id                  = aws_vpc.ceph_vpc.id
  cidr_block              = "10.10.3.0/24"
  availability_zone       = "${var.availability_zonec}"

  tags = {
    Name = "subnet-c"
  }
}

resource "aws_instance" "cepha1" {
  ami = "${var.ami_id}"
  availability_zone = "${var.availability_zonea}"
  instance_type = "${var.instance_type}"
  key_name = "terraform_ec2_key"
  subnet_id = aws_subnet.subneta.id
  tags = {
    Name = "cepha1"
  }
}

#resource "aws_instance" "cepha2" {
#  ami = "${var.ami_id}"
#  availability_zone = "${var.availability_zonea}"
#  instance_type = "${var.instance_type}"
#  key_name = "terraform_ec2_key"
#  subnet_id = aws_subnet.subneta.id
#  tags = {
#    Name = "cepha2"
#  }
#}

resource "aws_instance" "cephb1" {
  ami = "${var.ami_id}"
  availability_zone = "${var.availability_zoneb}"
  instance_type = "${var.instance_type}"
  key_name = "terraform_ec2_key"
  subnet_id = aws_subnet.subnetb.id
  tags = {
    Name = "cephb1"
  }
}

#resource "aws_instance" "cephb2" {
#  ami = "${var.ami_id}"
#  availability_zone = "${var.availability_zoneb}"
#  instance_type = "${var.instance_type}"
#  key_name = "terraform_ec2_key"
#  subnet_id = aws_subnet.subnetb.id
#  tags = {
#    Name = "cephb2"
#  }
#}

resource "aws_instance" "cephc1" {
  ami = "${var.ami_id}"
  availability_zone = "${var.availability_zonec}"
  instance_type = "${var.instance_type}"
  key_name = "terraform_ec2_key"
  subnet_id = aws_subnet.subnetc.id
  tags = {
    Name = "cephc1"
  }
}

resource "aws_key_pair" "terraform_ec2_key" {
  key_name = "terraform_ec2_key"
  public_key = "${file("${var.public_key_path}")}"
}

resource "aws_ebs_volume" "cepha1-vol" {
  availability_zone = "${var.availability_zonea}"
  size = 100
  tags = {
        Name = "cepha1-volume"
 }
}

resource "aws_volume_attachment" "cepha1-vol" {
  device_name = "/dev/sdc"
  volume_id = "${aws_ebs_volume.cepha1-vol.id}"
  instance_id = "${aws_instance.cepha1.id}"
}

resource "aws_ebs_volume" "cephc1-vol" {
  availability_zone = "${var.availability_zonec}"
  size = 100
  tags = {
        Name = "cephc1-volume"
 }
}

resource "aws_volume_attachment" "cephc1-vol" {
  device_name = "/dev/sdc"
  volume_id = "${aws_ebs_volume.cephc1-vol.id}"
  instance_id = "${aws_instance.cephc1.id}"
}


#resource "aws_ebs_volume" "cepha2-vol" {
#  availability_zone = "${var.availability_zonea}"
#  size = 100
#  tags = {
#        Name = "cepha2-volume"
# }
#
#}
#
#resource "aws_volume_attachment" "cepha2-vol" {
#  device_name = "/dev/sdc"
#  volume_id = "${aws_ebs_volume.cepha2-vol.id}"
#  instance_id = "${aws_instance.cepha2.id}"
#}

resource "aws_ebs_volume" "cephb1-vol" {
  availability_zone = "${var.availability_zoneb}"
  size = 100
  tags = {
        Name = "cephb1-volume"
 }
}

resource "aws_volume_attachment" "cephb1-vol" {
  device_name = "/dev/sdc"
  volume_id = "${aws_ebs_volume.cephb1-vol.id}"
  instance_id = "${aws_instance.cephb1.id}"
}



#resource "aws_ebs_volume" "cephb2-vol" {
#  availability_zone = "${var.availability_zoneb}"
#  size = 100
#  tags = {
#        Name = "cephb2-volume"
# }
#}
#
#resource "aws_volume_attachment" "cephb2-vol" {
#  device_name = "/dev/sdc"
#  volume_id = "${aws_ebs_volume.cephb2-vol.id}"
#  instance_id = "${aws_instance.cephb2.id}"
#}

resource "aws_eip" "publica1" {
  instance = aws_instance.cepha1.id
}
#resource "aws_eip" "publica2" {
#  instance = aws_instance.cepha2.id
#}
resource "aws_eip" "publicb1" {
  instance = aws_instance.cephb1.id
}
#resource "aws_eip" "publicb2" {
#  instance = aws_instance.cephb2.id
#}
resource "aws_eip" "publicc1" {
  instance = aws_instance.cephc1.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.ceph_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "my_route_table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subneta.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnetb.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.subnetc.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.ceph_vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  ingress{
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH traffic from any IP address (consider restricting this to a specific IP range for security)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
