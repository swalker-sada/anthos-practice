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

resource "null_resource" "exec_make_gcr_public" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/make_gcr_public.sh"
    environment = {
      PROJECT_ID             = var.project_id
    }
  }
  triggers = {
    script_sha1      = sha1(file("${path.module}/make_gcr_public.sh")),
  }
}
