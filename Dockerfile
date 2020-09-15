# Copyright 2019 Google LLC
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

FROM gcr.io/google.com/cloudsdktool/cloud-sdk:debian_component_based
RUN apt install -y jq python3 openssl gettext coreutils wget unzip curl dnsutils

ENV TERRAFORM_VERSION=0.12.26
# ENV TF_PLUGIN_CACHE_DIR /workspace/.terraform.d/plugin-cache

# Install terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    chmod +x terraform && \
    mv terraform /usr/local/bin && \
    rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install aws-iam-authenticator
RUN curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x /usr/local/bin/aws-iam-authenticator

# Install kubectl kpt kustomize
RUN gcloud components install kubectl kpt kustomize

# Install nomos
# RUN gsutil cp gs://config-management-release/released/latest/linux_amd64/nomos /usr/bin/local/nomos && \
    # chmod +x /usr/bin/local/nomos && \
    # nomos version
