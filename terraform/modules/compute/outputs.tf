output "launch_template_id" {
  value = aws_launch_template.app.id
}
output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_dns}:8080"
}
