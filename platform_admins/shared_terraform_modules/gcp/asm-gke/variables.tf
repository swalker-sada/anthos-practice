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

variable "project_id" {
  description = "The project in which the resource belongs."
  type        = string
}

variable "clusters" {
  description = "Map cluster indices to list of clusters to add ASM to."
  type = map(object({
    name     = string
    endpoint = string
    location = string
    regional = bool
  }))
}

variable "asm_properties" {
  description = "ASM properties that may be distinct by ASM version.  The branch can be branch or tag"
  type = object({
    version   = string
    rev_label = string
    branch    = string
  })
}