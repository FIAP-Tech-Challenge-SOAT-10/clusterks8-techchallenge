# Verifica se a VPC com a tag Name = "eks-vpc" já existe
# Se existir, usaremos ela. Caso contrário, criaremos uma nova.
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["eks-vpc"]
  }
  count = 1
}

# Cria nova VPC apenas se não existir uma com a tag "eks-vpc"
resource "aws_vpc" "eks" {
  count                = data.aws_vpc.existing[0].id != "" ? 0 : 1
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "eks-vpc"
  }
}

# Define o ID da VPC a ser usada (existente ou nova)
locals {
  vpc_id = data.aws_vpc.existing[0].id != "" ? data.aws_vpc.existing[0].id : aws_vpc.eks[0].id
}

data "aws_availability_zones" "available" {}

# Subnets públicas
resource "aws_subnet" "eks_public" {
  count                   = 2
  vpc_id                  = local.vpc_id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "eks-public-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "eks" {
  vpc_id = local.vpc_id
}

# Route Table
resource "aws_route_table" "eks_public" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks.id
  }
}

# Association entre subnets e a route table
resource "aws_route_table_association" "public_subnets" {
  count          = length(aws_subnet.eks_public)
  subnet_id      = aws_subnet.eks_public[count.index].id
  route_table_id = aws_route_table.eks_public.id
}

# IAM Role do Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Cluster EKS
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_public[*].id
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy]
}

# IAM Role do Node Group
resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.cluster_name}-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "node_group_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = each.value
}

# Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = aws_subnet.eks_public[*].id

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_capacity
    min_size     = var.min_capacity
  }

  instance_types = [var.node_instance_type]

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.node_group_policies
  ]
}
