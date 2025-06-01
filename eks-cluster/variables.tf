variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "eks-lanchonete"
}

variable "node_instance_type" {
  default = "t3.micro"
}

variable "desired_capacity" {
  default = 1
}

variable "max_capacity" {
  default = 1
}

variable "min_capacity" {
  default = 1
}
