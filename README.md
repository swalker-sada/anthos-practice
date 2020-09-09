# Anthos Multicloud with attached clusters - GKE and EKS Edition

## Architecture
```mermaid
%%{init: { 'theme': 'default' } }%%
graph TD
classDef dev fill:#F2ECE8,stroke:#333,stroke-width:1px;
classDef stage fill:#99C4C8,color:#fff,stroke:#333,stroke-width:1px;
classDef prod fill:#C3E5E9,stroke:#333,stroke-width:1px;

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

- Setting up an Anthos multicloud environment on GCP and AWS using GKE and EKS anthos attached clusters (registered via GKE Hub).
- Deploying Anthos Config Management (ACM) and Anthos Service Mesh (ASM) on both clusters.
- Deploying Online Boutique application on both clusters.
- Setting up monitoring and observability via Cloud Monitoring.
- Setting up global load balancing via GCLB to send client traffic (and loadgenerator traffic) to both instances on the Online Boutique app running in GKE and EKS (serving use case)
- Deploying Bank of Anthos on EKS cluster.
- Using Anthos to reliably migrate Bank of Anthos from AWS (EKS) to GCP (GKE).

## Setting up the environment in Qwiklabs

This workshop is intended to be run in Qwiklabs. 

You should see two labs in Qwiklabs as part of this workshop. One of the labs sets up an environment (a clean GCP project) in GCP while the other sets up an environment in AWS (a federated qwiklabs managed account).  Starting both of these labs provide you with credentials to both environments. For GCP, you get a Google account username, password and a GCP project. You use these credentials to access and administer resources in your provided GCP project via GCP Console and Cloud Shell. For AWS, you get an Access Key ID and a Secret Access Key. These credentials allow you full control over both environments. These two environments are temporary and expire at the end of this workshop (or when time expires). If you would like a persistent setup of this workshop, you can follow the same instructions using your own GCP and AWS accounts.

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
export ASM_VERSION=1.6.8-asm.9
```

- Create a `WORKDIR` for this tutorial. All files related to this tutorial end up in `WORKDIR`.
```
mkdir -p $HOME/anthos-multicloud && cd $HOME/anthos-multicloud && export WORKDIR=$HOME/anthos-multicloud
```
- Clone the workshop repo.
```
git clone https://gitlab.com/ameer00/anthos-multicloud-workshop.git ${WORKDIR}/attached-clusters
```

## Deploy the environment

- Run the bootstrap script to set up the environment in GCP and AWS.
```
cd ${WORKDIR}/attached-clusters
./build.sh
```
- Once the `build.sh` script finishes, it triggers an infrastructure deployment pipeline in **Cloudbuild**. This pipeline deploys the Anthos platform in both GCP and AWS.

> Note that the infrastructure pipeline can take 40 - 50 minutes to complete.

- Go to the **Cloudbuild** details page in Cloud Console from the left hand navbar.
- You see one build running. Click on the build ID to inspect the stages of the pipeline.

## Infrastructure Pipeline
```mermaid
%%{init: { 'theme': 'default' } }%%
graph LR
classDef aws fill:#F2ECE8,stroke:#333,stroke-width:2px;
classDef gcp fill:#99C4C8,stroke:#333,stroke-width:2px;
classDef mesh fill:#C3E5E9,stroke:#333,stroke-width:1px;

installer([Build Installer Image])

prodgcpvpc([Prod GCP VPC])
stagegcpvpc([Stage GCP VPC])
devgcpvpc([Dev GCP VPC])
prodgke([Prod GKE w/ ACM])
stagegke([Stage GKE w/ ACM])
devgke([Dev GKE w/ ACM])


gitlab([Gitlab])
repos([Repos])
hub_gsa([Anthos Hub GCP SA])
ssh_key([SSH Key Pair for ACM])

prodawsvpc([Prod AWS VPC])
stageawsvpc([Stage AWS VPC])
prodeks([Prod EKS w/ ACM])
stageeks([Stage EKS w/ ACM])

prodasm[Prod ASM]
stageasm[Stage ASM]
devasm[Dev ASM]

installer --> prodgcpvpc
installer --> prodawsvpc

installer --> stagegcpvpc
installer --> stageawsvpc

installer --> devgcpvpc

installer --> gitlab -->|Create ACM and Online Boutique repos| repos 
repos --> prodgke
repos --> stagegke
repos --> devgke

repos --> prodeks
repos --> stageeks

prodgcpvpc -->|Store creds in GCS| hub_gsa
installer -->|Create SSH key pair and store in GCS| ssh_key

ssh_key -->|Public key as deploy token| repos

hub_gsa --> prodeks
hub_gsa --> stageeks

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

subgraph Dev
  subgraph GCP_Dev[GCP]
    devgcpvpc --> devgke
  end
  subgraph ASM_Dev[ASM]
    devgke -.-> devasm
  end
end

class AWS_Prod,AWS_Stage aws;
class GCP_Prod,GCP_Stage,GCP_Dev gcp;
class ASM_Prod,ASM_Stage,ASM_Dev mesh;
```

## Folder Structure
```mermaid
%%{init: { 'theme': 'default' } }%%
graph LR
classDef infra fill:#F2ECE8,stroke:#333,stroke-width:2px;
classDef admin fill:#99C4C8,color:#fff,stroke:#333,stroke-width:2px;
classDef environ fill:#C3E5E9,stroke:#333,stroke-width:1px;

.
infra[infrastructure]
style infra fill:#55B3D9,stroke:#333,stroke-width:3px
admin[platform_admins]
style admin fill:#55B3D9,stroke:#333,stroke-width:3px
sharedtf[shared_terraform_modules]
style sharedtf fill:#40C7C5,stroke:#333,stroke-width:3px

. --> build.sh -.->|symlink|scripts
. --> infra
. --> admin

subgraph PLATFORM_ADMINS
  admin --> sharedtf
  sharedtf --> gcpadmin[gcp]
  style gcpadmin fill:#75FAF9,stroke:#333,stroke-width:3px
  sharedtf --> awsadmin[aws]
  style awsadmin fill:#FAC569,stroke:#333,stroke-width:3px
  sharedtf --> providers
  sharedtf --> templates

  gcpadmin --> vpcadmin[vpc]
  gcpadmin --> gkeadmin[gke]
  gcpadmin --> ...

  vpcadmin --> tfadmin[modules tf_files & scripts]

  admin --> |bootstrap and tool scripts|scripts
  admin --> |cloudbuilds|builds
  admin --> tests

end

subgraph INFRASTRUCTURE
  infra --> prod
  infra --> stage
  infra --> dev
  subgraph ENVIRONS
    prod --> gcp
    style gcp fill:#75FAF9,stroke:#333,stroke-width:3px
    prod --> aws
    style aws fill:#FAC569,stroke:#333,stroke-width:3px
    prod --> backends
    prod --> states
    prod --> variables
    gcp --> vpc
    gcp --> gke
    gcp --> ....
    vpc --> tf[tf_files]
    tf -.->|source| tfadmin
    tf -.->|symlink| backends
    tf -.->|symlink| states
    tf -.->|symlink| providers
    tf -.->|symlink| variables
  end
end

class INFRASTRUCTURE infra
class PLATFORM_ADMINS admin
class ENVIRONS environ
```
