data "aws_availability_zones" "available" {
  state = "available"
}

# data "aws_route_table" "public_route_1" {
#   subnet_id = aws_subnet.public_subnet_1.id
# }
# data "aws_route_table" "public_route_2" {

#   subnet_id = aws_subnet.public_subnet_2.id
# }
