resource "aws_instance" "app_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.instanceSG.id
  ]







  user_data = <<-EOF
  #!/bin/bash
  echo "Hello World" > index.html
  nohup busybox httpd -f -p 8080 &
  EOF

  tags = {
    Name = var.instance_name
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
    # prefix_list_ids = [ "*" ]
    # security_groups = [ "*" ]
    # self = false
  }
  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow port 80"
    from_port        = 80
    to_port          = 80
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
    # prefix_list_ids = [ "*" ]
    # security_groups = [ "*" ]
    # self = false
  }
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow port 8080"
    from_port        = 0
    ipv6_cidr_blocks = ["::/0"]
    to_port          = 0
    protocol         = "-1"
    # prefix_list_ids = [ "*" ]
    # security_groups = [ "*" ]
    # self = false

  }

  tags = {
    "Name" = "allow port 8080 and 80"
  }
}
