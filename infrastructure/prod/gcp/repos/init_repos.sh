#!/usr/bin/env bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Get SSH private key
echo ${SSH_KEY_PRIVATE} > ssh-key-private
chmod 0600 ssh-key-private
eval `ssh-agent` && ssh-add ssh-key-private

# ASM repo URL
export ACM_REPO_URL="git@gitlab.endpoints.${PROJECT_ID}.cloud.goog:platform-admins/anthos-config-management.git"

git clone ${ACM_REPO_URL}

pushd ${ACM_REPO_URL}
  ACM_EXISTS=$(ls starter_repos/anthos_config_management/system/repo.yaml 2> /dev/null)
  if [ -z ${ACM_EXISTS} ]; then
    cp -r ./starter_repos/anthos_config_management/. .    
  fi
  git add .
  git commit -m "Initial commit"
  git push
popd

  
