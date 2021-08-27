module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "nginx-app"
  cidr = "10.0.0.0/16"

  azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]

  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "nginx-app"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "nginx" {
  name               = "nginx-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.sg.security_group_id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}

resource "aws_lb_target_group" "nginx" {
  name_prefix = "nginx"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "nginx" {
  count = length(aws_instance.web)

  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  count = 1

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id    = module.vpc.private_subnets[count.index]

  vpc_security_group_ids = [
    module.sg.security_group_id,
  ]

  user_data = <<EOF
#!/bin/bash
apt update -y
apt install -y nginx
echo '<!DOCTYPE html><html><body><h1>Hello World</h1></body></html>' /var/www/html/index.html
systemctl start nginx
EOF

  tags = {
    Name = "nginx"
  }
}
