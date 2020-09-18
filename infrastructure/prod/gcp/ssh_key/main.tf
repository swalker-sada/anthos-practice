resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_key_private_file" {
  content  = tls_private_key.ssh-key.private_key_pem
  filename = "${path.module}/ssh-key-private"
}

resource "local_file" "ssh_key_public_file" {
  content  = tls_private_key.ssh-key.public_key_openssh
  filename = "${path.module}/ssh-key-public.pub"
}

resource "google_storage_bucket_object" "ssh_key_private_file_gcs" {
  name   = "ssh-keys/ssh-key-private"
  source = local_file.ssh_key_private_file.filename
  bucket = var.project_id
}

resource "google_storage_bucket_object" "ssh_key_public_file_gcs" {
  name   = "ssh-keys/ssh-key-public.pub"
  source = local_file.ssh_key_public_file.filename
  bucket = var.project_id
}
