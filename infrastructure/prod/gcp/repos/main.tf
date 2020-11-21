/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "gitlab_group" "platform-admins" {
  name             = var.platform_admins
  path             = var.platform_admins
  description      = "An group of projects for Platform Admins"
  visibility_level = "internal"
}

resource "gitlab_group_variable" "platform-admins-cicd-gsa-private-key" {
   group     = gitlab_group.platform-admins.id
   key       = "GCP_CICD_SA_KEY"
   value     = data.terraform_remote_state.prod_gcp_cicd_gsa.outputs.cicd_sa_key_base64
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "platform-admins-ssh-private-key" {
   group     = gitlab_group.platform-admins.id
   key       = "MANIFEST_WRITER_KEY"
   value     = data.terraform_remote_state.prod_gcp_ssh_key.outputs.private_key
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "platform-admins-acm-repo" {
   group     = gitlab_group.platform-admins.id
   key       = "ACM_REPO_SSH_URL"
   value     = gitlab_project.anthos-config-management.ssh_url_to_repo
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "ob-repo" {
   group     = gitlab_group.platform-admins.id
   key       = "OB_REPO_SSH_URL"
   value     = gitlab_project.online-boutique.ssh_url_to_repo
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "platform-admins-gcp-project" {
   group     = gitlab_group.platform-admins.id
   key       = "PROJECT_ID"
   value     = var.project_id
   protected = false
   masked    = false
}

resource "gitlab_project" "anthos-config-management" {
  name                   = var.acm
  description            = "Anthos Config Management repo"
  namespace_id           = gitlab_group.platform-admins.id
  visibility_level       = "internal"
  shared_runners_enabled = true
  default_branch   = "main"
  depends_on       = [gitlab_group.platform-admins]
}

resource "gitlab_deploy_key" "anthos-config-management" {
  project    = gitlab_project.anthos-config-management.id
  title      = "acm deploy key"
  key        = data.terraform_remote_state.prod_gcp_ssh_key.outputs.public_key_openssh
  can_push   = "true"
  depends_on = [gitlab_project.anthos-config-management]
}

resource "gitlab_group" "online-boutique" {
  name             = var.online_boutique_group
  path             = var.online_boutique_group
  description      = "Online boutique group"
  visibility_level = "internal"
  depends_on       = [gitlab_deploy_key.anthos-config-management]
}

resource "gitlab_group_variable" "online-boutique-cicd-gsa-private-key" {
   group     = gitlab_group.online-boutique.id
   key       = "GCP_CICD_SA_KEY"
   value     = data.terraform_remote_state.prod_gcp_cicd_gsa.outputs.cicd_sa_key_base64
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "ssh-private-key" {
   group     = gitlab_group.online-boutique.id
   key       = "MANIFEST_WRITER_KEY"
   value     = data.terraform_remote_state.prod_gcp_ssh_key.outputs.private_key
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "acm-repo" {
   group     = gitlab_group.online-boutique.id
   key       = "ACM_REPO_SSH_URL"
   value     = gitlab_project.anthos-config-management.ssh_url_to_repo
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "gcp-project" {
   group     = gitlab_group.online-boutique.id
   key       = "PROJECT_ID"
   value     = var.project_id
   protected = false
   masked    = false
}

resource "gitlab_project" "online-boutique" {
  name                   = var.online_boutique_project
  description            = "Online boutique project"
  namespace_id           = gitlab_group.online-boutique.id
  visibility_level       = "internal"
  shared_runners_enabled = true
  default_branch         = "main"
  depends_on             = [gitlab_group.online-boutique]
}

resource "gitlab_deploy_key" "online-boutique" {
  project    = gitlab_project.online-boutique.id
  title      = "ssh deploy key"
  key        = data.terraform_remote_state.prod_gcp_ssh_key.outputs.public_key_openssh
  can_push   = "true"
  depends_on = [gitlab_project.online-boutique]
}

resource "gitlab_project" "shared-cd" {
  name                   = var.sharedcd
  description            = "Shared CD repo"
  namespace_id           = gitlab_group.platform-admins.id
  visibility_level       = "internal"
  shared_runners_enabled = true
  default_branch   = "main"
  depends_on       = [gitlab_project.online-boutique]
}

resource "gitlab_deploy_key" "shared-cd" {
  project    = gitlab_project.shared-cd.id
  title      = "ssh deploy key"
  key        = data.terraform_remote_state.prod_gcp_ssh_key.outputs.public_key_openssh
  can_push   = "true"
  depends_on = [gitlab_project.shared-cd]
}

resource "gitlab_group" "bank-of-anthos" {
  name             = var.bank_of_anthos_group
  path             = var.bank_of_anthos_group
  description      = "Bank of Anthos group"
  visibility_level = "internal"
  depends_on       = [gitlab_project.shared-cd]
}

resource "gitlab_group_variable" "bank-of-anthos-cicd-gsa-private-key" {
   group     = gitlab_group.bank-of-anthos.id
   key       = "GCP_CICD_SA_KEY"
   value     = data.terraform_remote_state.prod_gcp_cicd_gsa.outputs.cicd_sa_key_base64
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "bank-of-anthos-ssh-private-key" {
   group     = gitlab_group.bank-of-anthos.id
   key       = "MANIFEST_WRITER_KEY"
   value     = data.terraform_remote_state.prod_gcp_ssh_key.outputs.private_key
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "bank-of-anthos-acm-repo" {
   group     = gitlab_group.bank-of-anthos.id
   key       = "ACM_REPO_SSH_URL"
   value     = gitlab_project.anthos-config-management.ssh_url_to_repo
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "bank-of-anthos-gcp-project" {
   group     = gitlab_group.bank-of-anthos.id
   key       = "PROJECT_ID"
   value     = var.project_id
   protected = false
   masked    = false
}

resource "gitlab_project" "bank-of-anthos" {
  name                   = var.bank_of_anthos_project
  description            = "Bank of Anthos project"
  namespace_id           = gitlab_group.bank-of-anthos.id
  visibility_level       = "internal"
  shared_runners_enabled = true
  default_branch         = "main"
  depends_on             = [gitlab_group.bank-of-anthos]
}

resource "gitlab_deploy_key" "bank-of-anthos" {
  project    = gitlab_project.bank-of-anthos.id
  title      = "ssh deploy key"
  key        = data.terraform_remote_state.prod_gcp_ssh_key.outputs.public_key_openssh
  can_push   = "true"
  depends_on = [gitlab_project.bank-of-anthos]
}

resource "gitlab_group" "databases" {
  name             = var.databases_group
  path             = var.databases_group
  description      = "Databases group"
  visibility_level = "internal"
  depends_on       = [gitlab_project.bank-of-anthos]
}

resource "gitlab_group_variable" "databases-cicd-gsa-private-key" {
   group     = gitlab_group.databases.id
   key       = "GCP_CICD_SA_KEY"
   value     = data.terraform_remote_state.prod_gcp_cicd_gsa.outputs.cicd_sa_key_base64
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "databases-ssh-private-key" {
   group     = gitlab_group.databases.id
   key       = "MANIFEST_WRITER_KEY"
   value     = data.terraform_remote_state.prod_gcp_ssh_key.outputs.private_key
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "databases-acm-repo" {
   group     = gitlab_group.databases.id
   key       = "ACM_REPO_SSH_URL"
   value     = gitlab_project.anthos-config-management.ssh_url_to_repo
   protected = false
   masked    = false
}

resource "gitlab_group_variable" "databases-gcp-project" {
   group     = gitlab_group.databases.id
   key       = "PROJECT_ID"
   value     = var.project_id
   protected = false
   masked    = false
}

resource "gitlab_project" "crdb" {
  name                   = var.crdb
  description            = "CRDB project"
  namespace_id           = gitlab_group.databases.id
  visibility_level       = "internal"
  shared_runners_enabled = true
  default_branch         = "main"
  depends_on             = [gitlab_group.databases]
}

resource "gitlab_deploy_key" "databases" {
  project    = gitlab_project.crdb.id
  title      = "ssh deploy key"
  key        = data.terraform_remote_state.prod_gcp_ssh_key.outputs.public_key_openssh
  can_push   = "true"
  depends_on = [gitlab_project.crdb]
}

resource "gitlab_project" "redis" {
  name                   = var.redis
  description            = "Redis project"
  namespace_id           = gitlab_group.databases.id
  visibility_level       = "internal"
  shared_runners_enabled = true
  default_branch         = "main"
  depends_on             = [gitlab_project.crdb]
}

resource "gitlab_deploy_key" "redis" {
  project    = gitlab_project.redis.id
  title      = "ssh deploy key"
  key        = data.terraform_remote_state.prod_gcp_ssh_key.outputs.public_key_openssh
  can_push   = "true"
  depends_on = [gitlab_project.redis]
}

# test harness
resource "gitlab_group" "test-harness" {
  name             = var.test_harness_group
  path             = var.test_harness_group
  description      = "Test Harness related projects"
  visibility_level = "internal"
}

resource "gitlab_group_variable" "test-harness-cicd-gsa-private-key" {
  group     = gitlab_group.test-harness.id
  key       = "GCP_CICD_SA_KEY"
  value     = data.terraform_remote_state.prod_gcp_cicd_gsa.outputs.cicd_sa_key_base64
  protected = false
  masked    = false
}

resource "gitlab_group_variable" "test-harness-ssh-private-key" {
  group     = gitlab_group.test-harness.id
  key       = "MANIFEST_WRITER_KEY"
  value     = data.terraform_remote_state.prod_gcp_ssh_key.outputs.private_key
  protected = false
  masked    = false
}

resource "gitlab_group_variable" "test-harness-acm-repo" {
  group     = gitlab_group.test-harness.id
  key       = "ACM_REPO_SSH_URL"
  value     = gitlab_project.anthos-config-management.ssh_url_to_repo
  protected = false
  masked    = false
}

resource "gitlab_group_variable" "test-harness-gcp-project" {
  group     = gitlab_group.test-harness.id
  key       = "PROJECT_ID"
  value     = var.project_id
  protected = false
  masked    = false
}

resource "gitlab_deploy_key" "test-harness" {
  project    = gitlab_project.test-harness.id
  title      = "ssh deploy key"
  key        = data.terraform_remote_state.prod_gcp_ssh_key.outputs.public_key_openssh
  can_push   = "true"
  depends_on = [gitlab_project.test-harness]
}

resource "gitlab_project" "test-harness" {
  name                   = var.test_harness_project
  description            = "Test Harness repo"
  namespace_id           = gitlab_group.test-harness.id
  visibility_level       = "internal"
  shared_runners_enabled = true
  default_branch         = "main"
  depends_on             = [gitlab_group.test-harness]
}