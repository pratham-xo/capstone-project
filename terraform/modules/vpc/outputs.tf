output "vpc_id" {
  value = aws_vpc.myvpc.id
}

output "aws_public_subnet1" {
  value = aws_subnet.public1.id
}

output "aws_public_subnet2" {
  value = aws_subnet.public2.id
}

output "aws_private_subnet1" {
  value = aws_subnet.private_subnet1.id
}

output "aws_private_subnet2" {
  value = aws_subnet.private_subnet2.id
}

output "aws_db_subnet" {
  value = aws_subnet.db_subnet.id
}

output "aws_db_subnet2" {
  value = aws_subnet.db_subnet2.id
}