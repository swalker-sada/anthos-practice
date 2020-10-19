#!/usr/bin/env bash

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

  
