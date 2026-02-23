# modules/loadbalancer/outputs.tf

output "load_balancer_dns" {
  value       = aws_elb.main.dns_name
  description = "The DNS name of the Classic Load Balancer"
}

output "elb_id" {
  value       = aws_elb.main.id
  description = "The ID of the Classic Load Balancer"
}