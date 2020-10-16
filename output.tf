output "instance_ip_addr" {
  value       = aws_instance.module_instance.public_ip
  description = "The public IP address of the main server instance."
}