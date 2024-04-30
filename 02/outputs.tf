output "scp" {
  value = "scp -i workers.pem workers.pem ec2-user@${module.public_worker.public_ip}:/home/ec2-user"
}

output "ssh" {
  value = "ssh -i workers.pem ec2-user@${module.public_worker.public_ip}"
}

output "ssh_private" {
  value = "ssh -i workers.pem ec2-user@${module.private_worker.private_ip}"
}
