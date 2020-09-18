output "private_key" {
  value = tls_private_key.ssh-key.private_key_pem
}

output "public_key_openssh" {
  value = tls_private_key.ssh-key.public_key_openssh
}
