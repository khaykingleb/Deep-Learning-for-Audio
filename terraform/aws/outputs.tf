output "instance_public_ip" {
  value       = aws_eip.this.public_ip
  description = "Public IP assigned to the EC2 instance."
}
