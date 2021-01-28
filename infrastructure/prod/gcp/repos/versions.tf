terraform {
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
    }
  }
  required_version = ">= 0.13"
}
