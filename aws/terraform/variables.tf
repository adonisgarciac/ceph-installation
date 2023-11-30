variable "access_key" {
        description = "Access key to AWS console"
}
variable "secret_key" {
        description = "Secret key to AWS console"
}

variable "instance_name" {
        description = "Name of the instance to be created"
        default = "awsbuilder-demo"
}

variable "instance_type" {
        default = "t3.large"
}

variable "availability_zonea" {
        default = "eu-central-1a"
}

variable "availability_zoneb" {
        default = "eu-central-1b"
}

variable "availability_zonec" {
        default = "eu-central-1c"
}

variable "ami_id" {
        description = "The AMI to use"
        default = "ami-0a3ca859119c1ee3c"
}

variable "ami_key_pair_name" {
        default = "ceph"
}

variable "region" {
        default = "eu-central-1"
}

variable "public_key_path" {
        default = "/home/agarciac/.ssh/id_rsa_aws_terraform.pub"
}
