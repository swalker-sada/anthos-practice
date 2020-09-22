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

FROM gcr.io/google.com/cloudsdktool/cloud-sdk:alpine

RUN apk --update add --no-cache \
coreutils \
curl \
gettext \
jq \
openssl \
python3 \
unzip \
wget

ENV TERRAFORM_VERSION=0.12.26

# Install terraform
RUN echo "INSTALL TERRAFORM v${TERRAFORM_VERSION}" \
&& wget -q -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip terraform.zip \
&& chmod +x terraform \
&& mv terraform /usr/local/bin \
&& rm -rf terraform.zip

ENV AWS_IAM_AUTHENTICATOR_VERSION=1.17.9/2020-08-04

# Install aws-iam-authenticator
RUN echo "INSTALL TERRAFORM v${TERRAFORM_VERSION}" \
&& wget -q -O /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VERSION}/bin/linux/amd64/aws-iam-authenticator \
&& chmod +x /usr/local/bin/aws-iam-authenticator

# Install additional tools
RUN gcloud components install \
kpt \
kubectl \
kustomize \
alpha \
&& rm -rf $(find google-cloud-sdk/ -regex ".*/__pycache__") \
&& rm -rf google-cloud-sdk/.install/.backup
