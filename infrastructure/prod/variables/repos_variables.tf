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

variable "platform_admins" { default = "platform-admins" }
variable "acm" { default = "config" }
variable "sharedcd" { default = "shared-cd" }

variable "online_boutique_group" { default = "online-boutique" }
variable "online_boutique_project" { default = "online-boutique" }

variable "bank_of_anthos_group" { default = "bank-of-anthos" }
variable "bank_of_anthos_project" { default = "bank-of-anthos" }

variable "databases_group" { default = "databases" }
variable "crdb" { default = "cockroachdb" }
variable "redis" { default = "redis" }

variable "test_harness_group" { default = "test-harness" }
variable "test_harness_project" { default = "test-harness" }