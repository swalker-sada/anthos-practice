# Version
terraform {
  required_version = ">=0.13, <0.14"
}

# Provider
provider "google" { version = "~> 3.54.0" }
provider "google-beta" { version = "~> 3.54.0" }
provider "kubernetes" { version = "~>1.11.0" }