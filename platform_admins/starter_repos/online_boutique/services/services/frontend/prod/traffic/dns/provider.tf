# Version
terraform {
  required_version = ">=0.12, <0.14"
}

# Provider
provider "google" { version = "~> 3.39.0" }
provider "google-beta" { version = "~> 3.39.0" }
provider "kubernetes" { version = "~>1.11.0" }