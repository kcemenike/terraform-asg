output "public_ip" {
  value = aws_instance.app_server.public_ip
}

# output "loadbalancer_dns" {
#   value = aws_lb.appserver-lb.dns_name
# }
