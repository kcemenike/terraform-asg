resource "aws_instance" "app_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.instanceSG.id
  ]
  user_data = <<-EOF
  #!/bin/bash
  echo "Hello World" > index.html
  nohup busybox httpd -f -p "${var.server_port}" &
  EOF
  tags = {
    Name = "App server"
  }
}

resource "aws_security_group" "instanceSG" {
  name = "terraform-instance-SG"
  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow port 8080"
    from_port        = 8080
    to_port          = 8080
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
    # prefix_list_ids  = []
    # security_groups  = []
    # self             = false
  }
  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow port ${var.server_port}"
    from_port        = var.server_port
    to_port          = var.server_port
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
    # prefix_list_ids  = []
    # security_groups  = []
    # self             = false
  }
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow port 8080"
    from_port        = 0
    ipv6_cidr_blocks = ["::/0"]
    to_port          = 0
    protocol         = "-1"
    # prefix_list_ids = []
    # security_groups = []
    # self = false

  }

}
resource "aws_security_group" "asg-sg" {
  name   = "asg-SG"
  vpc_id = aws_vpc.main.id
  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow port 8080"
    from_port        = 8080
    to_port          = 8080
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
    # prefix_list_ids  = []
    # security_groups  = []
    # self             = false
  }
  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow port ${var.server_port}"
    from_port        = var.server_port
    to_port          = var.server_port
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
    # prefix_list_ids  = []
    # security_groups  = []
    # self             = false
  }
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow port 8080"
    from_port        = 0
    ipv6_cidr_blocks = ["::/0"]
    to_port          = 0
    protocol         = "-1"
    # prefix_list_ids = []
    # security_groups = []
    # self = false

  }
  tags = {
    "Name" = "allow port 8080 and ${var.server_port}"
  }
}

resource "aws_launch_configuration" "appserver-launch-config" {
  image_id                    = "ami-08d70e59c07c61a3a"
  instance_type               = "t2.micro"
  key_name                    = "final"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.asg-sg.id]
  user_data                   = <<-EOF
  #!/bin/bash
  echo "Hello World" > index.html
  nohup busybox httpd -f -p "${var.server_port}" &
  EOF
  lifecycle { # A TF setting that makes sure a new resource is created before the old is destoyed
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "appserver-ASG" {
  launch_configuration = aws_launch_configuration.appserver-launch-config.id
  vpc_zone_identifier  = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  target_group_arns    = [aws_alb_target_group.lb-tg.arn]
  min_size             = 2
  max_size             = 5
  tag {
    key                 = "Name"
    value               = "appserver-asg"
    propagate_at_launch = true # required - enables propagation of tag to EC2 instances
  }
}

resource "aws_lb" "appserver-lb" {
  name               = "app-server-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.asg-sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Environment = "production"
  }
}

resource "aws_alb_listener" "lb" {
  load_balancer_arn = aws_lb.appserver-lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.lb-tg.arn
  }
}

resource "aws_alb_target_group" "lb-tg" {
  name     = "lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}
