# Anthos Multicloud Workshop

[[_TOC_]]

## Architecture

```mermaid
%%{init: { 'theme': 'default' } }%%
graph TD
classDef dev fill:#F2ECE8,stroke:#333,stroke-width:1px;
classDef stage fill:#99C4C8,color:#fff,stroke:#333,stroke-width:1px;
classDef prod fill:#C3E5E9,stroke:#333,stroke-width:1px;
classDef anthos fill:#E7ECEF,stroke:#333,stroke-width:1px;

subgraph Prod
  subgraph prodgcp[GCP]
    prodgcpvpc[VPC] --> prodgcpgke1[GKE1]
    prodgcpvpc --> prodgcpgke2[GKE2]
  end
  subgraph prodaws[AWS]
    prodawsvpc[VPC] --> prodawseks1[EKS1]
    prodawsvpc --> prodawseks2[EKS2]
  end
  subgraph prodanthos[Anthos]
    prodgcpgke1 -.-> prodasm[ASM]
    prodgcpgke2 -.-> prodasm
    prodawseks1 -.-> prodasm
    prodawseks2 -.-> prodasm
    prodacm[ACM]
  end
end

subgraph Stage
  subgraph stagegcp[GCP]
    stagegcpvpc[VPC] --> stagegcpgke1[GKE1]
  end
  subgraph stageaws[AWS]
    stageawsvpc[VPC] --> stageawseks1[EKS1]
  end
  subgraph stageanthos[Anthos]
    stagegcpgke1 -.-> stageasm[ASM]
    stageawseks1 -.-> stageasm
    stageacm[ACM]
  end
end

subgraph Dev
  subgraph devgcp[GCP]
    devgcpvpc[VPC] --> devgcpgke1[GKE1]
    devgcpvpc --> devgcpgke2[GKE2]
  end
  subgraph devanthos[Anthos]
    devgcpgke1 -.-> devasm[ASM]
    devgcpgke2 -.-> devasm
    devacm[ACM]
  end
end

subgraph Gitlab
  subgraph Repos
    acmrepo[anthos-config-management]
    obrepo[online-boutique]
  end
end
devacm -.-> acmrepo
stageacm -.-> acmrepo
prodacm -.-> acmrepo

class Prod prod;
class Stage stage;
class Dev dev;

```

## Objectives

In this workshop you will accomplish the following:

- Setting up an Anthos multi-environment multicloud environment on GCP and AWS using GKE and EKS anthos attached clusters (registered via GKE Hub).
- Setting up VPCs in each environment in GCP and VPC.
- Setting up GKE and EKS clusters in GCP and AWS.
- Deploying Anthos Config Management (ACM) on all clusters.
- Setting up a local Gitlab for source code management (SCM) with repos.
- Creating multicloud service meshes per environment using Anthos Service Mesh (ASM)
- Showcase distributed services and service migration between clouds.

## Setting up the environment in Qwiklabs

This workshop is intended to be run in Qwiklabs.

You should see two labs in Qwiklabs as part of this workshop. One of the labs sets up an environment in GCP (a clean GCP project) and the other sets up an environment in AWS (a federated qwiklabs managed account). Starting both of these labs provide you with credentials to both environments.

For GCP, you get a Google account username, password and a GCP project. You use these credentials to access and administer resources in your provided GCP project via GCP Console and Cloud Shell.

For AWS, you get an Access Key ID and a Secret Access Key. These credentials allow you full control over both environments.

These two environments are temporary and expire at the end of this workshop (or when time expires). If you would like a persistent setup of this workshop, you can follow the same instructions using your own GCP and AWS accounts.

## Setup

In Qwiklabs, you should see two labs. One lab starts the GCP environment, and the other starts the AWS environment.

- Start both lab environments. Starting the two labs will give you credentials to both GCP and AWS environments.
- From the GCP lab, open Cloud Shell. This lab is intended to be run from Cloud Shell.

```
ssh.cloud.google.com
```

- Set GCP and AWS credentials. Get the value of the GCP Project ID, AWS Access Key ID and AWS Secret Access
  Key from Qwiklabs and replace the values with your values below.

```
export GOOGLE_PROJECT=[GCP PROJECT ID]
export AWS_ACCESS_KEY_ID=[AWS_ACCESS_KEY_ID]
export AWS_SECRET_ACCESS_KEY=[AWS_SECRET_ACCESS_KEY]
```

- Create a `WORKDIR` for this tutorial. All files related to this tutorial end up in `WORKDIR`.

```
mkdir -p $HOME/anthos-multicloud && cd $HOME/anthos-multicloud && export WORKDIR=$HOME/anthos-multicloud
```

- Clone the workshop repo.

```
git clone https://gitlab.com/ameer00/anthos-multicloud-workshop.git ${WORKDIR}/anthos-multicloud-workshop
```

## Deploying the environment

- Run the `build.sh` script from the root folder to set up the environment in GCP and AWS. The `build.sh` script installs the required tools in Cloud Shell and triggers a _cloudbuild_ job which creates a number of resources in both GCP and AWS.

```
cd ${WORKDIR}/anthos-multicloud-workshop
./build.sh
```

- The `build.sh` script creates an `infrastructure` repo in Cloud Source Repository (CSR). The `infrastructiure` repo contains the code to deploy the Anthos resources in GCP and AWS. Commiting to the _master_ branch of the `infrastructure` repository triggers a series of build pipelines in **Cloudbuild**. These pipelines deploys the Anthos platform resources in both GCP and AWS.
  > Note that the infrastructure build process can take approximately 30 - 35 minutes to complete.
- After the `build.sh` script finishes, navigate to the **Cloudbuild** details page in Cloud Console from the left hand navbar.
- Initially, you see the `main` build running. Click on the build ID to inspect the stages of the pipeline. The `main` build pipeline trigger additional builds.
- The following diagram illustrates the builds and the approximate times each stage takes to complete. Note that all the `env` and the `gitlab` stages run concurrently as shown.

```mermaid
%%{init: { 'theme': 'default' } }%%
graph LR
classDef pipeline fill:#FAFAC6,stroke:#333;

commit -->|6mins|Main[Main - Create custom builder] -->|2mins| Project_Setup[Project Setup - SSH Keys and Anthos Hub GSA]
Project_Setup -->|7mins| Dev[Dev Pipeline - Sets up the dev environment]
Project_Setup --> |23mins|Stage[Stage Pipeline - Sets up the stage environment]
Project_Setup -->|26mins| Prod[Prod Pipeline - Sets up the prod environment]
Project_Setup -->|20mins| Gitlab[Gitlab and Repos - Sets up Gitlab and repos]

class Main,Project_Setup,Dev,Stage,Prod,Gitlab pipeline;
```

- You can trigger this pipeline by running the `build.sh` script which commits the changes to the `infrastructure` CSR repo's _master_ branch.
- Alternatively, you can directly commit changes to the `infrastructure` repo which is cloned in the `${WORKDIR}/infra-repo` folder in Cloud Shell.
  > Running the `build.sh` script overrides any changes you make locally through the `infra-repo` folder.

## Infrastructure Pipeline

The following illustration provides a detailed view of the pipelines and the resources that are created.

```mermaid
%%{init: { 'theme': 'default' } }%%
graph LR
classDef aws fill:#F2ECE8,stroke:#333,stroke-width:2px;
classDef gcp fill:#99C4C8,stroke:#333,stroke-width:2px;
classDef mesh fill:#C3E5E9,stroke:#333,stroke-width:1px;
classDef anthos fill:#FAFAC6,stroke:#333,stroke-width:1px,stroke-dasharray: 5 5;

installer([Build Installer Image])

prodgcpvpc([Prod GCP VPC])
stagegcpvpc([Stage GCP VPC])
devgcpvpc([Dev GCP VPC])
prodgke([2 x Prod GKE w/ ACM])
stagegke([1 x Stage GKE w/ ACM])
devgke([2 x Dev GKE w/ ACM])


gitlab([Gitlab])
repos([Repos])
hub_gsa([Anthos Hub GCP SA])
ssh_key([SSH Key Pair for ACM])

prodawsvpc([Prod AWS VPC])
stageawsvpc([Stage AWS VPC])
prodeks([2 x Prod EKS w/ ACM])
stageeks([1 x Stage EKS w/ ACM])

prodasm[Prod ASM]
stageasm[Stage ASM]
devasm[Dev ASM]

ssh_key --> prodgcpvpc
ssh_key --> prodawsvpc

ssh_key --> stagegcpvpc
ssh_key --> stageawsvpc

ssh_key --> devgcpvpc

ssh_key --> gitlab -->|Create ACM and Online Boutique repos| repos

installer -->|Store creds in GCS| hub_gsa
installer -->|Create SSH key pair and store in GCS| ssh_key

ssh_key -->|Public key as deploy token| repos

hub_gsa --> prodeks
hub_gsa --> stageeks

subgraph Gitlab_Pipeline
  gitlab
  repos
end

subgraph Project_Pipeline
  hub_gsa
  ssh_key
end

subgraph Main_Pipeline
  installer
end

subgraph Prod_Pipeline
  subgraph Prod
    subgraph GCP_Prod[GCP]
      prodgcpvpc --> prodgke
    end
    subgraph AWS_Prod[AWS]
      prodawsvpc --> prodeks
    end
    subgraph ASM_Prod[ASM]
      prodgke -.-> prodasm
      prodeks -.-> prodasm
    end
  end
end

subgraph Stage_Pipeline
  subgraph Stage
    subgraph GCP_Stage[GCP]
      stagegcpvpc --> stagegke
    end
    subgraph AWS_Stage[AWS]
      stageawsvpc --> stageeks
    end
    subgraph ASM_Stage[ASM]
      stagegke -.-> stageasm
      stageeks -.-> stageasm
    end
  end
end

subgraph Dev_Pipeline
  subgraph Dev
    subgraph GCP_Dev[GCP]
      devgcpvpc --> devgke
    end
    subgraph ASM_Dev[ASM]
      devgke -.-> devasm
    end
  end
end

class AWS_Prod,AWS_Stage aws;
class GCP_Prod,GCP_Stage,GCP_Dev gcp;
class ASM_Prod,ASM_Stage,ASM_Dev mesh;
class Prod_Pipeline,Stage_Pipeline,Dev_Pipeline,Gitlab_Pipeline,Project_Pipeline,Main_Pipeline anthos;
```