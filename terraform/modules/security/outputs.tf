output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "web_sg_id" {
  value = aws_security_group.web.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}

output "cache_sg_id" {
  value = aws_security_group.cache.id
}
output "jenkins_sg_id" {
  value = aws_security_group.jenkins.id
}
