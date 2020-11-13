## Objective

1. Initialize the `config` repository to ensure the clusters are prepared to deploy applications. 
> You only need to do this once. If you have already deployed another application for example [Bank of Anthos](/platform_admins/docs/multicluster-cd-bank-of-anthos.md), then may have already done this.

## Anthos Config Management

[Anthos Config Management](https://cloud.google.com/anthos/config-management) uses the `config` repository to deploy Kubernetes manifests to all Kubernetes clusters in the platform. This way, the `config` repo becomes the _source of truth/record_ for all application configuration. The files needed for the repository are located in the `/platform_admins/starter_repos/config` folder of the workshop repository. You copy the contents of this folder into the `config` repo in Gitlab (created in the workshop) to prepare the repo.

`config` repository. This repository is responsible for creating a _landing zone_ for each service to be deployed. The term _landing zone_ refers to a portion of the platform that is configured for a specific service. In Kubernetes, this could be a [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) as well as policies that may be required for a particular service. Each service gets deployed in its own namespace. Anthos Config Management [ACM](https://cloud.google.com/anthos/config-management) _config sync_ functionality is used to _pull_ Kubernetes config from the `config` repo and apply to the clusters. This ensures these namespaces are created in all clusters. `config` repo is also used to deploy the final _hydrated_ service configs to the clusters. Hydrated Kubernetes config refers to the final intended state for a service.

## `config` Repository

1. Run the following commands to initialize the `config` repository.

```bash
source ${WORKDIR}/anthos-multicloud-workshop/user_setup.sh
cd ${WORKDIR}
# init git
git config --global user.email "${GCLOUD_USER}"
git config --global user.name "Cloud Shell"
if [ ! -d ${HOME}/.ssh ]; then
  mkdir ${HOME}/.ssh
  chmod 700 ${HOME}/.ssh
fi
# pre-grab gitlab public key
ssh-keyscan -t ecdsa-sha2-nistp256 -H gitlab.endpoints.${GOOGLE_PROJECT}.cloud.goog >> ~/.ssh/known_hosts
git clone git@gitlab.endpoints.${GOOGLE_PROJECT}.cloud.goog:platform-admins/config.git
cd config
touch README.md
git add .
git commit -m "initial commit"
git branch -m master main
git push -u origin main
git checkout -b prep
cp -r ${WORKDIR}/anthos-multicloud-workshop/platform_admins/starter_repos/config/. .
git add .
git commit -m 'apply appropriate istio rev label'
# issues with auto-merge -- https://gitlab.com/gitlab-org/gitlab/-/issues/260311
git push -u origin prep -o merge_request.create -o merge_request.merge_when_pipeline_succeeds -o merge_request.target=main 
```

```
# Output (Do not copy)
remote:
remote: View merge request for prep:
remote:   https://gitlab.endpoints.qwiklabs-gcp-02-3b55f8d468d3.cloud.goog/platform-admins/config/-/merge_requests/1
remote:
To gitlab.endpoints.qwiklabs-gcp-02-3b55f8d468d3.cloud.goog:platform-admins/config.git
 * [new branch]      prep -> prep
Branch 'prep' set up to track remote branch 'prep' from 'origin'.
```

1. Access gitlab with the provided link and select `Merge` to update the applicable namespace istio revision label.

```bash
echo -e "https://gitlab.endpoints.${GOOGLE_PROJECT}.cloud.goog/platform-admins/config/-/merge_requests/1" 
```

<img src="/platform_admins/docs/img/gitlab-config-merge.png" width=50% height=50%>

1. Wait a few moments and ensure all clusters (except `gitlab` cluster) are `SYNCED` to the `config` repo. Run the following command.

   - if you're having trouble with git and ssh-keys, make sure your ssh-agent is running. the easiest thing to do is to re-run the setup script via: `source ${WORKDIR}/anthos-multicloud-workshop/user_setup.sh` (note the prefix `source `)
   
```bash
nomos status
```

You may need to run this command multiple times until clusters are synced. The output should look as follows.

```
Current   Context                  Sync Status      Last Synced Token   Sync Branch   Resource Status
-------   -------                  -----------      -----------------   -----------   ---------------
          eks-prod-us-west2ab-1    SYNCED           21887d8b                          Healthy
          eks-prod-us-west2ab-2    SYNCED           21887d8b                          Healthy
          eks-stage-us-east1ab-1   SYNCED           21887d8b                          Healthy
          gitlab                   NOT INSTALLED
          gke-dev-us-west1a-1      SYNCED           21887d8b                          Healthy
          gke-dev-us-west1b-2      SYNCED           21887d8b                          Healthy
*         gke-prod-us-west2a-1     SYNCED           21887d8b                          Healthy
          gke-prod-us-west2b-2     SYNCED           21887d8b                          Healthy
          gke-stage-us-east4b-1    SYNCED           21887d8b                          Healthy
```

Syncing to the `config` repo ensures that the namespaces for the Online Boutique application are created on all clusters. You can now deploy the Online Boutique app.